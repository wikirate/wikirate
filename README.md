Decko application code used at Wikirate.org

Code Organization
=========
Like all Decko decks, WikiRate's code is organized in
[_mods_](https://www.rubydoc.info/gems/card/Card/Mod).


Steps to make it work
----

The following will help set up a functioning wikirate site with a small subset of (mostly fake) data.  Some pages will not look complete.

1. fork repo on github: https://github.com/wikirate/wikirate/
1. clone repo: `git clone git@github.com:YOURNAME/wikirate.git`
1. enter dir: `cd wikirate`
1. init/update submodules `git submodule update -f --init --recursive`
1. install gems: `bundle install`
1. set up config: `cp -R sample_config/* config`
1. populate dev database (with test data): `DATABASE_NAME_TEST=wikirate_dev bundle exec rake wikirate:test:seed`
1. add AWS credentials to config/application.rb (Ask wikirate dev team!  Sorry, we'll make this easier soon)
1. reset machines `rake card:reset_machine_output`
1. start server: `bundle exec decko s`

note: 
- initial homepage load will take a long time.
- You can log into the test data with:
  - joe@user.com  / joe_pass, or
  - joe@admin.com / joe_pass
  


Testing
=========

Running Tests
----
1. populate test database: `bundle exec rake wikirate:test:seed`
2. start rspec with `decko rspec`cucumber with `decko cucumber`.

Alternatively, you can use the shorter commands `decko rs` and `decko cc`

To run specific tests, you can add `--` followed by the test file.

Eg. `decko rs -- /my/file/is/here`

Writing Tests
----
Sample tests contained here:

Paths:
```sh
 mod/*/spec                       # rspec and jest tests
 mod/*/features                   # cucumber tests
 mod/*/features/step_definitions  # cucumber step definitions
```

CoffeeScript Tests
----
To set up coffeescript testing run `yarn install` 
(if you don't have yarn [ get it here ](https://yarnpkg.com/en/docs/install) or
use any other package manager that can handle a package.json file)
Start tests with `jest test`.
Jest is configured to run all `.coffee` files in `mod/**/spec` folders.
The configuration can be changed in `package.json`. 
The basic setup for Jest with jquery and decko's coffeescript is loaded in 
`test/setup_jest.js`. 

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
