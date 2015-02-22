# Class: motd
#
# Borrowed from https://github.com/ripienaar/puppet-concat
#
class motd (
  $enable_ascii_art = false,
  $ascii_art_text = $::fqdn,
  $ascii_art_font = 'graffiti',
  $manage_gem  = true,
  $motd_file   = '/etc/motd',
  $fact_list   = [$fqdn, $ipaddress, $whereami]
  ){
  if str2bool($manage_gem) and str2bool($enable_ascii_art) {
    $gem_provider = str2bool($::is_pe) ? {
      true    => 'pe_gem',
      false   => 'gem',
      default => 'gem',
    }
    package { 'artii':
      ensure   => present,
      provider => $gem_provider,
      before   => Concat[$motd_file],
    }
  }

  concat { $motd_file:
    owner => 'root',
    mode  => '0644',
  }

  concat::fragment { 'motd_header':
    target  => $motd_file,
    content => template('motd/motd.erb'),
    order   => '02',
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
