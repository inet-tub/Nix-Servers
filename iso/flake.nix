{
  description = "Custom NixOS installation media";
  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-24.05";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.darwin.follows = "";
    };
  };

  outputs = { self, nixos, agenix }@inputs: {
    nixosConfigurations = {
      inetInstaller = nixos.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };

        modules =
        [
          "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./configuration.nix
        ];
      };
    };
  };
}