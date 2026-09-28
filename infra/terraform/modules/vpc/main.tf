data "aws_region" "current" {}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  nat_gateway_count = var.enable_nat_gateway ? (
    var.single_nat_gateway ? 1 : length(var.availability_zones)
  ) : 0
}

resource "aws_vpc" "this" {
  #checkov:skip=CKV2_AWS_11:VPC Flow Logs are deferred to the centralized monitoring phase; production environments must enable network-flow logging.
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  ingress = []
  egress  = []

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-default-sg"
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-igw"
    }
  )
}

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.availability_zones[count.index]
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    local.common_tags,
    {
      Name                     = "${local.name_prefix}-public-${var.availability_zones[count.index]}"
      Tier                     = "public"
      "kubernetes.io/role/elb" = "1"
    }
  )
}

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.availability_zones[count.index]
  cidr_block              = var.private_subnet_cidrs[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    local.common_tags,
    {
      Name                              = "${local.name_prefix}-private-${var.availability_zones[count.index]}"
      Tier                              = "private"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-rt"
      Tier = "public"
    }
  )
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count = local.nat_gateway_count

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-eip-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = local.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id

  subnet_id = aws_subnet.public[
    var.single_nat_gateway ? 0 : count.index
  ].id

  connectivity_type = "public"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "private" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-rt-${var.availability_zones[count.index]}"
      Tier = "private"
    }
  )
}

resource "aws_route" "private_nat" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.this[
    var.single_nat_gateway ? 0 : count.index
  ].id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_gateway_endpoint ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = aws_route_table.private[*].id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-s3-endpoint"
    }
  )
}