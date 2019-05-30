{ pkgs ? import <nixpkgs> {} }:

let

  kind = pkgs.callPackage ./k8s/kind.nix {};

  serviceDependencies = pkgs.callPackage ./build.nix {};

  kubenix = pkgs.callPackage ./k8s/kubenix.nix {};

  buildConfig = t: kubenix.buildResources { configuration = import ./k8s-config.nix { type = t; }; };

  appImage = pkgs.callPackage ./docker.nix {};

  buildConfigMongo = t: kubenix.buildResources { configuration = import ./k8s-config-mongo.nix { type = t; }; };

  appImageMongo = pkgs.callPackage ./docker-mongo.nix {};

in

  rec {

    app = serviceDependencies;

    kind-create-cluster = pkgs.callPackage ./k8s/kind-create-cluster.nix {
      inherit kind;
    };

    kind-deploy-app = pkgs.callPackage ./k8s/kind-deploy-app.nix {
      config = buildConfig "dev";
      inherit kind;
      inherit appImage;
    };

    kind-deploy-mongo = pkgs.callPackage ./k8s/kind-deploy-mongo.nix {
      config = buildConfigMongo "dev";
      inherit kind;
      appImage = appImageMongo;
    };

    shell = pkgs.mkShell {
      buildInputs = [
        kind
        kind-create-cluster
        kind-deploy-app
        kind-deploy-mongo
        pkgs.curl
        pkgs.docker
        pkgs.kubectl
      ];
      shellHook = ''
        kind-create-cluster
        kind-deploy-app
        kind-deploy-mongo
        export KUBECONFIG=$(kind get kubeconfig-path)
      '';
    };

  }
