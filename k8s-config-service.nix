{ config, type ? "dev" }:

let
  kubeVersion = "1.11";

  cpu = if type == "dev" then "100m" else "1000m";

  imagePolicy = if type == "dev" then "Never" else "IfNotPresent";

in
{
  kubernetes.version = kubeVersion;

  kubernetes.resources.deployments."${config.label}" = {
    metadata.labels.app = config.label;
    spec = {
      replicas = 1;
      selector.matchLabels.app = config.label;
      template = {
        metadata.labels.app = config.label;
        spec.containers."${config.label}" = {
          name = "${config.label}";
          image = "${config.imageName}:latest";
          imagePullPolicy = imagePolicy;
          env = config.env;
          resources.requests.cpu = cpu;
          ports."${toString config.port}" = {};
          volumeMounts = [
            { mountPath = "/tmp";
              name = "tmp-volume";
            }
           ];
          livenessProbe = {
            httpGet = {
              path =  "/ping/ping";
              port = config.port;
            };
            initialDelaySeconds = 30;
            timeoutSeconds = 1;
          };
        };
        spec.volumes = [
          { name = "tmp-volume";
            emptyDir = {};
          }
        ];
      };
    };
  };

  kubernetes.resources.services."${config.label}" = {
    spec.selector.app = "${config.label}";
     spec.ports."${toString config.port}".targetPort = config.port;
    # spec.ports."${toString config.port}" = {
    #   targetPort = config.port;

    # # default type is "ClusterIP"
    # # service is only reachable from within cluster. Start `kubectl proxy` to reach.
    # # e.g. curl -i "http://localhost:8001/api/v1/namespaces/defult/services/service-dependencies:8459/ping/ping"

    # # nodePort will fail for "ClusterIP"
    #   nodePort = 32222;
    # };
    # spec.type = "NodePort";

    # e.g. get cluser ip: `kubectl get svc`
    # curl -i "http://<cluser ip>:32222/ping/ping"
  };
}
