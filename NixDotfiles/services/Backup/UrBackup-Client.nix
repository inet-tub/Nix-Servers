{ pkgs, config, lib, ... }: {
  services.urbackup-client = {
    enable = true;
  };
}
