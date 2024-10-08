{
  inputs = {
    systems.url = "github:nix-systems/default-linux";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "nixpkgs";
  };

  outputs = {
    self,
    poetry2nix,
    systems,
    nixpkgs,
  }: let
    inherit (nixpkgs) lib;

    pkgsFor = eachSystem (system:
      import nixpkgs {
        localSystem = system;
      });

    eachSystem = lib.genAttrs (import systems);
  in {
    packages = eachSystem (system: let
      pkgs = pkgsFor.${system};

      entries = {
        sys-brightness = ./apps/sys-brightness;
        screen-capture-x11 = ./apps/screen-capture-x11;
        nmcli-wifi-scan-waybar = ./apps/nmcli-wifi-scan-waybar;
        # playerctl-waybar = ./apps/playerctl-waybar;
        sys-sound = ./apps/sys-sound;
        batlimit = ./apps/batlimit;
        cliphist-rofi = ./apps/cliphist-rofi;
        swww-switcher = ./apps/swww-switcher;
        nixgrep = ./apps/nixgrep;
        mullvad-status = ./apps/mullvad-status;
      };
    in
      {
        default = self.packages.${system}.nmcli-wifi-scan-waybar;
      }
      // lib.attrsets.mapAttrs (_n: p:
        pkgs.callPackage p {
          inherit (poetry2nix.lib.mkPoetry2Nix {inherit pkgs;}) mkPoetryApplication;
          inherit pkgs;
        })
      entries);

    homeManagerModules.default = import ./nix/hm-module.nix self;
  };
}
