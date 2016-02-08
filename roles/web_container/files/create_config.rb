#! ruby
require 'json'

domain = ENV["DOMAIN_ROOT"]
app_config = JSON.parse(ENV["APP_CONFIG"].gsub(/u?'/, '"'))
app_config.each do |app, info|
  port = info['port']
  File.open("/etc/nginx/sites-available/#{app}", "w") do |file|
    file.write(<<-EOF.gsub(/^ {6}/, '')
      server {
        listen 80;
        listen 443;
        server_name #{app}.#{domain};
        proxy_set_header   Host               $host;
        proxy_set_header   X-Real-IP          $remote_addr;
        proxy_set_header   X-Forwarded-For    $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto  $scheme;
    
        location / {
          if ($http_x_forwarded_proto = 'http') {
            rewrite ^ https://$host$request_uri? permanent;
          }
          try_files /maintenance.html $uri @app;
        }
    
        location @app {
          proxy_pass http://localhost:#{port};
          proxy_redirect default;
        }
      }
      server {
        listen 443;
        server_name www.#{app}.#{domain};
        rewrite ^(.*)$ https://#{app}.#{domain}$1 permanent;
      }
      server {
        listen 80;
        server_name www.#{app}.#{domain};
        rewrite ^(.*)$ https://#{app}.#{domain}$1 permanent;
      }
    EOF
    )
  end
  `ln -s /etc/nginx/sites-available/#{app} /etc/nginx/sites-enabled/#{app}`
end
`rm /etc/nginx/sites-enabled/default`
`rm /etc/nginx/sites-available/default`