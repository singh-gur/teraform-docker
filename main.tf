terraform {
  backend "s3" {
    key = "terraform.tfstate"
  }

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}


variable "minio_endpoint" {
  description = "MinIO S3 endpoint URL"
  type        = string
  default     = "https://s3.gsingh.io"
}

variable "minio_bucket" {
  description = "MinIO bucket name for Terraform state"
  type        = string
  default     = "terraform-state"
}

variable "minio_access_key" {
  description = "MinIO access key"
  type        = string
  sensitive   = true
}

variable "minio_secret_key" {
  description = "MinIO secret key"
  type        = string
  sensitive   = true
}

provider "docker" {}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "tutorial"

  ports {
    internal = 80
    external = 8095
  }
}
