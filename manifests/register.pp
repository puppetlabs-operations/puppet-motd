# used by other modules to register themselves in the motd
define motd::register($content=undef, $order=10) {
  include motd

  if $content == undef {
    $body = $name
  } else {
    $body = $content
  }

  concat::fragment{"motd_fragment_${name}":
    target  => '/etc/motd',
    content => "    -- ${body}\n"
  }
}

