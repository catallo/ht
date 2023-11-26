import 'package:ht/globals.dart';
import 'dart:io';

void gatherSystemInfo() {
  os = Platform.operatingSystem;
  //print("os: $os");

  var out = Process.runSync('uname', ['-a']);
  uname = out.stdout.toString().trim();
  //print("uname: $uname");

  if (Platform.isMacOS) {
    distro = "Darwin";
  } else {
    distro = checkDistro(uname) ?? "Debian derivate";
  }

  //print("distro: $distro");

  // works only for system default shell, not actual shell
  shell = Platform.environment['SHELL']!;
  shell = shell.substring(shell.lastIndexOf('/') + 1);

  //print("shell: $shell");
}

// Following function uses a list to identify the distribution by checking if any
// of these names appear as a substring in the output of the 'uname' command. This
// approach seems to be necessary because surprisingly there is no standardized
// way across all Linux distributions to reliably and directly obtain the distribution
// name. The 'uname' command's outputvaries significantly among distributions, and
// often the distribution name is part of a longer string, hence the substring checking.
// If you know a better way, please let me know.

String? checkDistro(String uname) {
  final Set<String> distros = {
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
    'Pop!_OS',
    'Lite',
    'Zorin',
    'Garuda',
    'KDE neon',
    'antiX',
    'elementary',
    'Nobara',
    'PCLinuxOS',
    'Puppy',
    'Vanilla',
    'AlmaLinux',
    'SparkyLinux',
    'EasyOS',
    'Q4OS',
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
    'Lubuntu',
    'Tails',
    'SmartOS',
    'Bluestar',
    'OpenMandriva',
    'Rocky',
    'Regata',
    'Archcraft',
    'XeroLinux',
    'PureOS',
    'Parrot',
    'Xubuntu',
    'Linuxfx',
    'siduction',
    'Murena',
    'Red Hat',
    'redhat',
    'Photon',
    'Clear',
    'Neptune',
    'Qubes',
    'EuroLinux',
    'KaOS',
    'Tiny Core',
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
    'Archman',
    'Proxmox',
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
    'Absolute',
    'Gecko',
    'Haiku',
    'Kodachi',
    'Peropesis',
    'NuTyX',
    'Spiral',
    'NetBSD',
    'raspi',
  };

  uname = uname.toLowerCase();
  for (final distro in distros) {
    if (uname.contains(distro.toLowerCase())) {
      return distro;
    }
  }

  return null;
}
