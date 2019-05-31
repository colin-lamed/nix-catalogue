{ pkgs ? import <nixpkgs> {} }:

let

  kind             = pkgs.callPackage ./k8s/kind.nix {};

  kubenix          = pkgs.callPackage ./k8s/kubenix.nix {};

  docker-mongo     = pkgs.callPackage ./docker-mongo.nix {};
  k8s-config-mongo = t: kubenix.buildResources { configuration = import ./k8s-config-mongo.nix { type = t; }; };


  serviceDefs      = pkgs.callPackage ./services.nix {};

  deployServices   = map (serviceDef:

    let
      dockerImageName = serviceDef.name;

      service         = pkgs.callPackage ./mkService.nix {
                          name    = serviceDef.name;
                          version = serviceDef.version;
                          sha256  = serviceDef.sha256;
                        };

      dockerImage     = pkgs.callPackage ./docker-service.nix {
                          imageName = dockerImageName;
                          cmd       = "${service}/bin/${serviceDef.name}";
                          debug     = false;
                        };

      name            = serviceDef.name;

      k8sConfig       = t: kubenix.buildResources {
                          configuration = import ./k8s-config-service.nix {
                            config = rec {
                              label      = serviceDef.name;
                              port       = serviceDef.port;
                              type       = "dev";
                              imageName = dockerImageName;
                              env       = serviceDef.env;
                            };
                          };
                        };

    in

      pkgs.callPackage ./k8s/kind-deploy.nix {
        config   = k8sConfig "dev";
        name     = serviceDef.name;
        inherit kind;
        appImage = dockerImage;
      }

  ) serviceDefs;

in

  rec {

    kind-create-cluster = pkgs.callPackage ./k8s/kind-create-cluster.nix {
                            inherit kind;
                          };

    kind-deploy-mongo   = pkgs.callPackage ./k8s/kind-deploy.nix {
                            config = k8s-config-mongo "dev";
                            name = "mongo";
                            inherit kind;
                            appImage = docker-mongo;
                          };

    shell               = pkgs.mkShell {
                            buildInputs = [
                              kind
                              kind-create-cluster
                              kind-deploy-mongo
                              pkgs.curl
                              pkgs.docker
                              pkgs.kubectl
                            ] ++ deployServices;
                            shellHook = ''
                              kind-create-cluster
                              kind-deploy-mongo
                              kind-deploy-service-dependencies
                              kind-deploy-catalogue-frontend
                              export KUBECONFIG=$(kind get kubeconfig-path)
                            '';
                          };

  }
