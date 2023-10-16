String? checkDistro(String uname) {
  final distros = [
    'Ubuntu',
    'Debian',
    'Fedora',
    'CentOS',
    'Arch',
    'Manjaro',
    'openSUSE',
    'SUSE',
    'Gentoo',
    'Slackware',
    'Alpine',
    'Raspbian',
    'Kali',
    'LinuxMint',
    'ElementaryOS',
    'PopOS',
    'ZorinOS',
    'Solus',
    'Void',
    'NixOS',
    'ClearLinux',
    'ParrotOS',
    'MXLinux',
    'Deepin',
    'Mageia',
    'EndeavourOS',
    'ArcoLinux',
    'MX Linux',
    'Mint',
    'EndeavourOS',
    'Debian',
    'Manjaro',
    'Ubuntu',
    'Pop!_OS',
    'Fedora',
    'openSUSE',
    'Lite',
    'Zorin',
    'Garuda',
    'KDE neon',
    'antiX',
    'elementary',
    'Mageia',
    'Nobara',
    'Kali',
    'PCLinuxOS',
    'Puppy',
    'Vanilla',
    'AlmaLinux',
    'SparkyLinux',
    'ArcoLinux',
    'EasyOS',
    'NixOS',
    'Q4OS',
    'Alpine',
    'FreeBSD',
    'CachyOS',
    'Peppermint',
    'blendOS',
    'Voyager',
    'Bodhi',
    'Devuan',
    'Kubuntu',
    'Gnoppix',
    'TUXEDO',
    'Solus',
    'Lubuntu',
    'Tails',
    'SmartOS',
    'Bluestar',
    'OpenMandriva',
    'Rocky',
    'Slackware',
    'Regata',
    'Archcraft',
    'XeroLinux',
    'PureOS',
    'Parrot',
    'CentOS',
    'Xubuntu',
    'Linuxfx',
    'siduction',
    'Gentoo',
    'Murena',
    'Red Hat',
    'Photon',
    'Clear',
    'Neptune',
    'Qubes',
    'EuroLinux',
    'KaOS',
    'Tiny Core',
    'Arch',
    'Athena',
    '4MLinux',
    'Mabox',
    'TrueNAS',
    'wattOS',
    'ReactOS',
    'Artix',
    'deepin',
    'Endless',
    'MakuluLinux',
    'RebornOS',
    'Void',
    'Archman',
    'Proxmox',
    'Ubuntu MATE',
    'GhostBSD',
    'ALT',
    'ExTiX',
    'Nitrux',
    'Feren',
    'Fatdog64',
    'Oracle',
    'OpenBSD',
    'ROSA',
    'Emmabuntüs',
    'LXLE',
    'Ubuntu Studio',
    'Absolute',
    'Gecko',
    'Haiku',
    'Kodachi',
    'Peropesis',
    'NuTyX',
    'Spiral',
    'KDE neon',
    'NetBSD',
    'raspi',
  ];

  for (final distro in distros) {
    if (uname.contains(distro)) {
      return distro;
    }
  }

  return null;
}
