{ type ? "dev" }:

let
  kubeVersion = "1.11";

  redis = rec {
    label = "redis";
    port = 6379;
    cpu = if type == "dev" then "100m" else "1000m";
    imagePolicy = if type == "dev" then "Never" else "IfNotPresent";
    env = [{ name = "APP_PORT"; value = "${toString port}"; }];
  };
in
{
  kubernetes.version = kubeVersion;

  kubernetes.resources.deployments."${redis.label}" = {
    metadata.labels.app = redis.label;
    spec = {
      replicas = 1;
      selector.matchLabels.app = redis.label;
      template = {
        metadata.labels.app = redis.label;
        spec.containers."${redis.label}" = {
          name = "${redis.label}";
          image = "redis:latest";
          imagePullPolicy = redis.imagePolicy;
          env = redis.env;
          resources.requests.cpu = redis.cpu;
          ports."${toString redis.port}" = {};
          # volumeMounts = [
          #   { mountPath = "/tmp";
          #     name = "tmp-volume";
          #   }
          #   { mountPath = "/data/db";
          #     name = "data-volume";
          #   }
          #  ];
        };
        # spec.volumes = [
        #   { name = "tmp-volume";
        #     emptyDir = {};
        #   }
        #   { name = "data-volume";
        #     emptyDir = {};
        #   }
        # ];
      };
    };
  };

  kubernetes.resources.services."${redis.label}" = {
    spec.selector.app = "${redis.label}";
    spec.ports."${toString redis.port}".targetPort = redis.port;
  };
}
