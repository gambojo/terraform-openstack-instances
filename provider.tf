terraform {
  backend "s3" {
    endpoint = "http://minio-api01.apps.k8s-1.cp.dev.cldx.ru"
    bucket = "terraform"
    region = "us-east-1"
    key    = "gama/terraform.tfstate"

    access_key = "65vUNEJv3hW3p499uueU"
    secret_key = "jzHDtyOe6ZJspxwVypf2THchm7BEp1jJ1qskz1KB"

    skip_region_validation      = true
    skip_credentials_validation = true
    force_path_style            = true 
    skip_metadata_api_check     = true
  }

  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

provider "openstack" {
  insecure = true
}
