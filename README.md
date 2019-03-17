# puppet-yamlresource

[![Build Status](https://travis-ci.org/ffrank/puppet-yamlresource.svg?branch=master)](https://travis-ci.org/ffrank/puppet-yamlresource)

A puppet face similar to `puppet resource`, with the ability to accept structured data for input.

# Motivation

The `puppet resource` command is very useful to manage single resources without the overhead of
writing it in manifest form, and running the catalog builder. However, it can only accept a
limited subset of Puppet's supported attribute values. For example:

```puppet
cron { 'renew-lease':
  ensure => present,
  command => '/usr/local/bin/renew-lease',
  user => 'root',
  minute => 10,
  hour => 13,
}
```

This resource can be applied a little more simply with the following command:

    puppet resource cron renew-lease ensure=present command=/usr/local/bin/renew-lease user=root minute=10 hour=13

Now consider the following change:

```puppet
cron { 'renew-lease':
  # ...
  hour => [ 1, 13 ],
}
```

This resource cannot be represented in `puppet resource` syntax, because array values like
`[ 1, 13 ]` are not recognized.

With `puppet yamlresource`, you can use the following command:

    puppet yamlresource cron renew-license \
        '{ ensure: present, command: /usr/local/bin/renew-lease, user: root, minute: 10, hour: [ 1, 13 ], }'

Note that the attributes are actually passed in a JSON-like syntax, but that's fine because JSON is valid YAML,
and YAML even gives you a lot of freedom, such as optional quotes, trailing commas etc.

# Installation

    puppet module install ffrank-yamlresource

# Usage

## From the command line

1. List all resources of a given type

        puppet yamlresource cron

2. Show a YAML representation of a distinct resource

        puppet yamlresource cron renew-lease

3. Manage the state of a single resource


        puppet yamlresource cron renew-lease '<YAML data>'

## Through the Ruby API

The functionality is available through Puppet's *faces* API. Documentation is yet to be created.

## Receive mode

Receive mode gives Puppet greater utility as a worker back-end for other software.

The `puppet yamlresource receive` subcommand takes no other parameters. When invoked,
Puppet starts reading resource descriptions from the command line. It tries and applies
each of these resources. It always prints one line of JSON in return. Any errors
are reported in this JSON structure.

This is a typical, successful interaction with the running instance of `yamlresource receive`:

```
file /tmp/x { ensure: file }
{"resource":"File[/tmp/x]","failed":false,"changed":true,"noop":false,"error":false,"exception":null}
```

Issues are indicated through the `error` and `exception` fields:

```
file /tmp/y { parameters: many }
Error: (Applying File[/tmp/z]) no parameter named 'parameters'
{"failed":true,"changed":false,"error":true,"exception":"no parameter named 'parameters'"}
```

This input format only works for resources without spaces in the resource title. A more
robust input format is also JSON (wrapping the YAML parameters in a string):

```
{"type":"file", "title":"/tmp/z", "params":"{ ensure: file }"}
{"resource":"File[/tmp/z]","failed":false,"changed":true,"noop":false,"error":false,"exception":null}`
```

This is quite cumbersome on the shell, but more reliable when integrating
other software.
