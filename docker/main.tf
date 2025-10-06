terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
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


