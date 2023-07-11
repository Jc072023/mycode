
provider "docker" {}

provider "random" {}

provider "time" {}

resource "docker_image" "nginx" {
  name         = "nginx:1.23.4"
  keep_locally = true
}

resource "random_pet" "nginx" {
  length = 2
}

resource "docker_container" "nginx" {
  count = 4
  image = docker_image.nginx.image_id
  name  = "nginx-${random_pet.nginx.id}-${count.index}"
  
  ports {
    internal = 80
    external = 8000 + count.index
  }
}

resource "docker_image" "redis" {
  name         = "redis:7.0.11"
  keep_locally = true
}

resource "time_sleep" "wait_120_seconds" {
 depends_on = [docker_image.redis]

 create_duration = "120s"
}

resource "docker_container" "data" {

  depends_on = [time_sleep.wait_120_seconds]
  image      = docker_image.redis.image_id
  name       = "data"

  ports {
    internal = 6379
    external = 6379
  }
}


