{ pkgs ? import <nixpkgs> {} }:

let

  serviceDependencies = pkgs.callPackage ./build.nix {};

in

pkgs.dockerTools.buildLayeredImage {
  name = "service-dependencies";
  tag = "latest";
  config.Cmd = [ "${serviceDependencies}/bin/service-dependencies" ];
}
