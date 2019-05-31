{ type ? "dev" }:

let
  kubeVersion = "1.11";

  serviceDependencies = rec {
    label = "service-dependencies";
    port = 8459;
    cpu = if type == "dev" then "100m" else "1000m";
    imagePolicy = if type == "dev" then "Never" else "IfNotPresent";
    env = [{ name = "JAVA_TOOL_OPTIONS"; value = "-Dhttp.port=${toString port} -Dhttp.address=0.0.0.0 -Dmongodb.uri=mongodb://mongodb/service-dependencies"; }];
  };
in
{
  kubernetes.version = kubeVersion;

  kubernetes.resources.deployments."${serviceDependencies.label}" = {
    metadata.labels.app = serviceDependencies.label;
    spec = {
      replicas = 1;
      selector.matchLabels.app = serviceDependencies.label;
      template = {
        metadata.labels.app = serviceDependencies.label;
        spec.containers."${serviceDependencies.label}" = {
          name = "${serviceDependencies.label}";
          image = "service-dependencies:latest";
          imagePullPolicy = serviceDependencies.imagePolicy;
          env = serviceDependencies.env;
          resources.requests.cpu = serviceDependencies.cpu;
          ports."${toString serviceDependencies.port}" = {};
          volumeMounts = [
            { mountPath = "/tmp";
              name = "tmp-volume";
            }
           ];
          livenessProbe = {
            httpGet = {
              path =  "/ping/ping";
              port = serviceDependencies.port;
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

  kubernetes.resources.services."${serviceDependencies.label}" = {
    spec.selector.app = "${serviceDependencies.label}";
     spec.ports."${toString serviceDependencies.port}".targetPort = serviceDependencies.port;
    # spec.ports."${toString serviceDependencies.port}" = {
    #   targetPort = serviceDependencies.port;

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
