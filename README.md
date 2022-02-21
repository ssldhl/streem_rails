# Streem

To get the application up and running.

* Copy `master.key` to `config/` directory

* Install Ruby version - `ruby-3.0.2` with gemset `streem` as specified in `.ruby-version` and `.ruby-gemset` files

* Run `bundle install`

* Configure postgres database with username - `pguser` and password `root`

* Run `rails db:setup db:migrate`

* Finally `rails s -p 4000`
