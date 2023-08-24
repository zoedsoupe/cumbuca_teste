{
  description = "Case Técnico da Cumbuca";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

  outputs = {nixpkgs, ...}: let
    system = "aarch64-darwin";

    pkgs = import nixpkgs {inherit system;};
  in {
    packages = {
      # todo build release with Nix
      "${system}".default = null;
    };

    devShells = {
      "${system}".default = with pkgs;
        mkShell {
          name = "pescarte";
          packages = [
            gnumake
            gcc
            openssl
            zlib
            elixir_1_14
            darwin.apple_sdk.frameworks.CoreServices
            darwin.apple_sdk.frameworks.CoreFoundation
          ];
        };
    };
  };
}
