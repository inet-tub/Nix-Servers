{ ... }: {
  imports = map (it: ../../services/${it}) [
    "Nginx.nix"
  ];
}
