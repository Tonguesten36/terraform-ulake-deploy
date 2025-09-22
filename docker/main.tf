terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "docker" {
  # For Windows only
  # host = "npipe:////.//pipe//docker_engine"
}

# use this if the microservices uses dev build instead
# resource "docker_image" "ulake_service" {
#   name = "ulake/service:1.0.0-SNAPSHOT"
# }

# Step 1: Create ulake-network
resource "docker_network" "ulake_network" {
  name   = "ulake-network"
  driver = "bridge"
}

# Step 2: Start a MariaDB container
# Define Docker volume for persistent MariaDB data
resource "docker_volume" "mariadb_data" {
  name = "mariadb_data"
}
# MariaDB 
# all microservices only recognize the name ulake-mysql despite the database runs on MariaDB
resource "docker_container" "ulake_mariadb" {
  name    = "ulake-mysql"
  image   = docker_image.mariadb.image_id
  restart = "unless-stopped"

  depends_on = [docker_network.ulake_network]

  ports {
    internal = 3306
    external = 23306
  }

  env = [
    "MYSQL_ROOT_PASSWORD=root"
  ]

  volumes {
    volume_name    = docker_volume.mariadb_data.name
    container_path = "/var/lib/mysql"
  }

  networks_advanced {
    name    = docker_network.ulake_network.name
    aliases = ["ulake-mysql"]
  }
}
# Initialize the database
resource "null_resource" "init_sql" {
  provisioner "local-exec" {
    command = "./init_db.sh"
  }

  triggers = {
    mariadb_container_id = docker_container.ulake_mariadb.id
  }

  depends_on = [docker_container.ulake_mariadb]
}
# Find the latest MariaDB image.
resource "docker_image" "mariadb" {
  name = "mariadb:latest"
}

# Step 3: Start a phpmyadmin container
resource "docker_container" "ulake_phpmyadmin" {
  name    = "ulake-phpmyadmin"
  image   = docker_image.ulake_phpmyadmin.image_id
  restart = "unless-stopped"

  depends_on = [null_resource.init_sql]

  ports {
    internal = 80
    external = 8081
  }

  env = [
    "MYSQL_ROOT_PASSWORD=root",
    "PMA_HOST=${docker_container.ulake_mariadb.name}",
    "PMA_PORT=3306"
  ]

  networks_advanced {
    name    = docker_network.ulake_network.name
    aliases = ["ulake-phpmyadmin"]
  }
}
# Find the phpMyAdmin image
resource "docker_image" "ulake_phpmyadmin" {
  name = "phpmyadmin:latest"
}

# Step 4: Start the microservice containers
resource "docker_image" "ulake_microservices_native" {
  name = "registry.access.redhat.com/ubi8/ubi-minimal:8.6"
}
# # 4.1: Log service
resource "docker_container" "ulake_service_log" {
  name    = "ulake-service-log-${count.index}"
  image   = docker_image.ulake_microservices_native.image_id
  restart = "unless-stopped"

  count = var.log_service_count

  depends_on = [null_resource.init_sql]

  entrypoint = [
    "/home/ulake-service-log-runner"
  ]

  env = [
    "MYSQL_ROOT_PASSWORD=root"
  ]

  volumes {
    host_path      = abspath("${path.module}/../../log/build/log-1.0.0-runner")
    container_path = "/home/ulake-service-log-runner"
    read_only      = true
  }

  networks_advanced {
    name    = docker_network.ulake_network.name
    aliases = ["ulake-service-log"]
  }
}
# # 4.2: User service
resource "docker_container" "ulake_service_user" {
  name    = "ulake-service-user-${count.index}"
  image   = docker_image.ulake_microservices_native.image_id
  restart = "unless-stopped"

  count = var.user_service_count

  depends_on = [null_resource.init_sql]

  entrypoint = [
    "/home/ulake-service-user-runner"
  ]

  env = [
    "MYSQL_ROOT_PASSWORD=root"
  ]

  volumes {
    host_path      = abspath("${path.module}/../../user/build/user-1.0.0-SNAPSHOT-runner")
    container_path = "/home/ulake-service-user-runner"
    read_only      = true
  }

  networks_advanced {
    name    = docker_network.ulake_network.name
    aliases = ["ulake-service-user"]
  }
}

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

  depends_on = [
    docker_container.ulake_service_user,
    docker_container.ulake_service_log,
    docker_container.ulake_phpmyadmin
  ]
}
resource "docker_image" "nginx" {
  name = "nginx:latest"
}

