{ kind, appImage, config, pkgs }:

pkgs.writeScriptBin "kind-deploy-mongo"
''
  #! ${pkgs.runtimeShell}
  set -euo pipefail
  echo "Loading the ${pkgs.docker}/bin/docker image inside the kind docker container ..."
  export KUBECONFIG=$(${kind}/bin/kind get kubeconfig-path --name="kind")

  kind load image-archive ${appImage}

  echo "Applying the configuration ..."
  cat ${config} | ${pkgs.jq}/bin/jq "."
  cat ${config} | ${pkgs.kubectl}/bin/kubectl apply -f -
''
