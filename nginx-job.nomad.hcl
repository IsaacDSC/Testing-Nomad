job "httpnginx" {
  datacenters = ["dc1"]
  group "echo" {
    network {
      mode = "bridge"
      port "http" {
        static = 8080
        to = 80
      }
    }
    count = 2
    task "server" {
      driver = "docker"
      config {
        image = "nginx"
        ports = ["http"]
      }
    }
  }
}