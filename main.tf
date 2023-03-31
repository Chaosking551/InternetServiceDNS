variable "openstack_username"{
	type = string
}

variable "openstack_password"{
	type = string
}

variable "public_network_id"{
	type = string
	default = "c5ed0f0a-57ca-4b0b-884b-0c1944573650"
}

variable "backup_flavor"{
	type = string
}


#define credentials
locals {
	auth_url = "https://private-cloud.informatik.hs-fulda.de:5000/v3"
	user_name = "${var.openstack_username}"
	user_password = "${var.openstack_password}"
	tenant_name = "${var.openstack_username}"
	#network_name  = "${var.openstack_username}-net"
	router_name   = "${var.openstack_username}-router"
	image_name    = "Ubuntu 20.04 - Focal Fossa - 64-bit - Cloud Based Image"
	flavor_name   = "m1.small"
	region_name   = "RegionOne"
}


#define provider
terraform {
	required_version = ">= 0.14.0"
	required_providers {
		openstack = {
			source  = "terraform-provider-openstack/openstack"
			version = ">= 1.46.0"
		}
	}
}


#configure provider
provider "openstack" {
	user_name = local.user_name
	tenant_name = local.tenant_name
	password = local.user_password
	auth_url = local.auth_url
	region = local.region_name
	use_octavia = true
}


#create keypair
resource "openstack_compute_keypair_v2" "terraform-keypair" {
	name = "ssh_keypair"
	public_key = file("/sshkey/server-pub.txt")
}


#create security groups
resource "openstack_networking_secgroup_v2" "backup_security_group" {
	name = "backup"
	description = "Group for Backup/Monitor-Server"
}

resource "openstack_networking_secgroup_rule_v2" "backup_secgroup-rule_ssh" {
	direction = "ingress"
	ethertype = "IPv4"
	protocol = "tcp"
	port_range_min = 22
	port_range_max = 22
	security_group_id = openstack_networking_secgroup_v2.backup_security_group.id
}

resource "openstack_networking_secgroup_rule_v2" "backup_secgroup-rule_monitor" {
	direction = "ingress"
	ethertype = "IPv4"
	protocol = "tcp"
	port_range_min = 9090
	port_range_max = 9090
	security_group_id = openstack_networking_secgroup_v2.backup_security_group.id
}

resource "openstack_networking_secgroup_v2" "dns_security_group"{
	name = "DNS"
	description = "Group for DNS/WEB-Servers"
}

resource "openstack_networking_secgroup_rule_v2" "dns_secgroup-rule_monitor" {
	direction = "ingress"
	ethertype = "IPv4"
	protocol = "tcp"
	port_range_min = 9100
	port_range_max = 9100
	remote_ip_prefix = "192.168.2.0/24"
	security_group_id = openstack_networking_secgroup_v2.dns_security_group.id
}

resource "openstack_networking_secgroup_rule_v2" "dns_secgroup-rule_http" {
	direction = "ingress"
	ethertype = "IPv4"
	protocol = "tcp"
	port_range_min = 80
	port_range_max = 80
	security_group_id = openstack_networking_secgroup_v2.dns_security_group.id
}

resource "openstack_networking_secgroup_rule_v2" "dns_secgroup-rule_https" {
	direction = "ingress"
	ethertype = "IPv4"
	protocol = "tcp"
	port_range_min = 443
	port_range_max = 443
	security_group_id = openstack_networking_secgroup_v2.dns_security_group.id
}

resource "openstack_networking_secgroup_rule_v2" "dns_secgroup-rule_dns" {
	direction = "ingress"
	ethertype = "IPv4"
	protocol = "udp"
	port_range_min = 53
	port_range_max = 53
	security_group_id = openstack_networking_secgroup_v2.dns_security_group.id
}

resource "openstack_networking_secgroup_rule_v2" "dns_secgroup-rule_ssh" {
	direction = "ingress"
	ethertype = "IPv4"
	protocol = "tcp"
	port_range_min = 22
	port_range_max = 22
	security_group_id = openstack_networking_secgroup_v2.dns_security_group.id
}

resource "openstack_networking_secgroup_v2" "db_security_group" {
	name = "DB"
	description = "Group for DB-Servers"
}

resource "openstack_networking_secgroup_rule_v2" "db_secgroup-rule_monitor" {
	direction = "ingress"
	ethertype = "IPv4"
	protocol = "tcp"
	port_range_min = 9100
	port_range_max = 9100
	remote_ip_prefix = "192.168.2.0/24"
	security_group_id = openstack_networking_secgroup_v2.db_security_group.id
}

