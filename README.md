driebit/puppet-zotonic
====================

Introduction
------------

This Puppet module installs and configures [Zotonic](http://zotonic.com/).

Usage
-----

### Install Zotonic

```puppet
class { 'zotonic': }
```

Customise as follows:

```puppet
class { 'zotonic':
  password            => '',                 # admin password
  listen_port         => '8000',             # Zotonic port
  dir                 => '/opt/zotonic',     # Installation directory
  version             => 'release-0.10.0p1', # Version to install
  user                => 'zotonic',          # User that owns Zotonic
  db_name             => 'zotonic',          # PostgreSQL database for Zotonic
  db_username         => 'zotonic',          # PostgreSQL username for Zotonic
  db_password         => '',                 # PostgreSQL password for Zotonic
  db_host             => 'localhost',        # PostgreSQL host
  db_port             => 5432,               # PostgreSQL port
  erlang_package      => 'erlang',           # Erlang package name
  imagemagick_package => ''                  # ImageMagick package name (a Zotonic dependency)
}
```

### Install modules

To install modules from the [Zotonic Module Repository](http://modules.zotonic.com/):

```puppet
zotonic::module { 'mod_geo': }
```

You can also install unofficial modules from any Git repository:

```puppet
zotonic::git_module { 'mod_awesome':
  module_dir => '/zotonic/modules',   # Defaults to priv/modules in Zotonic dir
  url        => 'https://github.com/driebit/mod_import_anymeta.git',   # Git repo URL
  version    => 'master'
}
```

### Add a site to Zotonic

You can add a site to your Zotonic setup with:

```puppet
zotonic::site { 'mysite':
  dir => '/home/me/mysite'   # Directory that contains the site
}
```

This will:
* set up PostgreSQL for the site
* create a site config in `/home/me/mysite/config.d/`
* create a symlink from the Zotonic sites dir to your site’s directory.

Customise as follows:

```puppet
zotonic::site { 'mysite':
  dir            => '/home/me/mysite',
  admin_password => 'admin',  # Administrator password (defaults to admin)
  db_name        => undef,    # PostgreSQL database for the site (defaults to Zotonic database)
  db_user        => undef,    # PostgreSQL user for the site (defaults to Zotonic username)
  db_password    => undef,    # PostgreSQL password for the site (defaults to Zotonic password)
  db_schema      => 'public', # PostgreSQL schema for the site (defaults to public)
  hostname       => undef,    # Site hostname (defaults to sitename.fqdn)
  config_file    => 'puppet'  # Config file that will be placed in $dir/config.d,
}
```
