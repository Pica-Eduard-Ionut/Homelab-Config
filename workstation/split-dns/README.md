# Overview
Configures a dedicated network connection to route only `.homelab.com` DNS queries to a local DNS server, while keeping all other traffic (including internet DNS) on the default gateway.

This was done mostly follwing RedHat tutorials like [configuring_and_managing_networking](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/configuring_and_managing_networking/using-different-dns-servers-for-different-domains_configuring-and-managing-networking#using-systemd-resolved-in-networkmanager-to-send-dns-requests-for-a-specific-domain-to-a-selected-dns-server_using-different-dns-servers-for-different-domains)

## Why this setup?
- **Split DNS**: Only `.homelab.com` domains are resolved by the local DNS server
- **No Routing Conflicts**: Internet traffic continues using the default gateway (e.g., WiFi or Ethernet)
- **Clean Separation**: External DNS queries (e.g., `google.com`) bypass the local DNS entirely
- **Automatic Fallback**: Non-homelab domains use the system's default DNS resolver

## Steps:

### Create the connection:
```bash
sudo nmcli connection modify homelab-dns \
    ipv4.method manual \
    ipv4.addresses 192.168.1.254/32 \
    ipv4.never-default yes
```

### Configure DNS resolver and search domain:
Replace the ip address with the server's private IP address.
```bash
sudo nmcli connection modify homelab-dns \
    ipv4.dns "192.168.1.130" \
    ipv4.dns-search "~homelab.com"
```

### Activate the connection
```bash
sudo nmcli connection up homelab-dns
```
After a few seconds it should work, NetworkManager takes a bit to refresh.

## Verify the configuration
```bash
resolvectl status
```
Now something like the following should appear:
```
Link 4 (homelab0)
    Current Scopes: DNS
    Current DNS Server: 192.168.1.130
    DNS Servers: 192.168.1.130
    DNS Domain: ~homelab.com
    Default Route: no
```