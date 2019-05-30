{ pkgs ? import <nixpkgs> {} }:

let
  # TODO needs to be kept in sync with sbt project?
  version = "1.0";

in pkgs.stdenv.mkDerivation {
  name = "service-dependencies";

  src = pkgs.fetchFromGitHub {
    owner = "hmrc";
    repo = "service-dependencies";
    rev = "ae86b6b734c6cd8c26f4d7ae9d27b39ea790dcc7";
    sha256 = "0wrdrk816589hikg3knpgk14zv8zwwvh7gmxbrx5prigmr9kskmk";
  };

  # set environment variable to affect all SBT commands
  # SBT_OPTS = ''
  #   -Dsbt.ivy.home=./.ivy2/
  #   -Dsbt.boot.directory=./.sbt/boot/
  #   -Dsbt.global.base=./.sbt
  #   -Dsbt.global.staging=./.staging
  # '';

  JAVA_TOOL_OPTIONS = "-Dfile.encoding=UTF-8";

  buildInputs = [ pkgs.git pkgs.makeWrapper ]; # sbt-version plugin requires git on path

  buildPhase = ''
    # also use clean, if not setting SBT_OPTS for isolation
    #${pkgs.sbt}/bin/sbt test stage
    ${pkgs.sbt}/bin/sbt stage
  '';

  installPhase = ''
    mkdir -p $out/{lib,bin}
    cp -r ./target/universal/stage/* $out/

    # generated script requires dirname, basename, uname, awk, jre on path
    wrapProgram $out/bin/service-dependencies \
      --prefix PATH ":" ${pkgs.jre}/bin \
      --prefix PATH ":" ${pkgs.coreutils}/bin \
      --prefix PATH ":" ${pkgs.gawk}/bin ;
  '';
}
