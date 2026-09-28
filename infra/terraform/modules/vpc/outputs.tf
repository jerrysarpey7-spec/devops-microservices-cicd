output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN of the VPC."
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "IPv4 CIDR block assigned to the VPC."
  value       = aws_vpc.this.cidr_block
}

output "availability_zones" {
  description = "Availability Zones used by the VPC."
  value       = var.availability_zones
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = aws_subnet.private[*].id
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables."
  value       = aws_route_table.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways."
  value       = aws_nat_gateway.this[*].id
}

output "nat_gateway_public_ips" {
  description = "Public IP addresses assigned to the NAT Gateways."
  value       = aws_eip.nat[*].public_ip
}

output "s3_gateway_endpoint_id" {
  description = "ID of the S3 Gateway Endpoint, or null when disabled."
  value       = try(aws_vpc_endpoint.s3[0].id, null)
}