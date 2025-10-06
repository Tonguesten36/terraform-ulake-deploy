# Step 5: nginx container
resource "docker_container" "ulake_nginx" {
  name    = "ulake-nginx"
  image   = docker_image.nginx.image_id
  restart = "unless-stopped"

  ports {
    internal = 80
    external = 80
  }

  volumes {
    host_path      = abspath("${path.module}/../../deployment/nginx.conf.mini")
    container_path = "/etc/nginx/nginx.conf"
    read_only      = true
  }

  volumes {
    host_path      = abspath("${path.module}/../../ulake-nginx/html")
    container_path = "/opt/ulake-nginx"
    read_only      = true
  }

  networks_advanced {
    name    = docker_network.ulake_network.name
    aliases = ["ulake-nginx"]
  }

  host {
    host = "user.ulake.usth.edu.vn"
    ip = "127.0.0.1"
  }
  host {
    host = "log.ulake.usth.edu.vn"
    ip = "127.0.0.1"
  }
  host {
    host = "pma.ulake.usth.edu.vn"
    ip = "127.0.0.1"
  }
  host {
    host = "dashboard.ulake.usth.edu.vn"
    ip = "127.0.0.1"
  }
  host {
    host = "core.ulake.usth.edu.vn"
    ip = "127.0.0.1"
  }
  host {
    host = "folder.ulake.usth.edu.vn"
    ip = "127.0.0.1"
  }
  host {
    host = "acl.ulake.usth.edu.vn"
    ip = "127.0.0.1"
  }

  depends_on = [
    docker_container.ulake_service_user,
    docker_container.ulake_service_log,
    docker_container.ulake_service_dashboard,
    docker_container.ulake_service_acl,
    docker_container.ulake_service_folder,
    docker_container.ulake_service_core,
    docker_container.ulake_phpmyadmin
  ]
}
resource "docker_image" "nginx" {
  name = "nginx:latest"
}