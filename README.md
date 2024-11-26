[![Build Status][1]][2]
[![Maintainability][5]][6]
[![License: GPL v3][3]][4]

[1]: https://decko.semaphoreci.com/badges/wikirate/branches/main.svg?style=shields
[2]: https://decko.semaphoreci.com/projects/wikirate
[3]: https://img.shields.io/badge/License-GPLv3-blue.svg
[4]: https://www.gnu.org/licenses/gpl-3.0
[5]: https://api.codeclimate.com/v1/badges/876f4ff79be503fe8171/maintainability
[6]: https://codeclimate.com/github/wikirate/wikirate/maintainability
[7]: https://github.com/wikirate/wikirate/
[8]: https://docs.decko.org/docs/Cardio/Mod
[9]: https://github.com/wikirate/wikirate/blob/main/mod/Modfile

Decko application code used at Wikirate.org

Code Organization
=================
WikiRate is a website built with Decko, or a "deck."

Decko code is primarily written in Ruby, and ruby code is typically distributed in 
libraries called "gems." Decko code has a few main core gems (_decko_, _card_, 
and _cardname_), and then everything else is organized into [_mods_][8], which you can
think of as short for "modules" or "modifications". 

### Repositories

WikiRate developers work with mods in three different main GitHub repositories:


1. [wikirate/wikirate][7] – this repo.
2. [decko-commons/decko](https://github.com/decko-commons/decko), which contains code
for core gems and the mods that are included by default in new decks. It is included as a
submodule of this repo at `vendor/decko`.
3. [decko-commons/card-mods](https://github.com/decko-commons/card-mods), which contains 
other mod gems developed by Decko Commons. It's included here at `vendor/card-mods`


### Directories

A quick overview of the purpose of each directory in this repo:

- _.semaphore_ configures our [continuous integration testing with Semaphore](https://decko.semaphoreci.com/).
- _config_ is for configuration settings, many of which will vary between installations.
- [_cypress_](https://www.cypress.io/) is one of our integration testing tools.
- _db_ is for database seed data and migrations (may soon be moved into mods).
- _files_ is where uploaded images and other files are stored.
- _lib_ contains a few rake tasks and deployment scripts (will soon be moved into mods).
- _log_ stores logs from web requests, tests, etc.
- _mod_ is where we keep [_mods_][8], **the main WikiRate code**. More details below.
- _public_ files are exposed to the web. (It's mostly symbolic links to the public 
directories in mods.)
- _script_ contains lots of one-off scripts, eg for data transformations.
- _spec_ contains configuration for rspec tests. (The tests themselves are in mods.)
- _tmp_ holds caches and other temporary data.
- _vendor_ contains git submodules, including `decko` and `card-mods`.

### Mods

Inside the `mod` directory there are many mod directories and a file named `Modfile`.
When a deck has a _Modfile_, it means we've specified a load order for the mods. 

WikiRate's [Modfile][9] is more involved than most, but it's reasonably well commented.
The mods can be grouped into four main groups:

1. mods prefixed with **deckorate_**. DeckoRate is an abstraction of WikiRate; it has
metrics, answers, sources, datasets, etc, but the subject might be something other
than companies – could be governments, geographical areas, or whatever else. It's
more of an idea than a reality thus far, but we're trying to organizing code to help 
us approach that reality, and these mods are moving us in that direction. The idea is 
that some day these would all be made into gems and shared.
2. mods prefixed with **wikirate_**. This code is very narrowly 
WikiRate-specific and is unlikely to be very useful to others, so we're not likely to
share it.
3. more broadly useful mods. Mods like `guides` and `posts` are likely to be useful
to other decko users, and not just those creatings sites that follow the DeckoRate 
pattern. We will soon move them to `card-mods`.
4. todos. other mods don't really fit neatly into any of these categories and need to 
refactored until they do.

The [mod page on docs.decko.org][8] has details about mods' subdirectory structure
and is a good place to start if you're learning to be a Decko monkey.


Setting up a Development Environment
====================================

The following will help set up a functioning wikirate site with a small subset of 
(mostly fake, largely silly) WikiRate data.

### 1. Install basic dependencies
First, you will need to install 
[Decko dependencies](https://github.com/decko-commons/decko#1-install-dependencies),
including ruby, bundler, ImageMagick, MySQL, and a JavaScript runtime.

### 2. Get code from GitHub
Then you will need to make your own fork of the 
[WikiRate GitHub repository][7]. Each WikiRate
developer maintains their own fork so they can make pull requests from that fork. For
example, Ethan's fork is at https://github.com/ethn/wikirate.

If you don't already have a GitHub account, start by signing up. If you're logged in, 
you can fork by clicking the "Fork" button in the upper right hand corner of the
[repo page][7].

Now we pull that code down to our computers.

    git clone git@github.com:YOURNAME/wikirate.git

At this point we have the main wikirate repo, but there's a lot more code we need in
nested repositories, which git calls _submodules_.  The following command will pull down
the latest submodules, including the _decko_, _card-mods_, and others that we don't 
maintain.

    cd wikirate
    git submodule update -f --init --recursive


### 3. Install ruby gems
Nearly all ruby developers these days use a beloved gem management tool called _bundler_.
Bundler defines the "bundle" of gems you need for your application. "bundle install" will
install all those gems.

    bundle install

Pay close attention to any error messages. Some gems may have additional dependencies
that need to be installed or identified for the bundle installation to complete
successfully.

### 4. Add configurations

Each copy of the Wikirate site can have different configuration options for its own 
purposes. The production site, for example, is configured to store files and images
on the cloud, but by default your local test site will just store files locally.
Since the main config files are not shared (and often contain private credentials),
they are not tracked in git. However, you must have these files in place for your site to
function, so you can start by copying over a sample set:

    cp -R config/sample/* config

These configurations should typically work out of the box, but at some point you may 
wish to change:

- **config/database.yml** for unusual database configs
- **config/application.rb** to change most other configurations
- **config/environment/[environment].rb** for configurations that only apply to certain 
environments (test, development, production, etc.).

### 5. Seed and serve

Now we seed the database with our silly data and start the server:

    env RAILS_ENV=test bundle exec decko setup
    bundle exec decko server

You should now be able to access a copy of your site at http://localhost:3000. You can
log into the test data with:
  
  - joe@user.com  / joe_pass, or
  - joe@admin.com / joe_pass



Updating your code
==================

To get the latest code you will need to do the following:

```
git pull                             # pull the latest wikirate/wikirate code
git submodule update -f --recursive  # update the nested git repositories
bundle update                        # get the latest gems 
bundle exec decko update             # run migrations and install mods
```


Testing
=========

Running Tests
----
All tests required a populated test database

    bundle exec rake decko:seed:replant

### RSpec

We use [RSpec](https://rspec.info/) for unit and functional ruby tests. 

    bundle exec decko rspec                          # full syntax
    bundle exec decko rs                             # shortcut
    bundle exec decko rs -- /my/file/is/here_spec.rb # runs a specific test

Tests are found in the `spec` dir of most mods.

### Cypress

[Cypress](https://www.cypress.io/) is our preferred tool for integration tests. To get
it running, you will need to install node

Typically you will want two different shells active for cypress testing: one for a server

    RAILS_ENV=cypress bundle exec decko server -p 5002

...and another for running the tests

    yarn install
    yarn run cypress run

Tests are found in the `spec/cypress` dir within mods.

### Cucumber

We've been slowly moving away from [cucumber](https://cucumber.io/) in favor of cypress, 
but we still have some cucumber tests.

    bundle exec decko cucumber
    bundle exec decko cc          # shortcut

Tests are found in the `features` dir within mods.


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
