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

Paths:
```sh
 mod/*/spec                       # rspec tests
 mod/*/features                   # cucumber tests
 mod/*/features/step_definitions  # cucumber step definitions
```

Run `rake wikirate:test:seed` to prepare test database.

Start rspec with `wagn rspec` and cucumber with `wagn cucumber`.
Alternatively, you can use the shorter commands `wagn rs` and `wagn cc`

To update the test data from the dev site run
```sh
cap staging backup:pull_db
env RAILS_ENV=test rake wikirate:test:update_seed_data
```

This updates the mysql dump in  test/wikiratetest.db that is also used for
continuous integration testing. So don't forget to include it in your git commits.


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