resource "openstack_networking_secgroup_rule_v2" "db_secgroup-rule_mysql_backup" {
	direction = "ingress"
	ethertype = "IPv4"
	protocol = "tcp"
	port_range_min = 3306
	port_range_max = 3306
	remote_ip_prefix = "192.168.2.0/24"
	security_group_id = openstack_networking_secgroup_v2.db_security_group.id
}

resource "openstack_networking_secgroup_rule_v2" "db_secgroup-rule_mysql_web" {
	direction = "ingress"
	ethertype = "IPv4"
	protocol = "tcp"
	port_range_min = 3306
	port_range_max = 3306
	remote_ip_prefix = "192.168.0.0/24"
	security_group_id = openstack_networking_secgroup_v2.db_security_group.id
}

resource "openstack_networking_secgroup_rule_v2" "db_secgroup-rule_ssh" {
	direction = "ingress"
	ethertype = "IPv4"
	protocol = "tcp"
	port_range_min = 22
	port_range_max = 22
	security_group_id = openstack_networking_secgroup_v2.db_security_group.id
}


#create network
resource "openstack_networking_network_v2" "network_1" {
	name = "dns_network"
	admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
	name = "dns_subnet"
	network_id = openstack_networking_network_v2.network_1.id
	cidr = "192.168.0.0/24"
	ip_version = 4
}

resource "openstack_networking_subnet_v2" "subnet_2" {
	name = "db_subnet"
	network_id = openstack_networking_network_v2.network_1.id
	cidr = "192.168.1.0/24"
	ip_version = 4
}

resource "openstack_networking_subnet_v2" "subnet_3" {
	name = "backup_subnet"
	network_id = openstack_networking_network_v2.network_1.id
	cidr = "192.168.2.0/24"
	ip_version = 4
}

resource "openstack_networking_router_v2" "router_1" {
	name = local.router_name
	admin_state_up = true
	external_network_id = var.public_network_id
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
	router_id = openstack_networking_router_v2.router_1.id
	subnet_id = openstack_networking_subnet_v2.subnet_1.id
}

resource "openstack_networking_router_interface_v2" "router_interface_2" {
	router_id = openstack_networking_router_v2.router_1.id
	subnet_id = openstack_networking_subnet_v2.subnet_2.id
}

resource "openstack_networking_router_interface_v2" "router_interface_3" {
	router_id = openstack_networking_router_v2.router_1.id
	subnet_id = openstack_networking_subnet_v2.subnet_3.id
}


#create instances

resource "openstack_networking_port_v2" "port_1" {
	name               = "port_1"
	admin_state_up     = "true"
	network_id = openstack_networking_network_v2.network_1.id
	security_group_ids = [openstack_networking_secgroup_v2.dns_security_group.id]
	
	fixed_ip {
		subnet_id  = openstack_networking_subnet_v2.subnet_1.id
		ip_address = "192.168.0.9"
	}
}

resource "openstack_compute_instance_v2" "web_dns_1" {
	name = "web_dns_1"
	image_name = local.image_name
	flavor_name = local.flavor_name
	key_pair = openstack_compute_keypair_v2.terraform-keypair.name
	
	depends_on = [openstack_networking_subnet_v2.subnet_1]
	
	network {
		port = openstack_networking_port_v2.port_1.id
	}
	
	user_data = file("/cloud-init_DNS_WEB.sh")
}

resource "openstack_networking_port_v2" "port_2" {
	name               = "port_2"
	admin_state_up     = "true"
	network_id = openstack_networking_network_v2.network_1.id
	security_group_ids = [openstack_networking_secgroup_v2.dns_security_group.id]
	
	fixed_ip {
		subnet_id  = openstack_networking_subnet_v2.subnet_1.id
		ip_address = "192.168.0.10"
	}
}

resource "openstack_compute_instance_v2" "web_dns_2" {
	name = "web_dns_2"
	image_name = local.image_name
	flavor_name = local.flavor_name
	key_pair = openstack_compute_keypair_v2.terraform-keypair.name
	
	depends_on = [openstack_networking_subnet_v2.subnet_1]
	
	network {
		port = openstack_networking_port_v2.port_2.id
	}
	
	user_data = file("/cloud-init_DNS_WEB.sh")
}

resource "openstack_networking_port_v2" "port_3" {
	name               = "port_3"
	admin_state_up     = "true"
	network_id = openstack_networking_network_v2.network_1.id
	security_group_ids = [openstack_networking_secgroup_v2.db_security_group.id]

	fixed_ip {
		subnet_id  = openstack_networking_subnet_v2.subnet_2.id
		ip_address = "192.168.1.9"
	}
}

