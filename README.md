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

## Wiki for a production environment
You can follow ![the wiki](https://github.com/LINCnil/pia-back/wiki) for a full production installation of the `pia` (frontend) and `pia-back` (backend) applications on an Ubuntu server.

## Requirements
- [pia (front-end) application](https://github.com/LINCnil/pia)
- [Ruby](http://www.ruby-lang.org) 3.1.x
- [Rails](http://rubyonrails.org) 7.0.x
- [PostgreSQL](https://www.postgresql.org) 12.0+

## System requirements
- CPU : i5
- Ram: 4Go
- Disk Space : 20Go
- OS : preferably Linux but other OS works as well

## PostgreSQL installation
See the [Install PostgreSQL](https://github.com/LINCnil/pia-back/wiki/Install-PostgreSQL) page in the Wiki.

## Enable the authentication mode

### Create the first admin account

Enter the rails console with `bin/rails c`

Launch the command `User.create(email: 'YOUR_EMAIL', password: 'Azeazeaze123-', password_confirmation: 'Azeazeaze123-')` (your password should be at least 12 characters long, with numbers and special characters).

Get your user, add him all roles and unlock him with the **unlock_access!** method:

```
    a = User.last
    a.is_technical_admin = true
    a.is_functional_admin = true
    a.is_user = true
    a.unlock_access!
    a.save
```

### Enable LDAP mode (optional)
If you want to use the LDAP authentification mode, set `DEVISE_LDAP_LOGGER=true` inside your `.env` file.


Set up the environment credentials variables using `EDITOR='nano' rails credentials:edit`:

```
ldap_host: [Fill it with the LDAP host]
ldap_port: [Fill it with the LDAP port]
ldap_attribute: [Fill it with the LDAP attribute]
ldap_base: [Fill it with the LDAP base]
ldap_ssl: [true or false]
```

If admin user binding is a necessity,
set `DEVISE_LDAP_LOGGER_ADMIN_BIND=true` inside your `.env` file and set up LDAP admin user credentials:

```
ldap_admin_user: [Fill it with the LDAP admin user]
ldap_admin_user_password: [Fill it with admin user password]
```

## Run the application in a development environment
- `bin/rails s` your server will be accessible with the URL `localhost:3000`

- You can specify the option `-b` to bind to a public IP address or domain name and `-p` to use a different port.

    For example: `bin/rails s -b 123.456.789.101 -p 8080` your server will be accessible with the URL `123.456.789.101:8080`

- Then, in [the pia (front-end) application](https://github.com/LINCnil/pia), use this URL to enable the server mode.

- Fill the field in "Tools" > "Settings"

- Every user will have to fill the server URL, the client ID and the client SECRET fields to access the authentication interface.

![PIA Settings](public/pia-settings.png)

## How to update to the latest version in a development environment

Go to the folder pia-back : `cd pia-back`

Update the repository : `git pull`

Update the dependencies : `bundle install`

Update the database : `bin/rake db:migrate`
