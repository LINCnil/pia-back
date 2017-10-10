Getting started
===============

Requirements
------------

- [Ruby](http://www.ruby-lang.org) 2.3.x
- [Rails](http://rubyonrails.org) 5.0.x

Clone the repository
--------------------

`git clone https://github.com/atnos/pia-back.git`

Create and fill the file database.yml
-------------------------------------

`cp config/database.example.yml config/database.yml`

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

`bin/rails s`

Run the test
------------

`bin/rake`
