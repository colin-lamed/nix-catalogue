{}:

[
  rec {
    name    = "catalogue-frontend";
    version = "4.267.0";
    sha256  = "11d1ds126kfd13wnprvgxc4hqdf8zlykhqvl2bcnkv1sn5xnd0wh";
    port    = 9017;
    env     = [{ name  = "JAVA_TOOL_OPTIONS";
                 value = builtins.concatStringsSep " "
                           [ "-Dhttp.port=${toString port}"
                             "-Dmicroservice.services.teams-and-repositories.host=teams-and-repositories"
                             "-Dmicroservice.services.indicators.host=indicators"
                             "-Dmicroservice.services.service-deployments.host=service-deployments"
                             "-Dmicroservice.services.service-dependencies.host=service-dependencies"
                             "-Dmicroservice.services.service-configs.host=service-configs"
                             "-Dmicroservice.services.leak-detection.host=leak-detection"
                             "-Dmicroservice.services.user-management.url=http://example.com"
                             "-Dmicroservice.services.user-management.myTeamsUrl=http://example.com/myTeams"
                             "-Dmicroservice.services.user-management.profileBaseUrl=http://example.com/profile"
                             "-Dmicroservice.services.user-management-auth.url=PLACEHOLDER"
                             "-DurlTemplates.app-config-base=https://example.com/app-config-base/"
                             "-Dprototypes-base-url=PLACEHOLDER"
                             "-Dself-service-url=PLACEHOLDER"
                             "-Dmongodb.uri=mongodb://mongodb/catalogue-frontend"
                           ];
               }];
  }

  rec {
    name    = "service-dependencies";
    version = "1.82.0";
    sha256  = "0aad75grsjbxlk336hzz27i9vlxv7kqrjirmdg2d5cj24pxbila1";
    port    = 8459;
    env     = [{ name  = "JAVA_TOOL_OPTIONS";
                 value = builtins.concatStringsSep " "
                           [ "-Dhttp.port=${toString port}"
                             "-Dmongodb.uri=mongodb://mongodb/service-dependencies"
                             "-Dmicroservice.services.teams-and-repositories.host=teams-and-repositories"
                             "-Dmicroservice.services.service-configs.host=service-configs"
                             "-Dmicroservice.services.service-deployments.host=service-deployments"
                           ];
              }];
  }

  rec {
    name    = "service-configs";
    version = "0.42.0";
    sha256  = "1jrw989wknygcb424v5llp82y2qfzyhxjwlcli7m7m0crri9sghv";
    port    = 8460;
    env     = [{ name  = "JAVA_TOOL_OPTIONS";
                 value = builtins.concatStringsSep " "
                           [ "-Dhttp.port=${toString port}"
                             "-Dmongodb.uri=mongodb://mongodb/service-configs"
                             "-Dmetrics.enabled=false"
                             "-Dmicroservice.services.service-dependencies.host=service-dependencies"
                           ];
              }];
  }

  rec {
    name    = "service-deployments";
    version = "1.53.0";
    sha256  = "0cijzac7iwww3k45s6h68bmq2ii85shl0v4s2c0ilfamq42w47pf";
    port    = 8458;
    env     = [{ name  = "JAVA_TOOL_OPTIONS";
                 value = builtins.concatStringsSep " "
                           [ "-Dhttp.port=${toString port}"
                             "-Dmongodb.uri=mongodb://mongodb/service-deployments"
                             "-Dmicroservice.services.teams-and-repositories.host=teams-and-repositories"
                             "-Dartifactory.url=https://change.this.to.artifactory.url/artifactory"
                             "-Ddeployments.api.url=https://change.this.to.releases.app.url"
                           ];
              }];
  }

  rec {
    name    = "teams-and-repositories";
    version = "10.65.0";
    sha256  = "1qllasap30fdvkkhhnfz031az19jkqxfjsmc2pq8ih86w9d6mlca";
    port    = 9015;
    env     = [{ name  = "JAVA_TOOL_OPTIONS";
                 value = builtins.concatStringsSep " "
                           [ "-Dhttp.port=${toString port}"
                             "-Dmongodb.uri=mongodb://mongodb/teams-and-repositories"
                             "-Dapplication.router=testOnlyDoNotUseInAppConf.Routes"
                           ];
              }];
  }
]
