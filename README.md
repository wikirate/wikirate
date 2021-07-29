[![Build Status][1]][2]
[![Maintainability][5]][6]
[![License: GPL v3][3]][4]

[1]: https://decko.semaphoreci.com/badges/wikirate/branches/master.svg?style=shields
[2]: https://decko.semaphoreci.com/projects/wikirate
[3]: https://img.shields.io/badge/License-GPLv3-blue.svg
[4]: https://www.gnu.org/licenses/gpl-3.0
[5]: https://api.codeclimate.com/v1/badges/876f4ff79be503fe8171/maintainability
[6]: https://codeclimate.com/github/wikirate/wikirate/maintainability

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
   or start fresh with a subject of your choice: `bundle exec rake wikirate:new_with_subject Camels`
1. add AWS credentials to config/application.rb (Ask wikirate dev team!  Sorry, we'll make this easier soon)
1. to make assets like icons work: `bundle exec rake decko:update_assets_symlink`
1. reset assets `rake card:asset:refresh`
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
2. start rspec with `decko rspec` and cucumber with `decko cucumber`.

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
You need [node.js](https://nodejs.org/en/) (>=6) and [ yarn ](https://yarnpkg.com/en/docs/install) installed. 
To set up CoffeeScript testing run `yarn install`. 
Start tests with `yarn jest test`.
Jest is configured to run all `.coffee` files in `mod/**/spec` folders.
The configuration can be changed in `package.json`. 
The basic setup for Jest with jquery and Decko's coffeescript is loaded in 
`test/setup_jest.js`. 
See `mod/wikirate/spec/lib/javascript/script_wikirate_common.test.coffee` for 
a simple example. 

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
