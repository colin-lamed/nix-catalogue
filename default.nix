{ pkgs ? import <nixpkgs> {} }:

let

  kind = pkgs.callPackage ./k8s/kind.nix {};

  kubenix = pkgs.callPackage ./k8s/kubenix.nix {};

  docker-mongo = pkgs.callPackage ./docker-mongo.nix {};
  k8s-config-mongo = t: kubenix.buildResources { configuration = import ./k8s-config-mongo.nix { type = t; }; };

  #
  # service dependencies
  #

  # TODO move to json file, and load them all

  docker-service-dependencies-imageName = "service-dependencies";

  serviceDependencies = pkgs.callPackage ./service-dependencies.nix {};

  docker-service-dependencies = pkgs.callPackage ./docker-service.nix {
    imageName = docker-service-dependencies-imageName;
    cmd = "${serviceDependencies}/bin/service-dependencies";
    debug = false;
  };

  k8s-config-service-dependencies = t: kubenix.buildResources {
    configuration = import ./k8s-config-service.nix {
      config = rec {
        label = "service-dependencies";
        port = 8459;
        type = "dev";
        imageName = docker-service-dependencies-imageName;
        env = [{ name = "JAVA_TOOL_OPTIONS";
                 value = "-Dhttp.port=${toString port} -Dhttp.address=0.0.0.0 -Dmongodb.uri=mongodb://mongodb/service-dependencies";
              }];
      };
    };
  };

in

  rec {

    kind-create-cluster = pkgs.callPackage ./k8s/kind-create-cluster.nix {
      inherit kind;
    };

    kind-deploy-mongo = pkgs.callPackage ./k8s/kind-deploy-mongo.nix {
      config = k8s-config-mongo "dev";
      inherit kind;
      appImage = docker-mongo;
    };

    kind-deploy-app = pkgs.callPackage ./k8s/kind-deploy-app.nix {
      config = k8s-config-service-dependencies "dev";
      inherit kind;
      appImage = docker-service-dependencies;
    };

    shell = pkgs.mkShell {
      buildInputs = [
        kind
        kind-create-cluster
        kind-deploy-mongo
        kind-deploy-app
        pkgs.curl
        pkgs.docker
        pkgs.kubectl
      ];
      shellHook = ''
        kind-create-cluster
        kind-deploy-mongo
        kind-deploy-app
        export KUBECONFIG=$(kind get kubeconfig-path)
      '';
    };

  }
