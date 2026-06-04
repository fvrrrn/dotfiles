{
  description = "NixOS config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    eden-flake.url = "github:ardishko/eden-flake";
  };
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    nixosConfigurations = {
      pc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          hostname = "pc";
        };
        modules = [
          inputs.sops-nix.nixosModules.sops
          ./hardware/pc/hardware-configuration.nix
          ./configuration.nix
          ./modules/network.nix
          ./modules/nvidia.nix
          ./modules/sing-box.nix
          ./modules/sshd.nix
          ./modules/syncthing.nix
          ./modules/llama.nix
          ./modules/eden.nix
        ];
      };
      t480 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          hostname = "t480";
        };
        modules = [
          inputs.sops-nix.nixosModules.sops
          ./hardware/t480/hardware-configuration.nix
          ./configuration.nix
          ./modules/network.nix
          ./modules/sing-box.nix
          ./modules/syncthing.nix
          ./modules/steam.nix
          ./modules/sshd.nix
        ];
      };
    };
  };
}
