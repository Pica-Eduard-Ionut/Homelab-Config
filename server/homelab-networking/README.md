# Overview
Sets up an authoritative DNS server using BIND with wildcard records and a reverse proxy using Caddy with automatic internal TLS for homelab services.

- [Overview](#overview)
  - [1. BIND DNS Server Configuration](#1-bind-dns-server-configuration)
    - [Key Points](#key-points)
    - [Restart BIND](#restart-bind)
  - [2. Caddy Reverse Proxy Configuration](#2-caddy-reverse-proxy-configuration)
    - [Key Points](#key-points-1)
    - [Restart Caddy](#restart-caddy)
    - [Trust Internal CA](#trust-internal-ca)
    - [Removing the trust certificate from the workstation](#removing-the-trust-certificate-from-the-workstation)
    - [Adding New Services](#adding-new-services)


## 1. BIND DNS Server Configuration

Edit `/etc/named.conf` using `sudo nano /etc/named.conf`

- append the local IPv4 to `listen-on port 53 { 127.0.0.1; };`, so in my case it became `listen-on port 53 { 127.0.0.1; 192.168.1.130; };`
- append the local IPv6 to `listen-on-v6 port 53 { any; };`, I did not modify this as I don't have a need for it
- add the new zone for the homelab right after the `zone "." IN { ... };` block:
    ```
    // Authoritative zone for homelab
    zone "homelab.com" IN {
        type master;
        file "/var/named/homelab.com.zone";
    };
    ```

- now create the zone file using `sudo nano /var/named/homelab.com.zone`
    ``` bash
    $TTL 86400

    @       IN      SOA     ns1.homelab.com. admin.homelab.com. (
                            2026072904  ; serial (YYYYMMDDNN format)
                            3600        ; refresh
                            1800        ; retry
                            604800      ; expire
                            86400       ; minimum TTL
    )

    ; Name server record
            IN      NS      ns1.homelab.com.

    ; DNS server A record
    ns1     IN      A       192.168.1.130

    ; Wildcard - resolves ALL subdomains to the server
    *       IN      A       192.168.1.130
    ```

### Key Points
- `listen-on`: Binds to `192.168.1.130` (my homelabs private IP is 192.168.1.130) so LAN devices can query it
- `allow-query`: Restricts access to `192.168.1.0/24` for security
- Wildcard `*` record: Any `*.homelab.com` resolves to `192.168.1.130`
- Serial number: Increment when editing zone file (format: YYYYMMDDNN)

### Restart BIND
``` bash 
sudo systemctl restart named
sudo systemctl enable named
```


## 2. Caddy Reverse Proxy Configuration

Edit `/etc/caddy/Caddyfile` using `sudo nano /etc/caddy/Caddyfile`

```bash
# The Caddyfile is an easy way to configure your Caddy web server.
#
# https://caddyserver.com/docs/caddyfile


# The configuration below serves a welcome page over HTTP on port 80.  To use
# your own domain name with automatic HTTPS, ensure your A/AAAA DNS record is
# pointing to this machine's public IP, then replace `http://` with your domain
# name.  Refer to the documentation for full instructions on the address
# specification.
#
# https://caddyserver.com/docs/caddyfile/concepts#addresses
#http:// {
        # Set this path to your site's directory.
        #root * /usr/share/caddy

        # Enable the static file server.
        #file_server

        # Another common task is to set up a reverse proxy:
        # reverse_proxy localhost:8080

        # Or serve a PHP site through php-fpm:
        # php_fastcgi localhost:9000

        # Refer to the directive documentation for more options.
        # https://caddyserver.com/docs/caddyfile/directives
#}

# As an alternative to editing the above site block, you can add your own site
# block files in the Caddyfile.d directory, and they will be included as long
# as they use the .caddyfile extension.
import Caddyfile.d/*.caddyfile

console.homelab.com {
        tls internal
        reverse_proxy localhost:9090
}

```
In this case `console.homelab.com` points to the cockpit address.

### Key Points
- tls internal: Generates self-signed certificates trusted by Caddy's local CA
- Reverse proxy: console.homelab.com -> Cockpit (port 9090)

### Restart Caddy
```bash
sudo systemctl restart caddy
sudo systemctl enable caddy
```

### Trust Internal CA
Create a temporary copy of the `root.crt` on the **server** so that it can be copied by the workstation
```bash
sudo cp /var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt /tmp/caddy-root.crt
sudo chmod 644 /tmp/caddy-root.crt
```

Copy the file from the server to the **workstation**
```bash
scp admin@192.168.1.130:/tmp/caddy-root.crt ~/caddy-root.crt
```

Now copy it to the certificate folder and update the trust list
```bash
sudo cp ~/caddy-root.crt /etc/pki/ca-trust/source/anchors/caddy-root.crt
sudo update-ca-trust
```
Remove the certificate from `/home/user/` folder
```bash
rm ~/caddy-root.crt
```

### Removing the trust certificate from the workstation
```bash
sudo rm /etc/pki/ca-trust/source/anchors/caddy-root.crt
sudo update-ca-trust
```

### Adding New Services
- `DNS`: No change needed (wildcard handles all subdomains)
- `Caddy`: Add new block in `/etc/caddy/Caddyfile`:
    ```
    newservice.homelab.com {
        tls internal
        reverse_proxy localhost:PORT
    }
    ```
- Restart `Caddy`: 
    ```bash 
    sudo systemctl reload caddy
    ```