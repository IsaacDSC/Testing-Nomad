job "hello-tenant" {
  datacenters = ["dc1"]
  type = "service"

  group "deploy" {
    count = 1
    task "hello-tenant" {
      driver = "docker"
      config {
        image = "archanab/hello-tenant:latest"
      }

      resources {
        cpu    = 500
        memory = 256

        network {
          mbits = 10
          port  "http"  {
            static = 80
          }
        }
      }

      env {
        tenant_name = "tenant-archana"
      }
    }
  }
}