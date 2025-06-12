terraform {
  backend "s3" {
    bucket         = "tf-multi-account-111111111111"
    key            = "networking/vpc/terraform.tfstate"
    region         = "us-west-2"
    use_lockfile   = true
    encrypt        = true
  }
}
