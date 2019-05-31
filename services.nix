  {}:# TODO move to json file, and load them all

[
  #
  # catalogue-frontend
  #
  rec { name = "catalogue-frontend";
    version = "4.267.0";
    sha256 = "11d1ds126kfd13wnprvgxc4hqdf8zlykhqvl2bcnkv1sn5xnd0wh";
    port = 9017;
    env = [{ name = "JAVA_TOOL_OPTIONS";
             value = "-Dhttp.port=${toString port} -Dhttp.address=0.0.0.0 -Dmongodb.uri=mongodb://mongodb/catalogue-frontend";
          }];
  }

  #
  # service-dependencies
  #
  rec { name = "service-dependencies";
    version = "1.82.0";
    sha256 = "0aad75grsjbxlk336hzz27i9vlxv7kqrjirmdg2d5cj24pxbila1";
    port = 8459;
    env = [{ name = "JAVA_TOOL_OPTIONS";
             value = "-Dhttp.port=${toString port} -Dhttp.address=0.0.0.0 -Dmongodb.uri=mongodb://mongodb/service-dependencies";
          }];
  }
]
