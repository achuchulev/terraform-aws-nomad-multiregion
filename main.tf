// ************* GLOBAL Part ************* //

# generate a new private CA
resource "null_resource" "generate_self_ca" {
  provisioner "local-exec" {
    command = "${path.root}/scripts/gen_self_ca.sh .terraform/modules/nomad_cluster_on_aws_a/ca_certs .terraform/modules/nomad_cluster_on_aws_b/ca_certs"
  }
}

# generate a new secure gossip encryption key
resource "random_id" "server_gossip" {
  byte_length = 16
}

// ************* Networking ************* //

# Module that creates new VPC with one Public and one or more Private subnets on AWS
module "new_aws_vpc_a" {
  source = "git@github.com:achuchulev/terraform-aws-vpc-natgw.git"

  aws_access_key = var.access_key
  aws_secret_key = var.secret_key
  aws_region     = var.aws_region_a

  vpc_cidr_block         = var.vpc_cidr_block_a
  vpc_subnet_cidr_blocks = var.vpc_subnet_cidr_blocks_a

  vpc_tags = {
    Name = var.vpc_tag_name
    Side = var.vpc_tag_side_a
  }
}

# Module that creates new VPC with one Public and one or more Private subnets on AWS
module "new_aws_vpc_b" {
  source = "git@github.com:achuchulev/terraform-aws-vpc-natgw.git"

  aws_access_key = var.access_key
  aws_secret_key = var.secret_key
  aws_region     = var.aws_region_b

  vpc_cidr_block         = var.vpc_cidr_block_b
  vpc_subnet_cidr_blocks = var.vpc_subnet_cidr_blocks_b

  vpc_tags = {
    Name = var.vpc_tag_name
    Side = var.vpc_tag_side_b
  }
}

# Module that creates new VPC Peering between AWS RegionA <-> AWS RegionB
module "aws_vpc_peering" {
  source = "git@github.com:achuchulev/terraform-aws-vpc-peering.git"

  accepter_aws_access_key  = var.access_key
  accepter_aws_secret_key  = var.secret_key
  accepter_region          = var.aws_region_a
  accepter_vpc_id          = module.new_aws_vpc_a.vpc_id
  requester_aws_access_key = var.access_key
  requester_aws_secret_key = var.secret_key
  requester_region         = var.aws_region_b
  requester_vpc_id         = module.new_aws_vpc_b.vpc_id
}

# Module to create Client VPN
module "aws_client_vpn" {
  source = "git@github.com:achuchulev/terraform-aws-client-vpn-endpoint.git"

  aws_access_key = var.access_key
  aws_secret_key = var.secret_key
  aws_region     = var.aws_region_a
  subnet_id      = module.new_aws_vpc_a.subnet_ids[0]
  domain         = var.cloudflare_zone
}

// ************* NOMAD compute ************* //

# Module that creates Nomad cluster (servers/clients/frontend) on AWS Region A
module "nomad_cluster_on_aws_a" {
  source = "git@github.com:achuchulev/terraform-aws-nomad.git"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  region                     = var.aws_region_a
  ami_nomad_server           = var.ami_nomad_server_a
  ami_nomad_client           = var.ami_nomad_client_a
  ami_frontend               = var.ami_frontend_a
  aws_vpc_id                 = module.new_aws_vpc_a.vpc_id
  frontend_subnet_id         = module.new_aws_vpc_a.subnet_ids[0]
  server_subnet_id           = module.new_aws_vpc_a.subnet_ids[1]
  client_subnet_id           = module.new_aws_vpc_a.subnet_ids[1]
  secure_gossip              = random_id.server_gossip.b64_std
  cloudflare_email           = var.cloudflare_email
  cloudflare_token           = var.cloudflare_token
  cloudflare_zone            = var.cloudflare_zone
  subdomain_name             = var.aws_subdomain_name_a
  private_subnet_with_nat_gw = "true"
  dc                         = var.aws_region_a
  nomad_region               = var.nomad_region_aws_a
  authoritative_region       = var.authoritative_region
}

# Module that creates Nomad cluster (servers/clients/frontend) on AWS Region B
module "nomad_cluster_on_aws_b" {
  source = "git@github.com:achuchulev/terraform-aws-nomad.git"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  region                     = var.aws_region_b
  ami_nomad_server           = var.ami_nomad_server_b
  ami_nomad_client           = var.ami_nomad_client_b
  ami_frontend               = var.ami_frontend_b
  aws_vpc_id                 = module.new_aws_vpc_b.vpc_id
  frontend_subnet_id         = module.new_aws_vpc_b.subnet_ids[0]
  server_subnet_id           = module.new_aws_vpc_b.subnet_ids[1]
  client_subnet_id           = module.new_aws_vpc_b.subnet_ids[1]
  secure_gossip              = random_id.server_gossip.b64_std
  cloudflare_email           = var.cloudflare_email
  cloudflare_token           = var.cloudflare_token
  cloudflare_zone            = var.cloudflare_zone
  subdomain_name             = var.aws_subdomain_name_b
  private_subnet_with_nat_gw = "true"
  dc                         = var.aws_region_b
  nomad_region               = var.nomad_region_aws_b
  authoritative_region       = var.authoritative_region
}

// ************* NOMAD Cluster Federetaion ************* //

resource "null_resource" "nomad_federation_aws" {
  depends_on = [
    module.nomad_cluster_on_aws_a,
    module.nomad_cluster_on_aws_b,
    module.aws_vpc_peering
  ]

  provisioner "local-exec" {
    command = "${path.root}/scripts/nomad_federation.sh ${module.nomad_cluster_on_aws_a.ui_url} ${module.nomad_cluster_on_aws_b.server_private_ips[0]}"
  }
}
