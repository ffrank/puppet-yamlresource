# puppet-yamlresource

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
