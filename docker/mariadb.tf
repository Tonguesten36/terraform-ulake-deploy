# Define Docker volume for persistent MariaDB data
resource "docker_volume" "mariadb_data" {
  name = "mariadb_data"
}

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

resource "docker_image" "mariadb" {
  name = "mariadb:latest"
}