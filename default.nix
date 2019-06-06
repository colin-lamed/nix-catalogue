{ pkgs ? import <nixpkgs> {} }:

let

  kind             = pkgs.callPackage ./k8s/kind.nix {};

  kubenix          = pkgs.callPackage ./k8s/kubenix.nix {};

  docker-mongo     = pkgs.callPackage ./docker-mongo.nix {};
  k8s-config-mongo = t: kubenix.buildResources { configuration = import ./k8s-config-mongo.nix { type = t; }; };

  serviceDefs      = pkgs.callPackage ./services.nix {};

  findService      = name: pkgs.lib.lists.findFirst (serviceDef: serviceDef.name == name) {} serviceDefs;

in

  rec {

    buildService = name: let serviceDef = findService name;
                         in  pkgs.callPackage ./mkService.nix {
                               name    = serviceDef.name;
                               version = serviceDef.version;
                               sha256  = serviceDef.sha256;
                             };

    buildDocker  = name: let serviceDef = findService name;
                             service    = buildService name;
                         in  pkgs.callPackage ./docker-service.nix {
                               imageName = serviceDef.name;
                               cmd       = "${service}/bin/${serviceDef.name}";
                               debug     = false;
                            };

    deployService   = name: let serviceDef = findService name;
                                dockerImage = buildDocker name;
                                k8sConfig   = t: kubenix.buildResources {
                                                configuration = import ./k8s-config-service.nix {
                                                  config = rec {
                                                    label     = serviceDef.name;
                                                    port      = serviceDef.port;
                                                    type      = "dev";
                                                    imageName = serviceDef.name;
                                                    env       = serviceDef.env;
                                                  };
                                                };
                                              };

                             in pkgs.callPackage ./k8s/kind-deploy.nix {
                                  config   = k8sConfig "dev";
                                  name     = serviceDef.name;
                                  inherit kind;
                                  appImage = dockerImage;
                                };

    deployServices   = map (serviceDef: deployService serviceDef.name) serviceDefs;


    kind-create-cluster = pkgs.callPackage ./k8s/kind-create-cluster.nix {
                            inherit kind;
                          };

    kind-deploy-mongo   = pkgs.callPackage ./k8s/kind-deploy.nix {
                            config   = k8s-config-mongo "dev";
                            name     = "mongo";
                            inherit kind;
                            appImage = docker-mongo;
                          };

    docker-redis     = pkgs.callPackage ./docker-redis.nix {};

    k8s-config-redis = t: kubenix.buildResources { configuration = import ./k8s-config-redis.nix { type = t; }; };

    kind-deploy-redis   = pkgs.callPackage ./k8s/kind-deploy.nix {
                            config   = k8s-config-redis "dev";
                            name     = "redis";
                            inherit kind;
                            appImage = docker-redis;
                          };

    kind-deploy-all-services = pkgs.callPackage ./kind-deploy-all-services.nix {
                                 inherit serviceDefs;
                               };

    shell               = pkgs.mkShell {
                            buildInputs = [
                              kind
                              kind-create-cluster
                              kind-deploy-mongo
                              kind-deploy-redis
                              kind-deploy-all-services
                              pkgs.curl
                              pkgs.docker
                              pkgs.kubectl
                            ] ++ deployServices;
                            shellHook = ''
                              kind-create-cluster
                              kind-deploy-mongo
                              kind-deploy-redis
                              kind-deploy-all-services
                              export KUBECONFIG=$(kind get kubeconfig-path)
                            '';
                          };
  }
