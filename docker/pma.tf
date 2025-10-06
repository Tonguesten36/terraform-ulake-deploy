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
