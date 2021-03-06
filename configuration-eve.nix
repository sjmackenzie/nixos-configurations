# Edit this configuration file which defines what would be installed on the
# system.  To Help while choosing option value, you can watch at the manual
# page of configuration.nix or at the last chapter of the manual available
# on the virtual console 8 (Alt+F8).

{ pkgs, ... }:

{
  require = [
    ./hardware.nix
    ./intel-xts-luksroot-sda.nix
    ./filesystems-boot-root-tmptmpfs.nix
    ./nobeep.nix
  ];

  boot = {
    extraModprobeConfig = ''
      options thinkpad_acpi fan_control=1
    '';
    initrd.luks.enable = true;
    initrd.luks.devices = [ { name = "luksroot"; device = "/dev/sda3"; } ];
    # powertop needs msr and so far it does not load when needed
    kernelModules = [ "msr" ];
    kernelPackages = pkgs.linuxPackages_3_6;
    # major:minor number of my swap device, fully lvm-based system
    #resumeDevice = "254:1";
  };

  environment = {
    # To also get the header files in the system environment. You only need
    # this if you want compile non-nixos stuff against the system environment.
    # You would only want that as a part of temporary solution to continue on
    # whatever you were working before christmas. However, there are better
    # ways. See https://github.com/chaoflow/nixos-configurations for more on
    # that.
    #pathsToLink = ["include"];

    # shellInit = ''
    #   export GEM_PATH=/var/run/current-system/sw/${pkgs.ruby.gemPath}
    #   export RUBYLIB=/var/run/current-system/sw/lib
    #   export RUBYOPT=rubygems
    # '';

    # XXX: still not sure when it is better to put a package here and when to
    # use the default profile.
    systemPackages = with pkgs; [
      acpitool
      alsaLib
      alsaPlugins
      alsaUtils
      ant
      aumix
      autoconf
      automake
      bazaar
      bazaarTools
      bc
      beret
      cmake
      colordiff
      cpufrequtils
      cryptsetup
      cvs
      cvsps
      ddrescue
      dmenu
      dosbox
      emacs24
      emacs24Packages.bbdb
      emacs24Packages.calfw
      emacs24Packages.haskellMode
      emacs24Packages.js2
      emacs24Packages.notmuch
      emacs24Packages.org
      file
      gcc
      gdb
      geeqie
      ghostscript
      gimp
      gitAndTools.gitFull
      gitAndTools.qgit
      gitAndTools.svn2git
      gitAndTools.tig
      gnupg
      gnupg1
      gnumake
      gperf
      graphviz
      guile
      haskellPackages.ghc
      haskellPackages.haskellPlatform
      hdparm
      htop
      imagemagick
      io
      irssi
      jdkPlugin
      jscoverage
      jwhois
      keychain
      links2
      lsof
      lua5
      lxdvdrip
      lynx
      mailutils
      man
      mdbtools
      mercurial
      mjpegtools
      ncftp
      netcat
      nmap
      nodejs
      offlineimap
      openvpn
      p7zip
      parted
      pdfjam
      pdftk
      pinentry
      powertop
      pulseaudio
      pwgen
      pythonFull
      pythonPackages.ipython
      qrencode
      rLang
      rtorrent
      ruby
      screen
      sdparm
      stdmanpages
      subversion
      tcpdump
      telnet
      texLive
      units
      unrar
      unzip
      vde2
      vim
      vlc
      w3m
      wget
      zip
      zsh
    ];
    x11Packages = with pkgs; [
      chromeWrapper
      conkeror
      crack_attack
      firefoxWrapper
      gv
      glxinfo
      haskellPackages.xmonad
      haskellPackages.xmonadContrib
      haskellPackages.xmonadExtras
      inkscape
      kicad
      kde4.kruler
      kde4.kwallet
      MPlayer
      rxvt_unicode
      qemu_kvm
      rdesktop
      scrot
      scummvm
      stalonetray
      unetbootin
      wine
      wireshark
      wpa_supplicant_gui
      xfontsel
      xlibs.xev
      xlibs.xinput
      xlibs.xmessage
      xlibs.xmodmap
      xlockmore
      xmoto
      xorg.xkill
      xpdf
      xulrunner
      zathura
    ];
  };

  # XXX: add more fonts!
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;

    # terminus I use for rxvt-unicode
    # see https://github.com/chaoflow/chaoflow.skel.home/blob/master/.Xdefaults
    extraFonts = [
       pkgs.terminus_font
    ];
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  networking = {
    domain = "chaoflow.net";
    # hardcode domain name
    # extraHosts = ''
    #   127.0.0.1 eve.chaoflow.net eve
    # '';
    firewall = {
      allowedTCPPorts = [ 80 ];
      enable = true;
    };
    hostName = "eve";
    interfaceMonitor.enable = false; # Watch for plugged cable.
    # host network for qemu-kvm
    localCommands = ''
      ${pkgs.vde2}/bin/vde_switch -tap tap0 -mod 660 -group kvm -daemon
      ip addr add 10.0.0.1/24 dev tap0
      ip link set dev tap0 up
      ${pkgs.procps}/sbin/sysctl -w net.ipv4.ip_forward=1
      ${pkgs.iptables}/sbin/iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -j MASQUERADE
    '';
    wireless.enable = true;
    wireless.driver = "nl80211";
    wireless.interfaces = [ "wlan0" ];
    wireless.userControlled.enable = true;
  };

  nix.extraOptions = ''
    gc-keep-outputs = true
    gc-keep-derivations = true
  '';
  nix.useChroot = true;

  # XXX: unused so far
  nixpkgs.config = {
    xkeyboard_config = { extraLayoutPath = "./xkb-layout/chaoflow"; };
  };

  powerManagement.enable = true;
  powerManagement.aggressive = true;

  users.defaultUserShell = "/var/run/current-system/sw/bin/zsh";

  security.pam.loginLimits = [
    { domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
  ];

  services.atd.enable = false;
  services.httpd = {
    adminAddr = "flo@chaoflow.net";
    enable = false;
    enableUserDir = true;
  };
  services.locate.enable = true;
  services.nixosManual.showManual = false;
  services.openssh.enable = true;
  services.printing.enable = true;
  services.postfix = {
    destination = [ "localhost" "eve.chaoflow.net" ];
    enable = true;
    extraConfig = ''
      # For all options see ``man 5 postconf``
      # Take care, empty lines will mess up whitespace removal.  It would be
      # nice if empty lines would not be considered in minimal leading
      # whitespace analysis, but don't know about further implications.  Also
      # take care not to mix tabs and spaces. Should tabs be treated like 8
      # spaces?
      #
      # ATTENTION! Will log passwords
      #debug_peer_level = 4
      #debug_peer_list = tesla.chaoflow.net
      inet_interfaces = loopback-only
      #
      # the nixos config option does not allow to specify a port, beware:
      # small 'h' in contrast to the config option with capital 'H'
      relayhost = [tesla.chaoflow.net]:submission
      #
      #XXX: needs server certificate checking
      #smtp_enforce_tls = yes
      #
      # postfix generic map example content:
      #   user@local.email user@public.email
      # Run ``# postmap hash:/etc/nixos/cfg-private/postfix_generic_map``
      # after changing it.
      smtp_generic_maps = hash:/etc/nixos/cfg-private/postfix_generic_map
      smtp_sasl_auth_enable = yes
      smtp_sasl_mechanism_filter = plain, login
      #
      # username and password for smtp auth, example content:
      #  <relayhost> <username>:<password>
      # The <relayhost> is exactly what you specified for relayHost, resp.
      # relayhost.
      smtp_sasl_password_maps = hash:/etc/nixos/cfg-private/postfix_passwd
      smtp_sasl_security_options = noanonymous
      smtp_sasl_tls_security_options = $smtp_sasl_security_options
      smtp_use_tls = yes
    '';
    hostname = "eve.chaoflow.net";
    origin = "eve.chaoflow.net";
    postmasterAlias = "root";
    rootAlias = "cfl";
  };
  services.ttyBackgrounds.enable = false;
  services.xserver = {
    autorun = true;
    # no desktop manager, no window manager configured here. This
    # results in only one session *custom* for slim which executes
    # ~/.xsession. See:
    # https://github.com/chaoflow/chaoflow.skel.home/blob/master/.xsession
    desktopManager.xterm.enable = false;
    displayManager.slim = {
      defaultUser = "cfl";
      hideCursor = true;
    };
    enable = true;
    exportConfiguration = true;
    # custom is set in ./bin/init_keyboard.sh via .xsession with the
    # advantage of not breaking X in case the layout did not make it into the
    # newest profile generation
    layout = "us";
  };

  # List swap partitions that are mounted at boot time.
  #swapDevices = [{ label = "swap"; }];

  time.timeZone = "Europe/Berlin";

  # not supported with stock nixos yet
  trackpoint.sensitivity = "255";
}
