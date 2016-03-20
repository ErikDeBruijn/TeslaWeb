# TeslaWeb

A sinatra script to unlock charger for colleagues.

## What it does

If you access the panel with your webbrowser you can push an "Open port" button to open the charge port on the Tesla Model S or X. It will require a password, you can configure users in the config.json.example
## How to use

How to get in running:
 - Use a Linux or other system that runs ruby, with a public ip or port forward
 - For debian or ubuntu, install ruby. E.g. `apt-get install ruby ruby-dev`
 - `gem install bundler`
 - `bundle`
 - `gem install rerun`
 - `cp config.json{.example,}`
 - `rerun 'ruby teslaweb.rb'`
 - To make it start at boot, add to `/etc/rc.local` the following: (replace `erik` with your username)
 ```
 cd ~erik/TeslaWeb
 sudo -u erik rerun ruby TeslaWeb.rb 
```

## Credits

This is just a simple script. Most of the work is done by others. Makes use of the gem and Tesla API documentation by Tim Dorr. See https://github.com/timdorr/model-s-api for more info.
