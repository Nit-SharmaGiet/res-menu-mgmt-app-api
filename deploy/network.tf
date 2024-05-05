resource "aws_vpc" "main" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.prefix}-vpc"
      }
    )
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.prefix}-main"
      }
    )
  )

}

##########################################
#Public configs: 
#public_a: 10.1.1.0/24 subnet, aws_route table, aws_route_table_association, aws_route to public, aws_eip, aws_nat_gateway
#public_b: 10.1.2.0/24 subnet, aws_route table, aws_route_table_association, aws_route to public, aws_eip, aws_nat_gateway
##########################################

#public_a start:
resource "aws_subnet" "public_a" {
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${data.aws_region.current.name}a"

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.prefix}-public-a"
      }
    )
  )
}

resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.prefix}-public-a"
      }
    )
  )
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_a.id
}

resource "aws_route" "public_internet_access_a" {
  route_table_id         = aws_route_table.public_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_eip" "public_a" {
  #vpc = true

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.prefix}-public-a"
      }
    )
  )
}

resource "aws_nat_gateway" "public_a" {
  allocation_id = aws_eip.public_a.id
  subnet_id     = aws_subnet.public_a.id

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.prefix}-public-a"
      }
    )
  )
}

#public_b start:
resource "aws_subnet" "public_b" {
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${data.aws_region.current.name}b"

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.prefix}-public-b"
      }
    )
  )
}

resource "aws_route_table" "public_b" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.prefix}-public-b"
      }
    )
  )
}


resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_b.id
}

resource "aws_route" "public_internet_access_b" {
  route_table_id         = aws_route_table.public_b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_eip" "public_b" {
  #vpc = true

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.prefix}-public-b"
      }
    )
  )
}

resource "aws_nat_gateway" "public_b" {
  allocation_id = aws_eip.public_b.id
  subnet_id     = aws_subnet.public_b.id

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.prefix}-public-b"
      }
    )
  )
}
