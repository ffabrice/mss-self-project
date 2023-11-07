# Capture tunnel1 adress
output "tunnel1_address" {
    value = aws_vpn_connection.aws-vpnco-tf-sell.tunnel1_address
}

# Capture tunnel1 cgw inside adress
output "tunnel1_cgw_inside_address" {
    value = aws_vpn_connection.aws-vpnco-tf-sell.tunnel1_cgw_inside_address
}

# Capture 
output "tunnel1_inside_cidr" {
    value = aws_vpn_connection.aws-vpnco-tf-sell.tunnel1_inside_cidr 
}

# Capture 
output "tunnel1_preshared_key" {
    value = aws_vpn_connection.aws-vpnco-tf-sell.tunnel1_preshared_key
    sensitive = true
}

# Capture tunnel1 vgw inside adress
output "tunnel1_vgw_inside_address" {
    value = aws_vpn_connection.aws-vpnco-tf-sell.tunnel1_vgw_inside_address
}

# Capture tunnel2 adress
output "tunnel2_address" {
    value = aws_vpn_connection.aws-vpnco-tf-sell.tunnel2_address
}

# Capture tunnel2 cgw inside adress
output "tunnel2_cgw_inside_address" {
    value = aws_vpn_connection.aws-vpnco-tf-sell.tunnel2_cgw_inside_address
}

# Capture tunnel2 inside cidr
output "tunnel2_inside_cidr" {
    value = aws_vpn_connection.aws-vpnco-tf-sell.tunnel2_inside_cidr 
}

# Capture tunnel2 preshared key
output "tunnel2_preshared_key" {
    value = aws_vpn_connection.aws-vpnco-tf-sell.tunnel2_preshared_key
    sensitive = true
}

# Capture tunnel2 vgw inside adress
output "tunnel2_vgw_inside_address" {
    value = aws_vpn_connection.aws-vpnco-tf-sell.tunnel2_vgw_inside_address
}

# Capture VPN ID
output "aws_vpn_connection_id" {
    value = aws_vpn_connection.aws-vpnco-tf-sell.id
}
