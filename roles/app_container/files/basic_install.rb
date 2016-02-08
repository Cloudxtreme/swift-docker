app_name = ENV['APP_NAME']
environment = ENV['APP_ENV']
system_name = ENV['SYSTEM_NAME']
database_name = app_name + "_" + ENV['APP_ENV']
database_password = ENV['DATABASE_PASSWORD']
database_url = ENV['DATABASE_URL']
git_url = ENV['GIT_URL']
git_branch = ENV['GIT_BRANCH']

app_dir = "/var/swift/#{app_name}"
`mkdir -p #{app_dir}`
Dir.chdir "#{app_dir}"
if !File.exists?(app_dir + "/Package.swift")
  `rm -rf #{app_dir}/*`
  `ssh-keyscan github.com >> /root/.ssh/known_hosts`
  `git clone #{git_url} #{app_dir}`
end
`git fetch; git checkout #{git_branch}; git pull`

system <<EOS
bash -cl "
  swift build
"
EOS

File.open("Resources/config/database.plist", "w") do |file|
  file.puts(<<EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>host</key>
  <string>#{database_url}</string>
  <key>username</key>
  <string>#{system_name}</string>
  <key>password</key>
  <string>#{database_password}</string>
  <key>database</key>
  <string>#{database_name}</string>
</dict>
</plist>
EOS
  )
end
system "mysql -u#{system_name} -p\"#{database_password}\" -h#{database_url} -e 'CREATE DATABASE IF NOT EXISTS #{database_name}'"
if environment == "development"
  File.open("Resources/config/testDatabase.plist", "w") do |file|
    test_database_name = database_name.gsub(/development$/, 'test')
    file.puts(<<EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>host</key>
  <string>#{database_url}</string>
  <key>username</key>
  <string>#{system_name}</string>
  <key>password</key>
  <string>#{database_password}</string>
  <key>database</key>
  <string>#{test_database_name}</string>
</dict>
</plist>
EOS
    )
    
    system "mysql -u#{system_name} -p\"#{database_password}\" -h#{database_url} -e 'CREATE DATABASE IF NOT EXISTS #{test_database_name}'"
  end
end