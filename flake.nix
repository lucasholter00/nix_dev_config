{
  description = "Home Manager configuration of lucasholter";

  inputs = {
    nvimConfig = {
        url = "github:lucasholter00/barebones-nvim";
        flake = false;
    };
    direnv-instant.url = "github:Mic92/direnv-instant";
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."lucasholter" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit inputs;};

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ 
            ./home.nix 
            ./homeManagerModules
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
