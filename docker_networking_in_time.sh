#!/bin/bash

# Update package lists and install required tools
sudo apt-get update && sudo apt-get install -y bridge-utils iptables net-tools tcpdump 

# Create bridge interface
sudo ip link add name br0 type bridge 

# Assign IP address to the bridge
sudo ip addr add 192.168.1.1/24 dev br0 

# Bring up the bridge interface
sudo ip link set dev br0 up 

# Create Docker network with the bridge interface
sudo docker network create --driver=bridge --subnet=192.168.1.0/24 --gateway=192.168.1.1 br0 

# Launch container 1 with assigned IP
sudo ip link add name veth1 type veth peer name veth2
sudo ip link set veth1 up
sudo ip link set veth2 up
sudo docker run -d --name nginx_container1 --network=br0 --ip=192.168.1.10 nginx
sudo docker network connect br0 container1
sudo ip addr add dev veth1 192.168.1.10/24
sudo ip link set veth1 master br0

# Launch container 2 with assigned IP
sudo ip link add name veth3 type veth peer name veth4
sudo ip link set veth3 up
sudo ip link set veth4 up
sudo docker run -d --name nginx_container2 --network=br0 --ip= 192.168.1.11 nginx
sudo docker network connect br0 container2
sudo ip addr add dev veth3 192.168.1.11/24
sudo ip link set veth3 master br0


# Set up NAT for traffic forwarding (optional, adjust based on the environment)
sudo iptables -t nat -L -n -v                                         # Checking the iptables rules
sudo iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j MASQUERADE   # Enable NAT for internet connectivity

# Verify connectivity between containers
sudo docker exec nginx_container1 ping -c 3  192.168.1.11 
sudo docker exec nginx_container1 ping -c 3  8.8.8.8
sudo docker exec nginx_container2 ping -c 3  192.168.1.10 
sudo docker exec nginx_container2 ping -c 3  8.8.8.8
