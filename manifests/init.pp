# Class: motd
#
# Borrowed from https://github.com/ripienaar/puppet-concat
#
class motd {
  include concat::setup

  concat{ '/etc/motd':
    owner => 'root',
    mode  => '0644',
  }

  concat::fragment{ 'motd_header':
    target  => '/etc/motd',
    content => template('motd/motd.erb'),
    order   => 02,
  }

  # local users on the machine can append to motd by just creating
  # /etc/motd.local
  concat::fragment{ 'motd_local':
    ensure  => '/etc/motd.local',
    target  => '/etc/motd',
    order   => 15,
  }

  # Place our custom /etc/issue
  file { '/etc/banner':
    ensure => 'present',
    source => 'puppet:///modules/motd/banner.txt',
    owner  => 'root',
    mode   => '0644',
  }
}
