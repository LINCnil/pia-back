Getting started
===============

Requirements
------------

- [Ruby](http://www.ruby-lang.org) 2.3.x
- [Rails](http://rubyonrails.org) 5.0.x
- [PostgreSQL](https://www.postgresql.org) 9.4+

PostgreSQL installation
------------------

Basic installation on Debian you can use the following documentation: [wiki.debian.org/PostgreSql](https://wiki.debian.org/PostgreSql)
on Ubuntu you can use: [help.ubuntu.com/community/PostgreSQL](https://help.ubuntu.com/community/PostgreSQL)

Also, you need to create a new user with password

Clone the repository
--------------------

`git clone https://github.com/atnos/pia-back.git`

Create and fill the file database.yml
-------------------------------------

`cp config/database.example.yml config/database.yml`

Fill the fields `username` and `password` with the PostgreSQL username and password created in the previous step.

Create and fill the file application.yml
----------------------------------------

`cp config/application.example.yml config/application.yml`

Generate the SECRET_KEY_BASE with: `rake secret` and paste the secret key in the file.

Install all dependencies
------------------------

`bundle install`

Create database
---------------

`bin/rake db:create`

Create tables
-------------

`bin/rake db:migrate`

Run the application
-------------------

`bin/rails s` your server will be accessible with the URL `localhost:3000`

You can specify the option `-b` to bind to a public IP address or domain name and `-p` to use a différent port.

For example: `bin/rails s -b 123.456.789.101 -p 8080` your server will be accessible with the URL `123.456.789.101:8080`

Then, in the PIA application use this URL to activate the server mode. Fill the field in Tools > Settings

![PIA Settings](public/pia-settings.png)

Run the application in production mode
--------------------------------------

1. Fill the `production` section in the `database.yml`file.
2. Create the database: `RAILS_ENV=production bin/rake db:create`
3. Create the tables: `RAILS_ENV=production bin/rake db:migrate`
4. Run the server: `RAILS_ENV=production bin/rails s`

Run the full app through Docker-Compose for production
------------------------------------------------------

1. Fill the environment variables in `docker-compose.yml`
2. Run the containers `docker-compose up`
3. Access the website with `localhost:8080` or `yourdomain.net:8080`

Run the test
------------

`bin/rake`
