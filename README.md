# ansible-silpion

Baseline configuration for all nodes managed at Silpion.

## TODOs

- Finalize integration testing with Docker
    - Research for existing Gems to replace code in Ruby libraries
    - Fixup possible issues in Ruby libraries for ``rake spec``
    - Provide useful error handling in Ruby libraries for ``rake spec``
- Provide documentation to install Ruby with rbenv
    - Provide documentation to install required Gems with rbenv
- Provide documentation how to integrate roles into existing CI systems
- Provide a utility (as a Ruby gem) to install boilerplates for TDD

## Requirements

- Generation of pre-hashed root password for variable ``silpion_root_password``.

### Pre-hash root password

To cerate a SHA 512 hash suitable for the Ansible user module to configure
a users password pre-hashed there is the `pre-hash-passwd` script in `tools`
directory.
This requires python2 und the passlib modules to be installed.

The following Python snippet creates a pre-hashed password:

    python2 -c 'from passlib.hash import sha512_crypt; print(sha512_crypt.encrypt("<PASSWORD>"))'

## Role Variables

* ``silpion_root_password``: sha512 pre-hashed password for the root user (default: '')
* ``silpion_package_list_in_custom``: List of custom packages to be installed (default: ``[]``)

### ansible_os_family == 'Debian'

* ``silpion_apt_proxy_enable``: Enable or disable an APT proxy (default: ``true``)
* ``silpion_apt_proxy_url``: Configure the APT proxy url (default: ``http://apt-proxy.silpion.de:9999``)

### ansible_os_family == 'RedHat'

* ``silpion_yum_erase_fastestmirror``: Get rid of the yum "fastestmirror" plugin (default: ``true``) (**NOT IN USE**)
* ``silpion_epel_version``: EPEL version to use (default: ``6``)
* ``silpion_epel_baseurl``: EPEL repository base url (default: ``http://download.fedoraproject.org/pub/epel``)
* ``silpion_epel_mirrorurl``: EPEL repository mirror url (default: ``https://mirrors.fedoraproject.org/metalink``)
* ``silpion_epel_enable_debug``: Enable or disable EPEL debug repository (default: ``false`` (disabled))
* ``silpion_epel_enable_source``: Enable or disable EPEL source repository (default: ``false`` (disabled))

## Dependencies

None.

## Example playbook

    - hosts: servers
      vars:
        - silpion_root_password: "$6$$424Wd1I7Zf08UNjZ87zCI7CqSLDPJsmYixRJnsyXsavYUWpikshjobn8rbFAWU6cx/CzBkuaSteiZKhQj/0ia0"
      roles:
        - { role: silpion }

## License

Apache Version 2.0

## Integration testing

This role provides integration tests using the Ruby RSpec/serverspec framework
with a few drawbacks at the time of writing this documentation.

- Currently supports ansible_os_family == 'Debian' only.

Running integration tests requires a number of dependencies being
installed. As this role uses Ruby RSpec there is the need to have
Ruby with rake and bundler available.

    # install role specific dependencies with bundler
    bundle install

<!-- -->

    # run the complete test suite with Docker
    rake suite

<!-- -->

    # run the complete test suite with Vagrant
    RAKE_ANSIBLE_USE_VAGRANT=1 rake suite


## Author information

Mark Kusch @mark.kusch silpion.de


<!-- vim: set nofen ts=4 sw=4 et: -->
