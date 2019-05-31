{ pkgs ? import <nixpkgs> {} }:

let

  kind = pkgs.callPackage ./k8s/kind.nix {};

  kubenix = pkgs.callPackage ./k8s/kubenix.nix {};

  docker-mongo = pkgs.callPackage ./docker-mongo.nix {};
  k8s-config-mongo = t: kubenix.buildResources { configuration = import ./k8s-config-mongo.nix { type = t; }; };

  # TODO move to json file, and load them all

  #
  # catalogue-frontend
  #

  docker-catalogue-frontend-imageName = "catalogue-frontend";

  catalogue-frontend = pkgs.callPackage ./service.nix {
    name = "catalogue-frontend";
    version = "4.267.0";
    sha256 = "11d1ds126kfd13wnprvgxc4hqdf8zlykhqvl2bcnkv1sn5xnd0wh";
  };

  docker-catalogue-frontend = pkgs.callPackage ./docker-service.nix {
    imageName = docker-catalogue-frontend-imageName;
    cmd = "${catalogue-frontend}/bin/catalogue-frontend";
    debug = false;
  };

  k8s-config-catalogue-frontend = t: kubenix.buildResources {
    configuration = import ./k8s-config-service.nix {
      config = rec {
        label = "catalogue-frontend";
        port = 9017;
        type = "dev";
        imageName = docker-catalogue-frontend-imageName;
        env = [{ name = "JAVA_TOOL_OPTIONS";
                 value = "-Dhttp.port=${toString port} -Dhttp.address=0.0.0.0 -Dmongodb.uri=mongodb://mongodb/catalogue-frontend";
              }];
      };
    };
  };

  #
  # service-dependencies
  #

  docker-service-dependencies-imageName = "service-dependencies";

  serviceDependencies = pkgs.callPackage ./service.nix {
    name = "service-dependencies";
    version = "1.82.0";
    sha256 = "0aad75grsjbxlk336hzz27i9vlxv7kqrjirmdg2d5cj24pxbila1";
  };

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

    kind-deploy-mongo = pkgs.callPackage ./k8s/kind-deploy.nix {
      config = k8s-config-mongo "dev";
      name = "mongo";
      inherit kind;
      appImage = docker-mongo;
    };

    kind-deploy-service-dependencies = pkgs.callPackage ./k8s/kind-deploy.nix {
      config = k8s-config-service-dependencies "dev";
      name = "service-dependencies";
      inherit kind;
      appImage = docker-service-dependencies;
    };

    kind-deploy-catalogue-frontend = pkgs.callPackage ./k8s/kind-deploy.nix {
      config = k8s-config-catalogue-frontend "dev";
      name = "catalogue-frontend";
      inherit kind;
      appImage = docker-catalogue-frontend;
    };

    shell = pkgs.mkShell {
      buildInputs = [
        kind
        kind-create-cluster
        kind-deploy-mongo
        kind-deploy-service-dependencies
        kind-deploy-catalogue-frontend
        pkgs.curl
        pkgs.docker
        pkgs.kubectl
      ];
      shellHook = ''
        kind-create-cluster
        kind-deploy-mongo
        kind-deploy-service-dependencies
        kind-deploy-catalogue-frontend
        export KUBECONFIG=$(kind get kubeconfig-path)
      '';
    };

  }