resource "openstack_compute_instance_v2" "db_serv_1" {
	name = "db_serv_1"
	image_name = local.image_name
	flavor_name = local.flavor_name
	key_pair = openstack_compute_keypair_v2.terraform-keypair.name
	
	depends_on = [openstack_networking_subnet_v2.subnet_2]
	
	network {
		port = openstack_networking_port_v2.port_3.id
	}
	
	user_data = file("/cloud-init_DB_1.sh")
}

resource "openstack_networking_port_v2" "port_4" {
	name               = "port_4"
	admin_state_up     = "true"
	network_id = openstack_networking_network_v2.network_1.id
	security_group_ids = [openstack_networking_secgroup_v2.db_security_group.id]

	fixed_ip {
		subnet_id  = openstack_networking_subnet_v2.subnet_2.id
		ip_address = "192.168.1.10"
	}
}

resource "openstack_compute_instance_v2" "db_serv_2" {
	name = "db_serv_2"
	image_name = local.image_name
	flavor_name = local.flavor_name
	key_pair = openstack_compute_keypair_v2.terraform-keypair.name
	
	depends_on = [openstack_networking_subnet_v2.subnet_2]
	
	network {
		port = openstack_networking_port_v2.port_4.id
	}
	
	user_data = file("/cloud-init_DB_2.sh")
}

resource "openstack_networking_port_v2" "port_5" {
	name               = "port_5"
	admin_state_up     = "true"
	network_id = openstack_networking_network_v2.network_1.id
	security_group_ids = [openstack_networking_secgroup_v2.backup_security_group.id]

	fixed_ip {
		subnet_id  = openstack_networking_subnet_v2.subnet_3.id
	}
}

resource "openstack_compute_instance_v2" "backup_monitor" {
	name = "backup_monitor"
	image_name = local.image_name
	flavor_name = var.backup_flavor
	key_pair = openstack_compute_keypair_v2.terraform-keypair.name
	
	depends_on = [openstack_networking_subnet_v2.subnet_3]
	
	network {
		port = openstack_networking_port_v2.port_5.id
	}
	
	user_data = file("/cloud-init_backup.sh")
}



#create loadbalancer
resource "openstack_lb_loadbalancer_v2" "dns_balancer"{
	name = "dns-balancer"
	vip_subnet_id = openstack_networking_subnet_v2.subnet_1.id
}

resource "openstack_lb_listener_v2" "listener_http" {
	protocol = "HTTP"
	protocol_port = 80
	loadbalancer_id = openstack_lb_loadbalancer_v2.dns_balancer.id
	connection_limit = 1024
}

resource "openstack_lb_listener_v2" "listener_dns" {
	protocol = "UDP"
	protocol_port = 53
	loadbalancer_id = openstack_lb_loadbalancer_v2.dns_balancer.id
	connection_limit = 1024
}

resource "openstack_lb_pool_v2" "http_pool" {
	protocol = "HTTP"
	lb_method = "ROUND_ROBIN"
	listener_id = openstack_lb_listener_v2.listener_http.id
}

resource "openstack_lb_members_v2" "members_http" {
	pool_id = openstack_lb_pool_v2.http_pool.id
	
	member {
		address = openstack_compute_instance_v2.web_dns_1.access_ip_v4
		protocol_port = 80
	}
	
	member {
		address = openstack_compute_instance_v2.web_dns_2.access_ip_v4
		protocol_port = 80
	}
}

resource "openstack_lb_pool_v2" "dns_pool" {
	protocol = "UDP"
	lb_method = "ROUND_ROBIN"
	listener_id = openstack_lb_listener_v2.listener_dns.id
}

resource "openstack_lb_members_v2" "members_dns" {
	pool_id = openstack_lb_pool_v2.dns_pool.id
	
	member {
		address = openstack_compute_instance_v2.web_dns_1.access_ip_v4
		protocol_port = 53
	}
	
	member {
		address = openstack_compute_instance_v2.web_dns_2.access_ip_v4
		protocol_port = 53
	}
}


resource "openstack_lb_loadbalancer_v2" "db_balancer"{
	name = "db-balancer"
	vip_subnet_id = openstack_networking_subnet_v2.subnet_2.id
}

resource "openstack_lb_listener_v2" "listener_db" {
	protocol = "TCP"
	protocol_port = 3306
	loadbalancer_id = openstack_lb_loadbalancer_v2.dns_balancer.id
	connection_limit = 1024
}

resource "openstack_lb_pool_v2" "db_pool" {
	protocol = "TCP"
	lb_method = "ROUND_ROBIN"
	listener_id = openstack_lb_listener_v2.listener_db.id
}

