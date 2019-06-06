{ serviceDefs, pkgs }:

let script = pkgs.lib.strings.concatMapStrings (serviceDef:
              ''
                kind-deploy-${serviceDef.name}
              ''
             ) serviceDefs;


in pkgs.writeScriptBin "kind-deploy-all-services" script
