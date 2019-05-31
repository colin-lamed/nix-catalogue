{ pkgs ? import <nixpkgs> {} }:

let

  kind = pkgs.callPackage ./k8s/kind.nix {};

  kubenix = pkgs.callPackage ./k8s/kubenix.nix {};

  docker-mongo = pkgs.callPackage ./docker-mongo.nix {};
  k8s-config-mongo = t: kubenix.buildResources { configuration = import ./k8s-config-mongo.nix { type = t; }; };

  docker-service-dependencies = pkgs.callPackage ./docker-service-dependencies.nix {};
  k8s-config-service-dependencies = t: kubenix.buildResources { configuration = import ./k8s-config-service-dependencies.nix { type = t; }; };

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
