# Le logiciel PIA / The PIA Software
<img src="https://raw.githubusercontent.com/LINCnil/pia/master/src/assets/images/pia-auth-logo.png" align="left" hspace="10" vspace="6"> Le logiciel PIA est un outil distribué librement par la [CNIL](https://www.cnil.fr/fr/outil-pia-telechargez-et-installez-le-logiciel-de-la-cnil) afin de faciliter la réalisation d’analyses d’impact sur la protection des données prévues par le RGPD.
PIA-BACK est développé avec le framework RubyOnRails mettant à disposition une API RESTful à destination des outils PIA et PIA-APP.

The PIA software is a free tool published by the [CNIL](https://www.cnil.fr/en/open-source-pia-software-helps-carry-out-data-protection-impact-assesment) which aims to help data controllers build and demonstrate compliance to the GDPR.
PIA-BACK is developped with RubyOnRails providing a RESTful API for the PIA and PIA-APP applications.

[![CI](https://github.com/LINCnil/pia-back/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/LINCnil/pia-back/actions/workflows/ci.yml)
[![CodeQL](https://github.com/LINCnil/pia-back/actions/workflows/codeql-analysis.yml/badge.svg?branch=master)](https://github.com/LINCnil/pia-back/actions/workflows/codeql-analysis.yml)
[![CodeFactor](https://www.codefactor.io/repository/github/lincnil/pia-back/badge)](https://www.codefactor.io/repository/github/lincnil/pia-back)
[![Rails Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop-rails)
[![Rails Style Guide](https://img.shields.io/badge/code_style-community-brightgreen.svg)](https://rails.rubystyle.guide)

## Wiki for a production environment
**You can follow [the wiki](https://github.com/LINCnil/pia-back/wiki) for a full production installation of the `pia` (frontend) and `pia-back` (backend) applications on an Ubuntu server.**

## Requirements
- [pia (front-end) application](https://github.com/LINCnil/pia)
- [Ruby](http://www.ruby-lang.org) 3.4.x
- [Rails](http://rubyonrails.org) 8.0.x
- [PostgreSQL](https://www.postgresql.org) 13+

## System requirements
- CPU : i5
- Ram: 4Go
- Disk Space : 20Go
- OS : preferably Linux but other OS works as well

# Ruby installation
See the [Install Ruby](https://github.com/LINCnil/pia-back/wiki/Install-ruby) page in the Wiki.

## PostgreSQL installation
See the [Install PostgreSQL](https://github.com/LINCnil/pia-back/wiki/Install-PostgreSQL) page in the Wiki.

<<<<<<< HEAD
## Run the application in a development environment
=======
On Ubuntu you can use: [help.ubuntu.com/community/PostgreSQL](https://help.ubuntu.com/community/PostgreSQL)

Also, you need to create a new user with password.

## Clone the repository
`git clone https://github.com/LINCnil/pia-back.git`

## Go to the folder pia-back
`cd pia-back`

## Create and fill the file database.yml
`cp config/database.example.yml config/database.yml`

Fill the fields `username` and `password` for each environment with the PostgreSQL username and password created in the step "PostgreSQL installation".

## Install all dependencies
`bundle install`

## Create and fill the file `.env` file
Go in the root path of the back project then `cp .env-example .env`.

Generate the `SECRET_KEY_BASE` with `bin/rake secret` and paste the secret key in the file.

Generate the `DEVISE_SECRET_KEY` with `bin/rake secret` and paste the secret key in the file.

Generate the `DEVISE_PEPPER` with `bin/rake secret` and paste the secret key in the file.

Fill `MAILER_SENDER` with the default address email sender.

Fill `DEFAULT_URL` with the URL of your server.

If needed, fill `DEFAULT_PORT` to the PORT you use.

## Create the database
`bin/rake db:create`

## Create tables
`bin/rake db:migrate`

## Configure the application

Set `ENABLE_AUTHENTICATION=true` inside your `.env` file

Enter the rails console with `bin/rails c`

Launch the command `Doorkeeper::Application.create(name: "PIA", redirect_uri: "urn:ietf:wg:oauth:2.0:oob", scopes: ["read", "write"])`

Find your Client ID and Client SECRET by using `Doorkeeper::Application.select(:uid, :secret).last.uid` and `Doorkeeper::Application.select(:uid, :secret).last.secret`

See:

![image](https://github.com/LINCnil/pia-back/assets/24872475/b82f817d-6faa-4e9a-b5bb-df056049abc5)

You will need the CLIENT ID and the CLIENT SECRET data to enable the authentication mode in your PIA application, in the settings page.

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

### Enable SSO mode (optional)
This following information are required to enable SSO mode, make sure you have them all:
- "entity_id (issuer)"
- "sso_service_url (idp_sso_target_url)"
- "idp_cert (idp_cert_fingerprint)"

set those informations inside your `.env` file.

```
ENABLE_SSO=true
IDP_ENTITY_ID=[ENTITY ID VALUE]
IDP_SSO_TARGET_URL=[SSO TARGET URL]
IDP_SLO_TARGET_URL=[SSO TARGET URL] (same URL than IDP_SSO_TARGET_URL)
IDP_CERT=[SSO CERTIFICATE VALUE]
SSO_FRONTEND_REDIRECTION=[FRONT_END_URL]
```

Restart your pia-back rails app.

You also need to configure your SAML SSO:
- "Identifier (Entity ID)" : https://[PIA_BACK_URL]/saml/metadata
- "Reply URL (Assertion Consumer Service URL / ACS)" : https://[PIA_BACK_URL]/saml/acs
- "Logout URL (Single Logout URL / SLO)" : https://[PIA_BACK_URL]/saml/slo

After this, you should be able to use the SSO authentication button on the homepage of the PIA tool.

## SMTP configuration
Set up the environment credentials variables using `EDITOR='nano' rails credentials:edit` :

```
email_from: pia@xxxx.com
smtp_address: xxxx
smtp_port: xxxx
smtp_domain: xxxx
smtp_user_name: xxxx
smtp_password: xxxx
smtp_authentication: :cram_md5
smtp_enable_starttls_auto: true
```


## Configure the default locale for the authentication emails

The PIA tool can send different emails when the authentication module is enabled (new user, new evaluation ready, ...).

The default locale for the content of the authentication emails is English (en).

Define `DEFAULT_LOCALE="[locale key]"` inside your `.env` file to change the locale.

For example, if you want to have French translations for the authenication emails, configure `DEFAULT_LOCALE="fr"` in your `.env` file.

Supported locales: bg, cs, da, de, el, en, es, et, fi, fr, hr, hu, it, lt, lv, nl, no, pl, pt, ro, sl, sv.

## Run the application
>>>>>>> 90d4a03 (Update README.md)
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

## Rails 8 - How to migrate your attachments from Carrierwave to ActiveStorage

This migration utility converts file attachments from the legacy Carrierwave storage system to Rails' ActiveStorage.
Note that this migration only works for locally stored files and requires the correct file structure within the data/attachment/attached_file/ directory.

`RAILS_ENV=production bin/rake active_storage_migration`
