{ imageName, cmd, debug, pkgs ? import <nixpkgs> {} }:

let


  image = pkgs.dockerTools.buildLayeredImage {
    name = imageName;
    tag = "latest";
    config.Cmd = [ cmd ];
  };

  debugImage = pkgs.dockerTools.buildImage {
    name = imageName;
    tag = "latest";
    fromImage = pkgs.dockerTools.pullImage {
            imageName = "alpine";
            imageDigest = "sha256:e1871801d30885a610511c867de0d6baca7ed4e6a2573d506bbec7fd3b03873f";
            sha256 = "05wcg38vsygjzf59cspfbb7cq98c7x18kz2yym6rbdgx960a0kyq";
          };
    contents = [ pkgs.curl pkgs.telnet pkgs.dnsutils ];
    config.Cmd = [ "${pkgs.bash}/bin/sh"
                  "-c"
                  "${pkgs.coreutils}/bin/echo /etc/hostname && ${pkgs.coreutils}/bin/cat /etc/hostname && \
                    ${pkgs.coreutils}/bin/echo /etc/hosts && ${pkgs.coreutils}/bin/cat /etc/hosts && \
                    ${pkgs.coreutils}/bin/echo /etc/resolv.conf && ${pkgs.coreutils}/bin/cat /etc/resolv.conf && \
                    ${cmd}"
                ];
  };


in

  if debug then debugImage else image
