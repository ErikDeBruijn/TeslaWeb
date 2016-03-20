require 'yaml'
require 'pp'
require 'tesla_api'
require 'sinatra'

enable :sessions

configure do
	set :bind, '0.0.0.0'
end

$config = YAML::load_file('./config.yaml')

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    if(@auth.provided? and @auth.basic? and @auth.credentials)
    	c = @auth.credentials
    	pp c
    	$config[:users][c[0]] == c[1]
    end
  end
end

def tesla_signin
	token_days_old = (Time.now.to_i - $config[:token_time].to_i)/60/60/24
	tesla_api = TeslaApi::Client.new($config[:tesla_email],$config[:TESLA_CLIENT_ID], $config[:TESLA_CLIENT_SECRET])
	if(token_days_old < 7)
		pp "Have a valid token already: #{$config[:token]}, using that."
		tesla_api.token = $config[:token]
	else
		new_token = tesla_api.login!($config[:tesla_password])
		pp "Got a new token: #{new_token}"
		if new_token.is_a? String
			$config[:token] = new_token
			$config[:token_time] = Time.now.to_i
		end
	end
	vehicles = tesla_api.vehicles
	# model_s.wake_up
	@model_s = vehicles.first # => <TeslaApi::Vehicle>
end

get '/' do
	pp params
	message = ""
	message = "#{params['message']}<br>" if params['message'] 
	# pin = session[:last_pin]
	# <input type="textfield" name="PIN" value="'+pin+'"/>
	  # <input value="Charge to max" name="charge_max" type="submit" style="width:100%;height: 400px;font-size:70px"/><br>
	'Hi. '+ message +' Push a button:
	<form method="post" action="/api/v1/cmd">
	  <input value="Open port" name="open_port" type="submit" style="width:100%;height: 400px;font-size:70px"/><br>
	</form>'
end

get '/api/v1/cmd' do
	redirect '/', 301
end

post '/api/v1/cmd' do
	protected!
	# session[:last_pin] = params[:PIN]
	# pp params[:PIN]
	# redirect "/?message=Not%20Allowed", 303 if params[:PIN] != $config[:valid_pin]
	stream do |out|
		# out << "Signing in."
		tesla_signin()
		out << "Signed in. "
		if params[:open_port]
			pp @model_s.charge_port_door_open
			out << "Port opened. "
		end
		if params[:charge_max]
			@model_s.charge_port_door_open
			@model_s.set_charge_limit(100)
		end
		out << "Done. <a href=\"/\" style=\"font-size:70px\">Back.</a>"
	end
end

File.open('./config.yaml', 'w') {|f| f.write $config.to_yaml }
