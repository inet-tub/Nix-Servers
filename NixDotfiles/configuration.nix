# configuration in this file is shared by all hosts

{ pkgs, pkgs-unstable, inputs, ... }:
let inherit (inputs) self;
in {

  # Safety mechanism: refuse to build unless everything is tracked by git
  system.configurationRevision = if (self ? rev) then
    self.rev
  else
    throw "refusing to build: git tree is dirty";

  # NixOS Setup
  system.stateVersion = "23.05";
  boot.zfs.forceImportRoot = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  # Don't build man pages. This saves a *lot* of time when rebuilding
  documentation.man.generateCaches = false;

  # TODO: Enable automatic snapshots
  services.zfs = {
    autoSnapshot = {
      enable = false;
      flags = "-k -p --utc";
      monthly = 48;
    };
  };

  # Programs

  security.sudo.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

    fish.enable = true;
    git.enable = true;
  };


  # TODO: Migrate this away?
  users.users = {
    root = {
      initialHashedPassword = "rootHash_placeholder";
      openssh.authorizedKeys.keys = [ "sshKey_placeholder" ];

      shell = pkgs.fish;
    };
  };

  users.groups = {
    postgres.members = [ "postgres" ];
    hedgedoc.members = [ "hedgedoc" ];
    vaultwarden.members = [ "vaultwarden" ];
    mail.members = [ "mail" ];
    youtrack.members = [ "youtrack" ];
  };


  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.x86_64-linux.default

    jq
    wget
    zsh
    neofetch
    btop
    exa
    cowsay
    direnv
    htop
    rsync
    nmap
    inetutils
    python3
    groff
    openssl
    tcpdump
    traceroute
    sysstat
    pv

  ];


}
