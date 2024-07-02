{
  # TODO: flake-parts, systems, devenv

  description = "NixOS Server on ZFS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.darwin.follows = "";
    };
  };



  outputs = { self, nixpkgs, nixpkgs-unstable, agenix }@inputs:
    let
      mkHost = hostName: stateVersion: system:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            # By default, the system will only use packages from the stable channel.
            # You can selectively install packages from the unstable channel.
            # You can also add more  channels to pin package version.
            pkgs = import nixpkgs {
              inherit system;
#              overlays = [ (import ...) ];
              config.packageOverrides = pkgs: { vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; }; };
            };

            pkgs-unstable = import nixpkgs-unstable { inherit system; };
            pkgs-unfree = import nixpkgs { inherit system; config = { allowUnfree = true; }; };

            # make all inputs availabe in other nix files
            inherit inputs;
          };

          modules = [
            # Root on ZFS related configuration
            ./modules

            # Configuration shared by all hosts
            ./configuration.nix
            ./system.nix
            ./users/root.nix
            agenix.nixosModules.default

            # Configuration per host
            ./hosts/${hostName}
          ] ++ [{ system.stateVersion = stateVersion; }];
        };

    in
    {
      nixosConfigurations = {
        nixie = mkHost "nixie" "23.05" "x86_64-linux";
        en-backup = mkHost "en-backup" "23.11" "x86_64-linux";
        en-observertory = mkHost "en-observertory" "23.11" "x86_64-linux";
        en-mail = mkHost "en-mail" "23.11" "x86_64-linux";
        authentication = mkHost "authentication" "23.11" "x86_64-linux";
        admin = mkHost "admin" "23.11" "x86_64-linux";
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
