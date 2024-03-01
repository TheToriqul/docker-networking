# Building Docker Networking from Scratch in a Limited Time (Enhanced)

This project demonstrates a more advanced approach to setting up a Docker network using a bridge interface with additional features like container names and optional NAT for internet access.

## Prerequisites

- Debian-based Linux distribution
- Docker installed and running
- Essential tools: bridge-utils, iptables, net-tools, tcpdump

## Usage

1. **Download the Script**: Download the script to your local machine.

2. **Make it Executable**: Ensure the script is executable by running the following command:

   ```bash
   chmod +x docker_networking_in_time.sh
   ```

3. **Execute the Script**: Run the script with sudo privileges:

   ```bash
   sudo ./docker_networking_in_time.sh
   ```

## Steps Performed by the Script

1. **Update package lists and install required tools:**
    * The script starts by updating package lists and installing essential tools:
        * `bridge-utils`: For managing bridge interfaces.
        * `iptables`: For firewall configuration (optional).
        * `net-tools`: For basic networking utilities.
        * `tcpdump`: For network traffic capturing (optional).

2. **Create bridge interface:**
    * `sudo ip link add name br0 type bridge` creates a new bridge interface named `br0`.

3. **Assign IP address to the bridge:**
    * `sudo ip addr add 192.168.1.1/24 dev br0` assigns the IP address `192.168.1.1` with a subnet mask of `/24` to the bridge interface.

4. **Bring up the bridge interface:**
    * `sudo ip link set dev br0 up` activates the bridge interface.

5. **Create Docker network with the bridge interface:**
    * `docker network create --driver=bridge --subnet=192.168.1.0/24 --gateway=192.168.1.1 br0` creates a Docker network named `br0` using the bridge driver, the specified subnet, and the bridge interface as the gateway.

6. **Launch container 1 with assigned IP:**
    * **Create veth pair:**
        * `ip link add name veth1 type veth peer name veth2` creates a pair of virtual ethernet interfaces (`veth1` and `veth2`) for container 1.
        * `ip link set veth1 up` and `ip link set veth2 up` bring up both interfaces.
    * **Run container:**
        * `docker run -d --name nginx_container1 --network=br0 --ip=192.168.1.10 nginx` launches a detached Nginx container named `nginx_container1` connected to the `br0` network with the static IP `192.168.1.10`.
        * `docker network connect br0 container1` explicitly connects the container to the network (optional, usually handled automatically).
    * **Attach veth interface to container and bridge:**
        * `ip addr add dev veth1 192.168.1.10/24` assigns the IP address and subnet to `veth1`.
        * `ip link set veth1 master br0` attaches `veth1` to the bridge interface, effectively connecting the container to the network.

7. **Launch container 2 with assigned IP (similar to container 1):**
    * Follow the same steps as for container 1, creating a veth pair (`veth3` and `veth4`), running a container named `nginx_container2` with IP `192.168.1.11`, and attaching `veth3` to the bridge.

8. **Optional: Set up NAT for traffic forwarding:**
    * The script includes an optional section for setting up NAT (Network Address Translation) using `iptables`. This allows containers to access the internet if your environment requires it. Adjust the configuration based on your specific network setup.

9. **Verify connectivity between containers:**
    * `docker exec nginx_container1 ping -c 3 192.168.1.11` and `docker exec nginx_container2 ping -c 3 192.168.1.10` commands check if the containers can ping each other, indicating successful network connectivity.

## Notes

- Ensure Docker is installed and running before executing the script.
- The script assumes a Debian-based Linux distribution. Adjust package installation commands if using a different distribution.
- Customize IP addresses and container names as needed.
- This script is for my educational purposes only. Exercise caution in production environments and ensure proper network security measures are in place.
- Consider alternative methods for internet access within containers depending on your specific needs and security requirements.