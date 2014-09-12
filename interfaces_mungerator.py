#!/usr/bin/python

import os
import re
import sys

interfacesfile = "/etc/network/interfaces"

MGMT_label = os.environ['MGMT_NETWORK_NAME']
VXLAN_label = os.environ['VXLAN_NETWORK_NAME']
STORAGE_label = os.environ['STORAGE_NETWORK_NAME']


interfaces_template = """# MODIFIED BY INTERFACES_MUNGERATOR
# Used by ifup(8) and ifdown(8). See the interfaces(5) manpage or
# /usr/share/doc/ifupdown/examples for more information.

# The loopback network interface
auto lo
iface lo inet loopback

# Label public
%(public_stanza)s

# Label private
%(private_stanza)s

# Label %(MGMT_label)s
auto %(mgmt_eth)s
iface %(mgmt_eth)s inet manual

auto br-mgmt
iface br-mgmt inet static
    bridge_stp off
    bridge_waitport 210
    bridge_fd 0
    bridge_ports %(mgmt_eth)s
    address 172.24.240.100
    netmask %(mgmt_netmask)s


# Label %(VXLAN_label)s
auto %(vxlan_eth)s
iface %(vxlan_eth)s inet manual

auto br-vxlan
iface br-vxlan inet static
    bridge_stp off
    brige_waitport 210
    bridge_fd 0
    bridge_ports %(vxlan_eth)s
    address 172.24.236.100
    netmask %(vxlan_netmask)s


# Label %(STORAGE_label)s
auto %(storage_eth)s
iface %(storage_eth)s inet manual

auto br-storage
iface br-storage inet static
    bridge_stp off
    bridge_waitport 210
    bridge_fd 0
    bridge_ports %(storage_eth)s
    address 172.24.244.100
    netmask %(storage_netmask)s

auto br-vlan
iface br-vlan inet manual
    bridge_stp off
    bridge_waitport 260
    bridge_fd 0
    bridge_ports none


auto br-snet
iface br-snet inet static
    bridge_stp off
    bridge_waitport 0
    bridge_fd 0
    bridge_ports none
    address 172.24.248.100
    netmask 255.255.252.0


"""

with open(interfacesfile, 'rt') as ifo:
    interfaces_text = ifo.read()


if "# MODIFIED BY INTERFACES_MUNGERATOR" in interfaces_text:
    print('Interfaces file already altered. Skipping...')
    sys.exit(0)


# Handle Public Stanza
result = re.search(
    "# Label public\n((?:.*\n)+?)# Label", interfaces_text, flags=re.M)
public_stanza = result.group(1)


# Handle Private Stanza
result = re.search(
    "# Label private\n((?:.*\n)+?)# Label", interfaces_text, flags=re.M)
private_stanza = result.group(1)


# Handle MGMT Stanza
result = re.search(
    "# Label " + MGMT_label + "\n"
    "auto (eth\d)\niface eth\d inet static\n" +
    "\W+address ([\d.]+)\n\W+netmask ([\d.]+)", interfaces_text, flags=re.M)

mgmt_eth = result.group(1)
mgmt_ip = result.group(2)
mgmt_netmask = result.group(3)

print('mgmt_eth %s' % mgmt_eth)
print('mgmt_ip %s' % mgmt_ip)
print('mgmt_netmask %s' % mgmt_netmask)


# Handle vxlan stanza
result = re.search(
    "# Label " + VXLAN_label + "\n"
    "auto (eth\d)\niface eth\d inet static\n" +
    "\W+address ([\d.]+)\n\W+netmask ([\d.]+)", interfaces_text, flags=re.M)

vxlan_eth = result.group(1)
vxlan_ip = result.group(2)
vxlan_netmask = result.group(3)

print('vxlan_eth %s' % vxlan_eth)
print('vxlan_ip %s' % vxlan_ip)
print('vxlan_netmask %s' % vxlan_netmask)

# Handle storage stanza
result = re.search(
    "# Label " + STORAGE_label + "\n"
    "auto (eth\d)\niface eth\d inet static\n" +
    "\W+address ([\d.]+)\n\W+netmask ([\d.]+)", interfaces_text, flags=re.M)

storage_eth = result.group(1)
storage_ip = result.group(2)
storage_netmask = result.group(3)

print('storage_eth %s' % storage_eth)
print('storage_ip %s' % storage_ip)
print('storage_netmask %s' % storage_netmask)


new_interfaces_text = interfaces_template % locals()


with open(interfacesfile, 'wt') as ifo:
    ifo.write(new_interfaces_text)
