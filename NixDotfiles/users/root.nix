{ pkgs, config, lib, inputs, ... }: {
  security.sudo.enable = true;

  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  services.locate.enable = true;

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

    fish.enable = true;
    git.enable = true;
  };

  users.users = {
    root = {
      initialHashedPassword = "rootHash_placeholder";  # We have to allow password login in case ssh breaks
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND9kUmAEwH+qD6T+Gs/G83SA/oyIzpz1Zj4oMAkOvhO emily"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIN0lWZxVSad9z6dZKFqiL3QbQMf7KbDecte3hLsK5jP darwin@rumo"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICw1IrnMe/oOPDK6RmDazEnqwQjHG7ym3sRs7azaRvyc darwin@hammond"
      ];

      shell = pkgs.fish;
    };
  };

  environment.systemPackages = with pkgs; [
    sudo
    jq
    wget
    fish
    zsh
    neofetch
    btop
    eza
    cowsay
    direnv
    htop
    rsync
    nmap
    inetutils
    util-linux
    parted
    python3
    groff
    openssl
    tcpdump
    traceroute
    dig
    sysstat
    pv
    du-dust
    ripgrep
    unzip
    unzrip
    urbackup-client
  ];
}
