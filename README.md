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

To create a SHA 512 hash for a password use the following Pyhton snippet:

    python -c 'import crypt; print(crypt.crypt("<PASSWORD>", "$6$"))'

## Role Variables

* ``silpion_root_password``: sha512 pre-hashed password for the root user (default: '')
* ``silpion_package_list_in_custom``: List of custom packages to be installed (default: ``[]``)

### ansible_os_family == 'Debian'

* ``silpion_apt_proxy_enabled``: Enable or disable an APT proxy (default: ``true``)
* ``silpion_apt_proxy_url``: Configure the APT proxy url (default: ``http://apt-proxy.silpion.de:9999``)

### ansible_os_family == 'RedHat'

* ``silpion_yum_erase_fastestmirror``: Get rid of the yum "fastestmirror" plugin (default: ``true``)

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
with a number of drawbacks at the time of writing this documentation.

- Currently supports ansible_os_family == 'Debian' only.
- Integration testing with Vagrant is extremely slow.
- Integration testing with Docker solves Vagrant performance issues.
    - There is no way to successfully test installed services with Docker (work in progress).

Running integration tests requires a number of dependencies being
installed. As this role uses Ruby RSpec there is the need to have
Ruby with rake and bundler available.

    # install dependencies with bundler
    bundle install

<!-- -->

    # run the complete test suite with Docker
    rake docker

<!-- -->

    # run the complete test suite with Vagrant
    rake vagrant


## Author information

Mark Kusch @mark.kusch silpion.de


<!-- vim: set nofen ts=4 sw=4 et: -->
