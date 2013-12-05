driebit/puppet-xhgui
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

Change installation directory:

```puppet
class { 'zotonic':
  dir => '/opt/zotonic'
}
```

Install a specific Zotonic version:

```puppet
class { 'zotonic':
  version => '0.9.4'
}
```

Set the admin password:

```puppet
class { 'zotonic':
  password => 'supersecret'
}
```

### Add a site

You can configure a Zotonic site with:

```puppet
zotonic::site { 'mysite': }
```

If you with to set up a new site, you may want to use Zotonic’s
[addsite command](http://zotonic.com/docs/latest/tutorials/install-addsite.html):

```bash
$ zotonic addsite -s blog mysite
```
