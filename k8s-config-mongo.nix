{ type ? "dev" }:

let
  kubeVersion = "1.11";

  mongodb = rec {
    label = "mongodb";
    port = 27017;
    cpu = if type == "dev" then "100m" else "1000m";
    imagePolicy = if type == "dev" then "Never" else "IfNotPresent";
    env = [{ name = "APP_PORT"; value = "${toString port}"; }];
  };
in
{
  kubernetes.version = kubeVersion;

  kubernetes.resources.deployments."${mongodb.label}" = {
    metadata.labels.app = mongodb.label;
    spec = {
      replicas = 1;
      selector.matchLabels.app = mongodb.label;
      template = {
        metadata.labels.app = mongodb.label;
        spec.containers."${mongodb.label}" = {
          name = "${mongodb.label}";
          image = "mongodb:latest";
          imagePullPolicy = mongodb.imagePolicy;
          env = mongodb.env;
          resources.requests.cpu = mongodb.cpu;
          ports."${toString mongodb.port}" = {};
          volumeMounts = [
            { mountPath = "/tmp";
              name = "tmp-volume";
            }
            { mountPath = "/data/db";
              name = "data-volume";
            }
           ];
        };
        spec.volumes = [
          { name = "tmp-volume";
            emptyDir = {};
          }
          { name = "data-volume";
            emptyDir = {};
          }
        ];
      };
    };
  };

  kubernetes.resources.services."${mongodb.label}" = {
    spec.selector.app = "${mongodb.label}";
    spec.ports."${toString mongodb.port}".targetPort = mongodb.port;
  };
}
