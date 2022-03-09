# WikiRate server installation

### Latest installation: kasper, Feb 2022

Working from Ubuntu 20.04

__NOTE__: this is not a comprehensive guide. just a bunch of helpful guideposts.

set up hostname
```
vi /etc/hostname
hostname -F /etc/hostname
vi /etc/hosts  # add other servers
```


install standard packages: (these are on top of Hetzner's "minimal" ubuntu install)
```
apt update
apt dist-upgrade

apt install \
    build-essential locate dnsutils git zsh vim \
    ruby ruby-dev ruby-bundler \
    mysql-server mysql-client automysqlbackup libmysqlclient-dev \
    apache2 libapache2-mod-xsendfile python3-certbot-apache certbot \
    nodejs npm \
    memcached imagemagick libcurl4-openssl-dev libxrender1 
   
```

install passenger packages, see: https://www.phusionpassenger.com/library/install/apache/install/oss/bionic/



## Users / Groups / Permissions
```
adduser X  # deploy user and admin users
groupadd wikirate
```
### change shell if desired
```
usermod --shell /bin/zsh X
```
### add to group
```
usermod -aG adm X       # all admin
usermod -aG sudo X      # all admin
usermod -aG wikirate X  # all admin + deploy
usermod -aG www-data X  # all admin + deploy
```

### make primary group
```
usermod -g wikirate X   # all admin + deploy
```
### set up ssh
```
ssh-keygen -t ecdsa -b 521
```

 


## MySQL config

improve security defaults
```
sudo mysql_secure_installation
```

set up mysql user
```
CREATE USER IF NOT EXISTS 'wikirate'@'localhost';
# (have to give it password and grant privileges.  can't keep it all here, but I used
# pt-show-grants on johannes to refer to existing
```

update config files
```
sudo vi mysql.conf.d/mysqld.cnf
```
make sure appropriate values for:

* innodb_buffer_pool_size 
* innodb_buffer_pool_instances
* join_buffer_size


## Apache config
```
sudo vi /etc/apache2/apache2.conf
```
therein:
- uncomment /srv permissions and
- add `ServerName localhost`


enable mods
```
sudo a2enmod headers
sudo a2enmod ssl
sudo a2enmod rewrite
sudo a2enmod expires
sudo a2enmod xsendfile
sudo a2enmod proxy_http  # for docs.decko
```

copy certs to `/etc/letsencrypt` and sites to `/etc/apache2/sites-available`

## Other
### memcached config
```
sudo vi /etc/memcached.conf
```
change -m
> -m 4096


### logrotation

```
mkdir /var/log/decko # will have to set permissions
sudo vi /etc/logrotate.d/decko 
```
add:

``` 
/var/log/decko/*.log {
   daily
   su www-data wikirate
   missingok
   rotate 14
   compress
   delaycompress
   notifempty
   copytruncate
}
```
### mysql backups

```
sudo vi /etc/default/automysqlbackup
```
* `CREATE_DATABASE=no` (because we use the same database with different names: dev, demo, etc)

### deployment permissions

```
sudo visudo
```
Using visudo, add the following below root. (Makes it so deploy user can set the correct
permission on config.ru files but does not over-empower it)

> deploy  ALL=(ALL) NOPASSWD:/usr/bin/chown www-data config.ru
 
(do NOT put deploy user in sudo group!).

### might need to update node?

https://askubuntu.com/questions/426750/how-can-i-update-my-nodejs-to-the-latest-version