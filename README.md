Wagn application code used at Wikirate.org

Steps to make it work
=========

1. create folders "files","config","public" and "public/assets" under the wikirate root directory.
2. rake wagn:create
3. import the database
4. bundle exec wagn s



Steps to rspec test
=========

1. create a user call joe_user(maybe you need a joe_admin). You may create in the webpage.
2. run the following command in console
```sh
 wagn rspec
```
