# tailscale quick-setup instructions

## Installation

I am afraid of apt-get installs. So installed the binaries from https://pkgs.tailscale.com/stable/#static.
This gave:

- tailscale
- tailscaled => daemon process

## Run

Run the daemon first:

```bash
sudo ./tailscaled --state=./state
```

> I tried without sudo (e.g. `tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --state=./state`), but it failed... Perhaps spend more time if interested.

In a parallel terminal, run:

```bash
sudo ./tailscale up
```

This will give you a URL to authenticate the machine. Open it in your browser, login, and authorize the device.
Now you should be connected to your Tailscale network! You can verify from the Tailscale admin console.

---

## Opnsense setup:

On the router, we need to install `os-tailscale` plugin. I have currently version `1.3` This can be done from System > Firmware > Plugins.

1. After installation, go to VPN > Tailscale > Authentication.
2. From tailscale [admin console](https://login.tailscale.com/admin/settings/keys), get a reusable key
3. Enter: Login-Server=`https://controlplane.tailscale.com`, Auth-Key=`<the key you got>`, and click `Save`.
4. Now go to VPN > Tailscale > Settings, and Enable Tailscale. I also added `10.20.0.0/24` to the "Advertised Routes" so that devices on Tailscale can access nas_and_servers on the LAN. This step needs to be accepted on the Tailscale admin console too. This allowed me to do `ssh rayyan@p52.lab` from other machines etc.
5. Click `Save` and then `Start Tailscale`.
6. Add interface assignment for the new tailscale interface that appears after plugin installation.
7. Finally, add firewall rules to allow traffic from Tailscale interface to LAN and vice-versa. Currently I have `IPv4` protocol and `*` for everything else e.g source, port, destination, gateway.
