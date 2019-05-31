{ pkgs ? import <nixpkgs> {} }:

let

  serviceDependencies = pkgs.callPackage ./service-dependencies.nix {};

in

pkgs.dockerTools.buildLayeredImage {
  name = "service-dependencies";
  tag = "latest";
  contents = [ pkgs.curl pkgs.telnet pkgs.dnsutils ];
  config.Cmd = [ "${serviceDependencies}/bin/service-dependencies" ];
}


# pkgs.dockerTools.buildLayeredImage {
#   name = "service-dependencies";
#   tag = "latest";
#   # config.Cmd = [ "${serviceDependencies}/bin/service-dependencies" ];
#   # config.Cmd = [ "/bin/sh" "-c" "${pkgs.coreutils}/bin/echo 127.0.0.1 $HOSTNAME >> /etc/hosts && ${serviceDependencies}/bin/service-dependencies" ];
#   # config.Cmd = [ "${pkgs.bash}/bin/sh" "-c" "${pkgs.coreutils}/bin/echo 127.0.0.1 $HOSTNAME >> /etc/hosts && ${pkgs.coreutils}/bin/cat /etc/hosts && ${serviceDependencies}/bin/service-dependencies" ];
#   # config.Cmd = [ "${pkgs.bash}/bin/sh" "-c" "${pkgs.coreutils}/bin/cat /etc/hosts && ${serviceDependencies}/bin/service-dependencies" ];
#   # config.Cmd = [ "${pkgs.bash}/bin/sh" "-c" "${pkgs.gawk}/bin/awk -v hostname=$HOSTNAME '{if (NR==1) {print $0\" \" hostname} else {print $0}}' /etc/hosts && \


#   config.Cmd = [ "${pkgs.bash}/bin/sh"
#                  "-c"
#                  "${pkgs.coreutils}/bin/echo /etc/hostname && ${pkgs.coreutils}/bin/cat /etc/hostname && \
#                   ${pkgs.coreutils}/bin/echo /etc/hosts && ${pkgs.coreutils}/bin/cat /etc/hosts && \
#                   ${pkgs.coreutils}/bin/echo /etc/resolv.conf && ${pkgs.coreutils}/bin/cat /etc/resolv.conf && \
#                   ${serviceDependencies}/bin/service-dependencies"
#                ];

# }

# pkgs.dockerTools.buildImage {
#   name = "service-dependencies";
#   tag = "latest";
#   fromImage = pkgs.dockerTools.pullImage {
#           imageName = "alpine";
#           imageDigest = "sha256:e1871801d30885a610511c867de0d6baca7ed4e6a2573d506bbec7fd3b03873f";
#           sha256 = "05wcg38vsygjzf59cspfbb7cq98c7x18kz2yym6rbdgx960a0kyq";
#         };
#   contents = "${serviceDependencies}/bin";
#   # config.Cmd = [ "/bin/sh" "-c" "${pkgs.coreutils}/bin/echo 127.0.0.1 $HOSTNAME >> /etc/hosts && ${pkgs.coreutils}/bin/cat /etc/hosts && ${serviceDependencies}/bin/service-dependencies" ];
#   config.Cmd = [ "/bin/sh" "-c" "${pkgs.coreutils}/bin/cat /etc/hosts && ${serviceDependencies}/bin/service-dependencies" ];
# }




# pkgs.dockerTools.buildImage {
#   name = "service-dependencies";
#   tag = "latest";
#   # config.Cmd = [ "${serviceDependencies}/bin/service-dependencies" ];
#   # config.Cmd = [ "/bin/sh" "-c" "${pkgs.coreutils}/bin/echo 127.0.0.1 $HOSTNAME >> /etc/hosts && ${serviceDependencies}/bin/service-dependencies" ];
#   # config.Cmd = [ "${pkgs.bash}/bin/sh" "-c" "${pkgs.coreutils}/bin/echo 127.0.0.1 $HOSTNAME >> /etc/hosts && ${pkgs.coreutils}/bin/cat /etc/hosts && ${serviceDependencies}/bin/service-dependencies" ];
#   # config.Cmd = [ "${pkgs.bash}/bin/sh" "-c" "${pkgs.coreutils}/bin/cat /etc/hosts && ${serviceDependencies}/bin/service-dependencies" ];
#   # config.Cmd = [ "${pkgs.bash}/bin/sh" "-c" "${pkgs.gawk}/bin/awk -v hostname=$HOSTNAME '{if (NR==1) {print $0\" \" hostname} else {print $0}}' /etc/hosts && \


#   # fromImage = bash;
#   fromImage = pkgs.dockerTools.pullImage {
#           imageName = "alpine";
#           imageDigest = "sha256:e1871801d30885a610511c867de0d6baca7ed4e6a2573d506bbec7fd3b03873f";
#           sha256 = "05wcg38vsygjzf59cspfbb7cq98c7x18kz2yym6rbdgx960a0kyq";
#         };
#   # fromImage = pkgs.dockerTools.pullImage {
#   #         imageName = "debian";
#   #         imageDigest = "sha256:e1871801d30885a610511c867de0d6baca7ed4e6a2573d506bbec7fd3b03873f";
#   #         sha256 = "05wcg38vsygjzf59cspfbb7cq98c7x18kz2yym6rbdgx960a0kyq";
#   #       };

#   contents = [ pkgs.curl pkgs.telnet pkgs.dnsutils ];

#   config = {
#     Cmd = [ "${pkgs.bash}/bin/sh"
#                  "-c"
#                  "${pkgs.coreutils}/bin/echo /etc/hostname && ${pkgs.coreutils}/bin/cat /etc/hostname && \
#                   ${pkgs.coreutils}/bin/echo /etc/hosts && ${pkgs.coreutils}/bin/cat /etc/hosts && \
#                   ${pkgs.coreutils}/bin/echo /etc/resolv.conf && ${pkgs.coreutils}/bin/cat /etc/resolv.conf && \
#                   ${serviceDependencies}/bin/service-dependencies"
#                ];
#   };

# }
