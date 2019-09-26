// AWS Part outs

# NW AWS A

output "aws_a_vpc_id" {
  value = module.new_aws_vpc_a.vpc_id
}

output "aws_a_vpc_name" {
  value = module.new_aws_vpc_a.vpc_name
}


output "aws_a_subnet_ids" {
  value = module.new_aws_vpc_a.subnet_ids
}

# NW AWS B

output "aws_b_vpc_id" {
  value = module.new_aws_vpc_b.vpc_id
}

output "aws_b_vpc_name" {
  value = module.new_aws_vpc_b.vpc_name
}


output "aws_b_subnet_ids" {
  value = module.new_aws_vpc_b.subnet_ids
}


# Nomad AWS A

output "aws_a_server_private_ips" {
  value = module.nomad_cluster_on_aws_a.server_private_ips
}

output "aws_a_client_private_ips" {
  value = module.nomad_cluster_on_aws_a.client_private_ips
}

output "aws_a_frontend_public_ip" {
  value = module.nomad_cluster_on_aws_a.frontend_public_ip
}

output "AWS_A_Nomad_UI_URL" {
  value = module.nomad_cluster_on_aws_a.ui_url
}


# Nomad AWS B

output "aws_b_server_private_ips" {
  value = module.nomad_cluster_on_aws_b.server_private_ips
}

output "aws_b_client_private_ips" {
  value = module.nomad_cluster_on_aws_b.client_private_ips
}

output "aws_b_frontend_public_ip" {
  value = module.nomad_cluster_on_aws_b.frontend_public_ip
}

output "AWS_B_Nomad_UI_URL" {
  value = module.nomad_cluster_on_aws_b.ui_url
}

# Client VPN

output "client_vpn_id" {
  value = module.aws_client_vpn.client_vpn_endpoint_id
}
