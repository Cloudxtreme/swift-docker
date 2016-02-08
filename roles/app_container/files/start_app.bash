ruby /basic_install.rb
ruby /custom_install.rb
cd /var/swift/$APP_NAME
.build/debug/${APP_NAME[*]^}App run_alterations
.build/debug/${APP_NAME[*]^}App server