resource "openstack_lb_members_v2" "members_db" {
	pool_id = openstack_lb_pool_v2.db_pool.id
	
	member {
		address = openstack_compute_instance_v2.db_serv_1.access_ip_v4
		protocol_port = 3306
	}
	
	member {
		address = openstack_compute_instance_v2.db_serv_2.access_ip_v4
		protocol_port = 3306
	}
}


#assign floating ip
resource "openstack_networking_floatingip_v2" "dns_ip"{
	pool = "public1"
	port_id = openstack_lb_loadbalancer_v2.dns_balancer.vip_port_id
}

resource "openstack_networking_floatingip_v2" "db_ip"{
	pool = "public1"
	port_id = openstack_lb_loadbalancer_v2.db_balancer.vip_port_id
}

resource "openstack_networking_floatingip_v2" "db_fip"{
	pool = "public1"
}

resource "openstack_compute_floatingip_associate_v2" "db_fip" {
  floating_ip = openstack_networking_floatingip_v2.db_fip.address
  instance_id = openstack_compute_instance_v2.db_serv_1.id
}

resource "openstack_networking_floatingip_v2" "backup_ip"{
	pool = "public1"
}

resource "openstack_compute_floatingip_associate_v2" "web_dns_1" {
  floating_ip = openstack_networking_floatingip_v2.backup_ip.address
  instance_id = openstack_compute_instance_v2.web_dns_1.id
}

resource "time_sleep" "wait_beforFirstConnect" {
	depends_on = [openstack_compute_instance_v2.web_dns_1]
	create_duration = "180s"
}

resource "time_sleep" "changeDBConfig_1" {
	depends_on = [openstack_compute_floatingip_associate_v2.web_dns_1, time_sleep.wait_beforFirstConnect]
	create_duration = "10s"
	
	provisioner "remote-exec" {
		connection {
			type     = "ssh"
			user     = "ubuntu"
			private_key = file("/sshkey/private-key.pem")
			host = openstack_networking_floatingip_v2.backup_ip.address
		}
	
		inline = [
			"bash /home/ubuntu/changeDBConfig.sh ${openstack_networking_floatingip_v2.db_ip.address}",
		]
  }
}

resource "time_sleep" "wait_afterFirst" {
	depends_on = [time_sleep.changeDBConfig_1]
	create_duration = "10s"
}

resource "openstack_compute_floatingip_associate_v2" "web_dns_2" {
  floating_ip = openstack_networking_floatingip_v2.backup_ip.address
  instance_id = openstack_compute_instance_v2.web_dns_2.id
  depends_on = [time_sleep.wait_afterFirst]
}

resource "time_sleep" "changeDBConfig_2" {
	depends_on = [openstack_compute_floatingip_associate_v2.web_dns_2, openstack_compute_instance_v2.web_dns_2]
	create_duration = "10s"
	
	provisioner "remote-exec" {
		connection {
			type     = "ssh"
			user     = "ubuntu"
			private_key = file("/sshkey/private-key.pem")
			host = openstack_networking_floatingip_v2.backup_ip.address
		}
	
		inline = [
			"bash /home/ubuntu/changeDBConfig.sh ${openstack_networking_floatingip_v2.db_ip.address}",
		]
  }
}

resource "time_sleep" "wait_afterSecond" {
	depends_on = [time_sleep.changeDBConfig_2]
	create_duration = "10s"
}

resource "openstack_compute_floatingip_associate_v2" "fip_backup" {
  floating_ip = openstack_networking_floatingip_v2.backup_ip.address
  instance_id = openstack_compute_instance_v2.backup_monitor.id
  depends_on = [time_sleep.wait_afterSecond]
}

resource "time_sleep" "changeDBIP" {
	depends_on = [openstack_compute_floatingip_associate_v2.fip_backup, openstack_compute_instance_v2.backup_monitor]
	create_duration = "10s"
	
	provisioner "remote-exec" {
		connection {
			type     = "ssh"
			user     = "ubuntu"
			private_key = file("/sshkey/private-key.pem")
			host = openstack_networking_floatingip_v2.backup_ip.address
		}
	
		inline = [
			"bash /home/ubuntu/changeDBIP.sh ${openstack_networking_floatingip_v2.db_ip.address}",
		]
  }
}

output "loadbalancer_dns_addr" {
	value = openstack_networking_floatingip_v2.dns_ip
}

output "loadbalancer_db_addr" {
	value = openstack_networking_floatingip_v2.db_ip
}

output "backup_addr" {
	value = openstack_networking_floatingip_v2.backup_ip
}

output "db_init_addr" {
	value = openstack_networking_floatingip_v2.db_fip
}