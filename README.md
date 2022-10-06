# Le logiciel PIA / The PIA Software
<img src="https://raw.githubusercontent.com/LINCnil/pia/master/src/assets/images/pia-auth-logo.png" align="left" hspace="10" vspace="6"> Le logiciel PIA est un outil distribué librement par la [CNIL](https://www.cnil.fr/fr/outil-pia-telechargez-et-installez-le-logiciel-de-la-cnil) afin de faciliter la réalisation d’analyses d’impact sur la protection des données prévues par le RGPD.
PIA-BACK est développé avec le framework RubyOnRails mettant à disposition une API RESTful à destination des outils PIA et PIA-APP.

The PIA software is a free tool published by the [CNIL](https://www.cnil.fr/en/open-source-pia-software-helps-carry-out-data-protection-impact-assesment) which aims to help data controllers build and demonstrate compliance to the GDPR.
PIA-BACK is developped with RubyOnRails providing a RESTful API for the PIA and PIA-APP applications.

![Rails tests](https://github.com/lincnil/pia-back/workflows/CI/badge.svg?branch=master)
[![CodeQL](https://github.com/LINCnil/pia-back/actions/workflows/codeql-analysis.yml/badge.svg?branch=master)](https://github.com/LINCnil/pia-back/actions/workflows/codeql-analysis.yml)
[![CodeFactor](https://www.codefactor.io/repository/github/lincnil/pia-back/badge)](https://www.codefactor.io/repository/github/lincnil/pia-back)
[![Rails Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop-rails)
[![Rails Style Guide](https://img.shields.io/badge/code_style-community-brightgreen.svg)](https://rails.rubystyle.guide)

## Installation
You can follow ![the wiki](https://github.com/LINCnil/pia-back/wiki) for a full installation of PIA (back-end) and PIA (front-end) applications on a ubuntu 20.04 server.

### Requirements
- [pia (front-end) application](https://github.com/LINCnil/pia)
- [Ruby](http://www.ruby-lang.org) 2.7.x
- [Rails](http://rubyonrails.org) 6.0.x
- [PostgreSQL](https://www.postgresql.org) 12.0+

### System requirements
- CPU : i5
- Ram: 4Go
- Disk Space : 20Go
- OS : preferably Linux but other OS works as well

### PostgreSQL installation
Basic installation on Debian you can use the following documentation: [wiki.debian.org/PostgreSql](https://wiki.debian.org/PostgreSql)
on Ubuntu you can use: [help.ubuntu.com/community/PostgreSQL](https://help.ubuntu.com/community/PostgreSQL)

Also, you need to create a new user with password.

### Clone the repository
`git clone https://github.com/LINCnil/pia-back.git`

### Go to the folder pia-back
`cd pia-back`

### Create and fill the file database.yml
`cp config/database.example.yml config/database.yml`

Fill the fields `username` and `password` for each environment with the PostgreSQL username and password created in the step "PostgreSQL installation".

### Install all dependencies
`bundle install`

### Create and fill the file `.env` file
`cp .env-example .env`

Generate the SECRET_KEY_BASE with `bin/rake secret` and paste the secret key in the file.
Generate the DEVISE_SECRET_KEY with `bin/rake secret` and paste the secret key in the file.
Generate the DEVISE_PEPPER with `bin/rake secret` and paste the secret key in the file.
Fill MAILER_SENDER with the default address email sender
Fill DEFAULT_URL with the URL of your server
If needed, fill DEFAULT_PORT to the PORT you use


### Create database
`bin/rake db:create`

### Create tables
`bin/rake db:migrate`

### Enable the authentication mode

#### configure App

Set `ENABLE_AUTHENTICATION=true` inside your `.env` file

Enter the rails console with `bin/rails c`

Launch the command `Doorkeeper::Application.create(name: "PIA", redirect_uri: "urn:ietf:wg:oauth:2.0:oob", scopes: ["read", "write"])`

Find your UID and SECRET information `Doorkeeper::Application.select(:uid, :secret).first`

Use these credentials into your PIA application

#### Create admin account

Enter the rails console with `bin/rails c`

Launch the command `User.create(email: 'YOUR_EMAIL', password: 'Azeazeaze123-', password_confirmation: 'Azeazeaze123-')` (your password should be at least 12 characters long, with numbers and special characters).

Unlock your user with the **unlock_access!** method

```
    a = User.last
    a.is_technical_admin = true
    a.is_functional_admin = true
    a.is_user = true
    a.unlock_access!
```

### Enable LDAP MODE
Set `DEVISE_LDAP_LOGGER=true` inside your `.env` file.

Set up the environment credentials variables using `EDITOR='nano' rails credentials:edit` :

```
ldap_host: [Fill it with the LDAP host]
ldap_port: [Fill it with the LDAP port]
ldap_attribute: [Fill it with the LDAP attribute]
ldap_base: [Fill it with the LDAP base]
ldap_admin_user: [Fill it with the LDAP admin user]
ldap_admin_user_password: [Fill it with admin user password]
ldap_ssl: [true or false]
```

### Run the application
- `bin/rails s` your server will be accessible with the URL `localhost:3000`

- You can specify the option `-b` to bind to a public IP address or domain name and `-p` to use a different port.

    For example: `bin/rails s -b 123.456.789.101 -p 8080` your server will be accessible with the URL `123.456.789.101:8080`

- Then, in [the pia (front-end) application](https://github.com/LINCnil/pia), use this URL to enable the server mode.

- Fill the field in "Tools" > "Settings"

- For the authentication mode: every user will have to fill the server URL, the client ID and the client SECRET fields to access the authentication interface.

![PIA Settings](public/pia-settings.png)

### Run the application in production mode
1. Fill the `production` section in the `database.yml`file.
2. Create the database: `RAILS_ENV=production bin/rake db:create`
3. Create the tables: `RAILS_ENV=production bin/rake db:migrate`
4. Run the server: `RAILS_ENV=production bin/rails s`

### How to update to the latest version

Go to the folder pia-back : `cd pia-back`

Update the repository : `git pull`

Update the dependencies : `bundle install`

Update the database : `RAILS_ENV=production bin/rake db:migrate`

### Run the test
`bin/rake`

### Change default locale
Pia back mailer work with rails-i18n. For update default locale,
go to change this line in rails configuration:

In config/application.rb
```
config.i18n.default_locale = :en
```

## Contributions
- [Docker set-up](https://github.com/kosmas58/pia-docker) ([Kosmas Schütz](https://github.com/kosmas58)): a Docker-Compose configuration for production purpose. Everything is automated from creating containers to setting up the database.
- [Installation runbook](https://github.com/LINCnil/pia/issues/77) ([ylachgar](https://github.com/ylachgar)): runbook to install the pia tool server version on a ubuntu 17.10 server.

