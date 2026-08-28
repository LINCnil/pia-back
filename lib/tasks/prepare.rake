namespace :prepare do
  desc "Prepare the app for deployment by precompiling assets and cleaning up old files"
  task :app, [:username] => [:environment] do |task, args|

    puts "Register the following informations and keep then safe, you will need them to configure the PIA client:"

    # Create a Doorkeeper application for the PIA client
    Doorkeeper::Application.create(name: "PIA", redirect_uri: "urn:ietf:wg:oauth:2.0:oob", scopes: ["read", "write"])
    item = Doorkeeper::Application.select(:uid, :secret).last
    puts "PIA Client ID: #{item.uid}"
    puts "PIA Client Secret: #{item.secret}"

    if args.has_key?(:username)

      puts "Creating an admin user with the provided email address..."

      username = args[:username]
      password = [*'0'..'9', *'a'..'z', *'A'..'Z', *'!'..'?'].sample(16).join
      User.create( email: username, password: password,password_confirmation:password)
      user = User.find_by(email: username)
      user.update(is_technical_admin: true, is_functional_admin: true, is_user: true)
      user.unlock_access!

      puts "Admin user created with email: #{username} and password: #{password}"

    end

  end
end