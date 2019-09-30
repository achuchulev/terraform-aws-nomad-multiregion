# Terraform configuration to provision two Nomad clusters on AWS in two different Regions A &amp; B and make federation in-between

## High Level Overview

<img src="diagrams/aws-nomad-mutiregion.png" />

## How to deploy

#### Create `terraform.tfvars` file

```
// ******** NOMAD GLOBAL VARS ******** //

aws_region_a         = "aws-region-a"
aws_region_b         = "aws-region-b"
nomad_region_aws_a   = "aws.a"
nomad_region_aws_b   = "aws.b"
authoritative_region = "aws"

// ************  AWS VARS ************ //

access_key         = "aws_access_key"
secret_key         = "aws_secret_key"
ami_nomad_server_a = "server-ami-aws-a"
ami_nomad_client_a = "client-ami-aws-a"
ami_frontend_a     = "frontenmd-ami-aws-a"
ami_nomad_server_b = "server-ami-aws-b"
ami_nomad_client_b = "client-ami-aws-b"
ami_frontend_b     = "frontenmd-ami-aws-b"


// ********* CLOUDFLARE VARS ********* //

cloudflare_email     = "me@example.com"
cloudflare_token     = "your_cloudflare_token"
cloudflare_zone      = "example.com"
aws_subdomain_name_a = "nomad-aws-ui-a-001"
aws_subdomain_name_b = "nomad-aws-ui-b-001"
```

- For more details about all available input options read the readmes of module for
  - [AWS VPC](https://github.com/achuchulev/terraform-aws-vpc-natgw/blob/master/README.md)
  - [AWS VPC Peering](https://github.com/achuchulev/terraform-aws-vpc-peering/blob/master/README.md)
  - [AWS Client VPN](https://github.com/achuchulev/terraform-aws-client-vpn-endpoint/blob/master/README.md)
  - [AWS NOMAD Cluster](https://github.com/achuchulev/terraform-aws-nomad/blob/master/README.md)

#### Initialize terraform

```
terraform init
```

#### Generate Server and Client Certificates and Keys for the Client VPN Endpoint

Run `$ .terraform/modules/aws-client-vpn/scripts/gen_acm_cert.sh ./<cert_dir> <domain>`

- Script will:
  - make a `cert_dir` in the root
  - create private Certificate Authority (CA)
  - issue server certificate chain
  - issue client certificate chain
  
Note: This is based on official AWS tutorial described [here](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/authentication-authorization.html#mutual)

#### Deploy Nomad multicloud infrastructure

```
$ terraform plan
$ terraform apply
```

- `Terraform apply` will create:
  - install cfssl (Cloudflare's PKI and TLS toolkit)
  - generate selfsigned certificates for Nomad cluster
  - two VPC on AWS with one Public and one or more Private subnets with NAT GW in each region
  - VPC Peering between AWS VPC A and AWS VPC B
  - cient VPN Endpoint to the AWS VPC A
  - new instances on AWS Region A for server(3)/client(1)/frontend(1/0)
  - new instances on AWS Region B for server(3)/client(1)/frontend(1/0)
  - configure each of the frontend servers as a reverse proxy with nginx
  - automatically enable HTTPS for Nomad frontend with EFF's Certbot, deploying Let's Encrypt certificate
  - check for certificate expiration and automatically renew Let’s Encrypt certificate
  - create Nomad cluster federation between the clusters on GCP && AWS clouds

## To do

 - [] configure Nomad frontend with LB
 - [] expose public ip of LB only
  
## Access Nomad

#### via CLI

for example:

```
$ nomad node status
$ nomad server members
```

#### via WEB UI console

Open web browser, access nomad web console using your instance dns name as URL and verify that 
connection is secured and SSL certificate is valid  

## Run nomad job

#### via UI

- go to `jobs`
- click on `Run job`
- author a job in HCL/JSON format or paste the sample nomad job [nomad_jobs/nginx.hcl](https://github.com/achuchulev/terraform-aws-nomad-1dc-1region/blob/master/nomad_jobs/nginx.hcl) that run nginx on docker
- run `Plan`
- review `Job Plan` and `Run` it

#### via CLI

- Import vpn file `client-config.ovpn` into your preffered vpn client and connect.
- ssh to some of the nomad servers
- run a job

```
$ ssh ubuntu@nomad.server.ip
$ nomad job run [options] <job file>
```
