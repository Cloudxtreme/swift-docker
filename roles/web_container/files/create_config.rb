#! ruby
require 'json'

domain = ENV["DOMAIN_ROOT"]
app_config = JSON.parse(ENV["APP_CONFIG"].gsub(/u?'/, '"'))
app_config.each do |app, info|
  port = info['port']
  File.open("/etc/nginx/sites-available/#{app}", "w") do |file|
    if ENV["RAILS_ENV"] == "development"

      file.write(<<-EOF.gsub(/^ {6}/, '')
        server {
          listen 80;
          server_name #{app}.#{domain};
          proxy_set_header   Host               $host;
          proxy_set_header   X-Real-IP          $remote_addr;
          proxy_set_header   X-Forwarded-For    $proxy_add_x_forwarded_for;
          proxy_set_header   X-Forwarded-Proto  $scheme;
      
          location / {
            try_files /maintenance.html $uri @app;
          }
      
          location @app {
            proxy_pass http://localhost:#{port};
            proxy_redirect default;
          }
        }
      EOF
      )
    else
      file.write(<<-EOF.gsub(/^ {6}/, '')
        server {
          listen 443;
          server_name #{app}.#{domain};
          proxy_set_header   Host               $host;
          proxy_set_header   X-Real-IP          $remote_addr;
          proxy_set_header   X-Forwarded-For    $proxy_add_x_forwarded_for;
          proxy_set_header   X-Forwarded-Proto  $scheme;
      
          location / {
            try_files /maintenance.html $uri @app;
          }

          ssl on;
          ssl_session_timeout    5m;
          ssl_protocols    TLSv1 TLSv1.1 TLSv1.2;
          ssl_certificate /etc/nginx/ssl/#{domain}_cert.pem;
          ssl_certificate_key /etc/nginx/ssl/#{domain}_key.pem;
      
          location @app {
            proxy_pass http://localhost:#{port};
            proxy_redirect default;
          }
        }
        server {
          listen 80;
          server_name #{app}.#{domain};
          rewrite ^(.*)$ https://#{app}.#{domain}$1 permanent;
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
  end
  `ln -s /etc/nginx/sites-available/#{app} /etc/nginx/sites-enabled/#{app}`
end
`rm /etc/nginx/sites-enabled/default`
`rm /etc/nginx/sites-available/default`
`cat /etc/nginx/ssl/#{domain}_chain.pem >> /etc/nginx/ssl/#{domain}_cert.pem`