job "Application-Example" {
  type = "service"

  group "application-docker" {
    count = 3

    scaling {
      enabled = true
      min     = 1
      max     = 10

      policy {
        check "96pct" {
          strategy "app-sizing-percentile" {
            percentile = "70"
          }
        }
      }
    }


    network {
      port "application" {
        to = 80
      }
    }

    service {
      name     = "application-svc"
      port     = "application"
      provider = "nomad"
    }

    task "application-task" {
      driver = "docker"

      config {
        image = "nginx"
        ports = ["application"]
      }
    }

  }

}