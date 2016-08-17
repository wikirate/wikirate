Wagn application code used at Wikirate.org
=========

Steps to make it work
----

1. create folders "files","config","public" and "public/assets" under the wikirate root directory.
2. rake wagn:seed
3. import the database
4. bundle exec wagn s


Testing
=========

Running Tests
----
Run `rake wikirate:test:seed` to populate the test database

Start rspec with `wagn rspec` and cucumber with `wagn cucumber`.
Alternatively, you can use the shorter commands `wagn rs` and `wagn cc`


Writing Tests
----
Sample tests contained here:

Paths:
```sh
 mod/*/spec                       # rspec tests
 mod/*/features                   # cucumber tests
 mod/*/features/step_definitions  # cucumber step definitions
```

Updating Test DB
----
Run `rake wikirate:test:reseed_data` to prepare test database.
1. This command accepts one argument that indicate the production DB env. `production`, `local`, `dev` are options to set the location of your seed DB. Options other than these three will be treated as `production`.
2. It will get the pre-defined seed cards from the card `production_export` and then import some needed cards from `test/seed.rb`. Migration will also be run to let the test db catch up to your local dev environment.
3. It will dump the test db to `test/wikiratetest.db` for the CI testing.


Start rspec with `wagn rspec` and cucumber with `wagn cucumber`.
Alternatively, you can use the shorter commands `wagn rs` and `wagn cc`

After Updating Test DB (Optional)
----
As Wagn updated transaction handling, tables will be truncated after every cucumber test.
There is rake task to re-import the test db after every test. It is ok to run the cucumebr tests after the reseed of data, but it would be very slow because of regenerating the *all+*script and *all+*style cards.

These steps could help reduce the testing time.
1. Start the server in test environment
```ruby
RAILS_ENV=test bundle exec wagn s
```
2. Access the page at http://localhost:3000 (based on your settings)
3. Stop the server after the page is loaded
4. Dump the test db
```ruby
bundle exec rake wikirate:test:dump_test_db
```

Site Maintenance
================

See documentation here: https://github.com/capistrano/maintenance

quick examples:
```
  # turn on maintenance message with defaults
  cap production maintenance:enable

  # turn on maintenance message with more info
  cap production maintenance:enable REASON="database update" UNTIL="in a minute or two"

  # turn maintenance message off
  cap production maintenance:disable

```
