[![Build Status][1]][2]
[![Maintainability][5]][6]
[![License: GPL v3][3]][4]

[1]: https://decko.semaphoreci.com/badges/wikirate/branches/main.svg?style=shields
[2]: https://decko.semaphoreci.com/projects/wikirate
[3]: https://img.shields.io/badge/License-GPLv3-blue.svg
[4]: https://www.gnu.org/licenses/gpl-3.0
[5]: https://api.codeclimate.com/v1/badges/876f4ff79be503fe8171/maintainability
[6]: https://codeclimate.com/github/wikirate/wikirate/maintainability

Decko application code used at Wikirate.org

Code Organization
=================
WikiRate is a website built with Decko, or a "deck."

Decko code is primarily written in Ruby, and ruby code is typically distributed in 
libraries called "gems." Decko code has a few main core gems (_decko_, _card_, 
and _cardname_), and then everything else is organized into 
[_mods_][https://docs.decko.org/docs/Cardio/Mod], which you can
think of as short for "modules" or "modifications". 

WikiRate developers work with mods in three different main GitHub repositories:

1. [decko-commons/decko](https://github.com/decko-commons/decko), which contains code
for core gems and the mods that are included by default in new decks.
2. [decko-commons/card-mods](https://github.com/decko-commons/card-mods), which contains 
other mod gems developed by Decko Commons, and
3. [wikirate/wikirate](https://github.com/wikirate/wikirate/). (this repo!)


Setting up a Development Environment
====================================

The following will help set up a functioning wikirate site with a small subset of 
(mostly fake, largely silly) WikiRate data.

First, you will need to install Decko dependencies


First, you will need to make your own fork of the GitHub repository. 
1. fork repo on github: https://github.com/wikirate/wikirate/

We each maintain our own fork so that we can make pull requests from that fork. For 
example, Ethan's fork is at https://github.com/ethn/wikirate.

Now we pull that code down to our computers.

2. `git clone git@github.com:YOURNAME/wikirate.git`

At this point we have the main wikirate repo, but there's a lot more code we need in
nested repositories, which git calls _submodules_.  The following command will pull down
the latest submodules, including the _decko_, _card-mods_, and others that we don't 
maintain.

3. `cd wikirate`
4. `git submodule update -f --init --recursive`

Nearly all ruby developers these days use a beloved gem management tool called _bundler_.
Bundler defines the "bundle" of gems you need for your application. "bundle install" will
install all those gems.

5. `bundle install`

Each different decko site has different configuration options for their own purposes.
The production site does not have all the same configuration as your test site for 
example. And some configuration settings (such as credentials) are private. So the main
config files are not in git.  However, we have set up some sample configuration
options here to get you started:

6. `cp -R config/sample/* config`

Now we seed the database with our silly data and start the server:

7. `bundle exec rake wikirate:test:seed`
8. `bundle exec decko s`

You can log into the test data with:
  
  - joe@user.com  / joe_pass, or
  - joe@admin.com / joe_pass



Updating your code
==================

To get the latest code you will need to do the following:

```
git pull                             # pull the latest wikirate/wikirate code
git submodule update -f --recursive  # update the nested git repositories
bundle update                        # get the latest gems 
```


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

[//]: # (CoffeeScript Tests)
[//]: # (----)
[//]: # (You need [node.js]&#40;https://nodejs.org/en/&#41; &#40;>=6&#41; and [ yarn ]&#40;https://yarnpkg.com/en/docs/install&#41; installed. )
[//]: # (To set up CoffeeScript testing run `yarn install`. )
[//]: # (Start tests with `yarn jest test`.)
[//]: # (Jest is configured to run all `.coffee` files in `mod/**/spec` folders.)
[//]: # (The configuration can be changed in `package.json`. )
[//]: # (The basic setup for Jest with jquery and Decko's coffeescript is loaded in )
[//]: # (`test/setup_jest.js`. )
[//]: # (See `mod/wikirate/spec/lib/javascript/script_wikirate_common.test.coffee` for )
[//]: # (a simple example. )

Deploying Changes
================

Requires server permissions.

**TODO!**

Maintenance messages
----------------

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
