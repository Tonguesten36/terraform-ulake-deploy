resource "docker_image" "ulake_microservices_native" {
  name = "registry.access.redhat.com/ubi8/ubi-minimal:8.6"
}

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
    aliases = ["ulake-service-log"] # The network aliases of the container in the specific network.
  }
}

resource "docker_container" "ulake_service_user" {
  name    = "ulake-service-user-${count.index}"
  image   = docker_image.ulake_microservices_native.image_id
  restart = "unless-stopped"

  count = var.user_service_count

  depends_on = [null_resource.init_sql, docker_container.ulake_service_log]

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

resource "docker_container" "ulake_service_dashboard" {
  name    = "ulake-service-dashboard-${count.index}"
  image   = docker_image.ulake_microservices_native.image_id
  restart = "unless-stopped"

  count = var.dashboard_service_count

  depends_on = [null_resource.init_sql, docker_container.ulake_service_log, docker_container.ulake_service_core, docker_container.ulake_service_folder]

  entrypoint = [
    "/home/ulake-service-dashboard-runner"
  ]

  env = [
    "MYSQL_ROOT_PASSWORD=root"
  ]

  volumes {
    host_path      = abspath("${path.module}/../../dashboard/build/dashboard-1.0.0-runner")
    container_path = "/home/ulake-service-dashboard-runner"
    read_only      = true
  }

  networks_advanced {
    name    = docker_network.ulake_network.name
    aliases = ["ulake-service-dashboard"]
  }
}

resource "docker_container" "ulake_service_folder" {
  name    = "ulake-service-folder-${count.index}"
  image   = docker_image.ulake_microservices_native.image_id
  restart = "unless-stopped"

  count = var.folder_service_count

  depends_on = [null_resource.init_sql, docker_container.ulake_service_log, docker_container.ulake_service_acl]

  entrypoint = [
    "/home/ulake-service-folder-runner"
  ]

  env = [
    "MYSQL_ROOT_PASSWORD=root"
  ]

  volumes {
    host_path      = abspath("${path.module}/../../folder/build/folder-1.0.0-SNAPSHOT-runner")
    container_path = "/home/ulake-service-folder-runner"
    read_only      = true
  }

  networks_advanced {
    name    = docker_network.ulake_network.name
    aliases = ["ulake-service-folder"]
  }
}

resource "docker_container" "ulake_service_acl" {
  name    = "ulake-service-acl-${count.index}"
  image   = docker_image.ulake_microservices_native.image_id
  restart = "unless-stopped"

  count = var.acl_service_count

  depends_on = [null_resource.init_sql, docker_container.ulake_service_log]

  entrypoint = [
    "/home/ulake-service-acl-runner"
  ]

  env = [
    "MYSQL_ROOT_PASSWORD=root"
  ]

  volumes {
    host_path      = abspath("${path.module}/../../acl/build/acl-1.0.0-SNAPSHOT-runner")
    container_path = "/home/ulake-service-acl-runner"
    read_only      = true
  }

  networks_advanced {
    name    = docker_network.ulake_network.name
    aliases = ["ulake-service-acl"]
  }
}

resource "docker_container" "ulake_service_core" {
  name    = "ulake-service-core-${count.index}"
  image   = docker_image.ulake_microservices_native.image_id
  restart = "unless-stopped"

  count = var.core_service_count

  depends_on = [null_resource.init_sql]

  entrypoint = [
    "/home/ulake-service-core-runner"
  ]

  env = [
    "MYSQL_ROOT_PASSWORD=root"
  ]

  volumes {
    host_path      = abspath("${path.module}/../../core/build/core-1.0.0-SNAPSHOT-runner")
    container_path = "/home/ulake-service-core-runner"
    read_only      = true
  }

  networks_advanced {
    name    = docker_network.ulake_network.name
    aliases = ["ulake-service-core"]
  }
}

resource "docker_container" "ulake_service_admin" {
  name    = "ulake-service-admin-${count.index}"
  image   = docker_image.ulake_microservices_native.image_id
  restart = "unless-stopped"

  count = var.admin_service_count

  depends_on = [null_resource.init_sql]

  entrypoint = [
    "/home/ulake-service-admin-runner"
  ]

  env = [
    "MYSQL_ROOT_PASSWORD=root"
  ]

  volumes {
    host_path      = abspath("${path.module}/../../admin/build/admin-1.0.0-SNAPSHOT-runner")
    container_path = "/home/ulake-service-admin-runner"
    read_only      = true
  }

  networks_advanced {
    name    = docker_network.ulake_network.name
    aliases = ["ulake-service-admin"] # The network aliases of the container in the specific network.
  }
}