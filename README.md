# ansible-silpion

Baseline configuration for all nodes managed at Silpion.

## Requirements

- Generation of pre-hashed root password.

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
      roles:
        - { role: silpion, silpion_root_password: '<pre-hashed-sha512-password>' }

## License

Apache Version 2.0

## Author information

Mark Kusch @mark.kusch silpion.de


<!-- vim: set nofen ts=4 sw=4 et: -->
