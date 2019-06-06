{ name, version, sha256, pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = name;

  src  = pkgs.fetchFromGitHub {
           owner  = "hmrc";
           repo   = name;
           rev    = "v" + version;
           sha256 = sha256;
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

# sbt plugins require it to be a git project, with appropriate tag....

# java.lang.IllegalArgumentException: Invalid majorVersion: 1. You cannot request a major version of 1 if there are no tags in the repository.
#         at uk.gov.hmrc.versioning.ReleaseVersioning$.calculateVersion(ReleaseVersioning.scala:35)
#         at uk.gov.hmrc.versioning.ReleaseVersioning$.calculateNextVersion(ReleaseVersioning.scala:26)
#         at uk.gov.hmrc.versioning.SbtGitVersioning$$anonfun$projectSettings$1.apply(SbtGitVersioning.scala:40)
#         at uk.gov.hmrc.versioning.SbtGitVersioning$$anonfun$projectSettings$1.apply(SbtGitVersioning.scala:40)

# java.lang.IllegalArgumentException: One of setGitDir or setWorkTree must be called.
#         at org.eclipse.jgit.lib.BaseRepositoryBuilder.requireGitDirOrWorkTree(BaseRepositoryBuilder.java:590)
#         at org.eclipse.jgit.lib.BaseRepositoryBuilder.setup(BaseRepositoryBuilder.java:555)
#         at org.eclipse.jgit.storage.file.FileRepositoryBuilder.build(FileRepositoryBuilder.java:92)
#         at uk.gov.hmrc.Git$.repository$lzycompute(SbtAutoBuildPlugin.scala:160)
#         at uk.gov.hmrc.Git$.repository(SbtAutoBuildPlugin.scala:157)
#         at uk.gov.hmrc.Git$class.findRemoteConnectionUrl(SbtAutoBuildPlugin.scala:176)
#         at uk.gov.hmrc.Git$.findRemoteConnectionUrl(SbtAutoBuildPlugin.scala:156)
#         at uk.gov.hmrc.Git$class.browserUrl(SbtAutoBuildPlugin.scala:172)
#         at uk.gov.hmrc.Git$.browserUrl(SbtAutoBuildPlugin.scala:156)
#         at uk.gov.hmrc.Git$class.homepage(SbtAutoBuildPlugin.scala:169)
#         at uk.gov.hmrc.Git$.homepage(SbtAutoBuildPlugin.scala:156)
#         at uk.gov.hmrc.ArtefactDescription$$anonfun$apply$10.apply(SbtAutoBuildPlugin.scala:119)
#         at uk.gov.hmrc.ArtefactDescription$$anonfun$apply$10.apply(SbtAutoBuildPlugin.scala:119)


  patchPhase = ''
    git init
    git config user.email "you@example.com"
    git config user.name "Your Name"
    git add .
    git commit -m "Initial import"
    git tag -a v${version} -m "v${version}"
  '';

  buildPhase = ''
    # also use clean, if not setting SBT_OPTS for isolation
    #${pkgs.sbt}/bin/sbt test stage
    ${pkgs.sbt}/bin/sbt stage
  '';

  installPhase = ''
    mkdir -p $out/{lib,bin}
    cp -r ./target/universal/stage/* $out/

    # generated script requires dirname, basename, uname, awk, jre on path
    wrapProgram $out/bin/${name} \
      --prefix PATH ":" ${pkgs.jre}/bin \
      --prefix PATH ":" ${pkgs.coreutils}/bin \
      --prefix PATH ":" ${pkgs.gawk}/bin ;
  '';
}
