# Openstack

[TOC]

---

## MicroStack

<https://opendev.org/x/microstack>

Single-machine, snap-deployed OpenStack cloud.

Services provided: Nova, Keystone, Glance, Horizon and Neutron.

### Installation

We are going to install from the *edge* channel:

```sh
sudo snap install microstack --devmode --edge
```

Initialisation will set up databases, networks, flavors, and SSH keypair, a CirrOS image, and open ICMP/SSH security groups:

```sh
sudo microstack.init --auto
```

### Uninstall

```sh
sudo microstack.remove --auto --purge
```

We can also use *snap remove*. The Open vSwitch bridge will be cleaned up and will desappear the next time you reboot your system.

### Firewall configuration

<https://gist.github.com/kimus/9315140>

#### NAT
If you needed ufw to NAT the connections from the external interface to the internal the solution is pretty straight forward.
In the file /etc/default/ufw change the parameter DEFAULT_FORWARD_POLICY

```text
DEFAULT_FORWARD_POLICY="ACCEPT"
```

Also configure /etc/ufw/sysctl.conf to allow ipv4 forwarding (the parameters is commented out by default). Uncomment for ipv6 if you want.

```text
net.ipv4.ip_forward=1
#net/ipv6/conf/default/forwarding=1
#net/ipv6/conf/all/forwarding=1
```

The final step is to add NAT to ufw’s configuration. Add the following to /etc/ufw/before.rules just before the filter rules.

```text
# NAT table rules
*nat
:POSTROUTING ACCEPT [0:0]

# Forward traffic through eth0 - Change to match you out-interface
-A POSTROUTING -s 192.168.1.0/24 -o eth0 -j MASQUERADE

# don't delete the 'COMMIT' line or these nat table rules won't
# be processed
COMMIT
```

Now enable the changes by restarting ufw.

```text
$ sudo ufw disable && sudo ufw enable
```

#### FORWARD

For port forwardind just do something like this.

```text
# NAT table rules
*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]

# Port Forwardings
-A PREROUTING -i eth0 -p tcp --dport 22 -j DNAT --to-destination 192.168.1.10

# Forward traffic through eth0 - Change to match you out-interface
-A POSTROUTING -s 192.168.1.0/24 -o eth0 -j MASQUERADE

# don't delete the 'COMMIT' line or these nat table rules won't
# be processed
COMMIT
```

### Openstack client installation

<https://docs.openstack.org/python-ironicclient/pike/cli/osc_plugin_cli.html>

In order to use OpenStack CLI you have to install OpenStack Client:

```sh
pip install python-openstackclient
```

To use the CLI, you must provide your OpenStack username, password, project, and auth endpoint. You can use configuration options --os-username, --os-password, --os-project-id (or --os-project-name), and --os-auth-url, or set the corresponding environment variables:

```sh
export OS_USERNAME=user
export OS_PASSWORD=password
export OS_PROJECT_NAME=project
export OS_PROJECT_DOMAIN_ID=default
export OS_USER_DOMAIN_ID=default
export OS_IDENTITY_API_VERSION=3
export OS_AUTH_URL=http://auth.example.com:5000/v3
```

### Add route to access cloud VMs

In order to access cloud VMs from another machine in the LAN, you have to add a route:

```sh
sudo ip route add <cloud-lan>/24 via <openstack-host-ip> dev <interface-connected-to-lan>
```

### Usage

OpenStack client is bundled in *microstack.openstack*. For example:

```sh
microstack.openstack network list
microstack.openstack flavor list
microstack.openstack keypair list
microstack.openstack image list
microstack.openstack security group rule list
```

To create an instance:

```sh
sudo microstack.launch cirros --name test
```

Horizon dashboard credentials:

```text
username: admin
password: keystone
```

Add a new image:

```sh
wget https://cloud-images.ubuntu.com/releases/16.04/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img
microstack.openstack image create \
                     --public \
                     --disk-format qcow2 \
                     --container-formatfi bare \
                     --file ubuntu-16.04-server-cloudimg-amd64-disk1.img \
                     ubuntu1604
```

