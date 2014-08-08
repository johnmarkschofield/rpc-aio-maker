#!/usr/bin/python

import os
import re
import sys

interfacesfile = "/etc/network/interfaces"

VMNET_label = os.environ['VMNET_NETWORK_NAME']
MGMT_label = os.environ['MGMT_NETWORK_NAME']

interfaces_template = """# MODIFIED BY INTERFACES_MUNGERATOR
# Used by ifup(8) and ifdown(8). See the interfaces(5) manpage or
# /usr/share/doc/ifupdown/examples for more information.

# The loopback network interface
auto lo
iface lo inet loopback

# Label public
auto %(public_eth)s
iface %(public_eth)s inet manual

auto br-ext
iface br-ext inet static
    address %(public_ip)s
    netmask %(public_netmask)s
    gateway %(public_gateway)s
    bridge_ports %(public_eth)s
    bridge_stp off
    bridge_fd 0
iface br-ext inet6 static
    address %(public_ip6)s
    netmask %(public_netmask6)s
    gateway %(public_gateway6)s
    dns-nameservers %(public_dns)s

# Label private
%(private_stanza)s

# Label %(MGMT_label)s
auto %(mgmt_eth)s
iface %(mgmt_eth)s inet manual

auto br-mgmt
iface br-mgmt inet static
    address %(mgmt_ip)s
    netmask %(mgmt_netmask)s
    bridge_ports %(mgmt_eth)s
    bridge_stp off
    bridge_fd 0

# Label %(VMNET_label)s
auto %(vmnet_eth)s
iface %(vmnet_eth)s inet manual

auto br-vmnet
iface br-vmnet inet static
    address %(vmnet_ip)s
    netmask %(vmnet_netmask)s
    bridge_ports %(vmnet_eth)s
    bridge_stp off
    bridge_fd 0
"""

with open(interfacesfile, 'rt') as ifo:
    interfaces_text = ifo.read()


if "# MODIFIED BY INTERFACES_MUNGERATOR" in interfaces_text:
    print('Interfaces file already altered. Skipping...')
    sys.exit(0)

result = re.search(
    "^\# Label public\nauto (eth\d)\niface eth\d inet static\n" +
    "\W+address ([\d\.]+)\n\W+netmask ([\d\.]+)\n" +
    "\W+gateway ([\d\.]+)\niface eth\d inet6 static\n" +
    "\W+address ([\d:a-f]+)\n\W+netmask (\d+)\n" +
    "\W+gateway ([\d:a-f]+)\n\W+dns-nameservers ([0-9. ]+)",
    interfaces_text, flags=re.M)

public_eth = result.group(1)
public_ip = result.group(2)
public_netmask = result.group(3)
public_gateway = result.group(4)
public_ip6 = result.group(5)
public_netmask6 = result.group(6)
public_gateway6 = result.group(7)
public_dns = result.group(8)

print('public_eth %s' % public_eth)
print('public_ip %s' % public_ip)
print('public_netmask %s' % public_netmask)
print('public_gateway %s' % public_gateway)
print('public_ip6 %s' % public_ip6)
print('public_netmask6 %s' % public_netmask6)
print('public_dns %s' % public_dns)
print('public_gateway6 %s' % public_gateway6)

result = re.search(
    "# Label private\n((?:.*\n)+?)# Label", interfaces_text, flags=re.M)


private_stanza = result.group(1)
print('private_stanza %s' % private_stanza)


print('MGMT_label %s' % MGMT_label)
print('VMNET_label %s' % VMNET_label)


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

result = re.search(
    "# Label schof-aio-vmnet\nauto (eth\d)\n" +
    "iface eth\d inet static\n\W+address ([\d.]+)\n\W+netmask ([\d.]+)",
    interfaces_text, flags=re.M)

vmnet_eth = result.group(1)
vmnet_ip = result.group(2)
vmnet_netmask = result.group(3)

print('vmnet_eth %s' % vmnet_eth)
print('vmnet_ip %s' % vmnet_ip)
print('vmnet_netmask %s' % vmnet_netmask)

new_interfaces_text = interfaces_template % locals()

with open(interfacesfile, 'wt') as ifo:
    ifo.write(new_interfaces_text)
