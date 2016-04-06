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

Run `rake wikirate:test:reseed_data` to prepare test database.
1. This command accepts one argument that indicate the production DB env.
  `production`, `local`, `dev` are options to set the location of your seed DB.
  Options other than these three will be treated as `production`.
2. It will get the pre-defined seed cards from the card `production_export` and
  then import some needed cards from `test/seed.rb`. Migration will also be run
  to let the test db catch up to your local dev environment.
3. It will dump the test db to `test/wikiratetest.db` for the CI testing.


Start rspec with `wagn rspec` and cucumber with `wagn cucumber`.
Alternatively, you can use the shorter commands `wagn rs` and `wagn cc`

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