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
    order   => '02',
  }

  # local users on the machine can append to motd by just creating
  # /etc/motd.local
  concat::fragment{ 'motd_local':
    ensure  => '/etc/motd.local',
    target  => '/etc/motd',
    order   => '15',
  }

  # Place our custom /etc/issue
  file { '/etc/banner':
    ensure => 'present',
    source => 'puppet:///modules/motd/banner.txt',
    owner  => 'root',
    mode   => '0644',
  }

  case $::operatingsystem {
    'CentOS': {
      augeas { 'enable_motd_postlogin':
        context => '/files/etc/pam.d/postlogin',
        changes => [
          'ins 1000000 after *[last()]',
          'set 1000000/type session',
          'set 1000000/control optional',
          'set 1000000/module pam_motd.so',
        ],
        onlyif  => "match *[module = 'pam_motd.so'] size == 0",
      }

      augeas { 'remove_duplicate_motd_postlogin':
        context => '/files/etc/pam.d/postlogin',
        changes => [
          'rm *[last()]',
        ],
        onlyif  => "match *[module = 'pam_motd.so'] size > 1",
      }
    }
  }
}
