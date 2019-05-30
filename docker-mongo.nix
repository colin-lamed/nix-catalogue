{ pkgs ? import <nixpkgs> {} }:

pkgs.dockerTools.buildLayeredImage {
  name = "mongodb";
  tag = "latest";
  config.Cmd = [ "${pkgs.mongodb}/bin/mongod" ];
}
