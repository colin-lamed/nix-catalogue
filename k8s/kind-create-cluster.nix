{ kind, pkgs }:

pkgs.writeScriptBin "kind-create-cluster"
''
  #! ${pkgs.runtimeShell}
  set -euo pipefail
  ${kind}/bin/kind delete cluster || true
  ${kind}/bin/kind create cluster
''
