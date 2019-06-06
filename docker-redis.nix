{ pkgs ? import <nixpkgs> {} }:

pkgs.dockerTools.buildLayeredImage {
  name = "redis";
  tag = "latest";
  config.Cmd = [ "${pkgs.redis}/bin/redis-server" ];
}
