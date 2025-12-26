# Testing network connection using iperf


### Different Machines
There are two ways of doing so. The easier case is when the machines are different. Then you run on the server:

`iperf3 -s`

and on the client machine, run:

`iperf3 -c IP_ADDRESS_OF_SERVER`

### Same machine
A more interesting case is testing for direct connection between two ports of a single machine.

For this, we need network namespaces. Otherwise the data transfer happens directly without following the whole loop.
e.g., if you simply assign ips to two different interfaces and run iperf3 commands, you will see A LOT of speed. e.g., in my `HP prodesk 400 G2 SFF` machine with `i4590s`, I saw around 30Gbps speed (which is, in one sense, also good that it told me the limits of my PC), which is ~30 times more than the gigabit ports that I want to test.

So, the idea is to create two interfaces in two different namespaces. This allows us to gauge actual speed.


```bash
# provide interface names, e.g. the two different ports (via ip -brief link OR ip -brief addr)
INTERFACE1="eth0"
INTERFACE2="eth1"

# create namespaces
sudo ip netns add nsA
sudo ip netns add nsB

# move interfaces into namespaces
sudo ip link set $INTERFACE1 netns nsA
sudo ip link set $INTERFACE2 netns nsB

# bring up loopback inside each namespace
sudo ip netns exec nsA ip link set lo up
sudo ip netns exec nsB ip link set lo up

# assign IPs and bring interfaces up
sudo ip netns exec nsA ip addr add 192.0.2.1/24 dev $INTERFACE1
sudo ip netns exec nsA ip link set $INTERFACE1 up

sudo ip netns exec nsB ip addr add 192.0.2.2/24 dev $INTERFACE2
sudo ip netns exec nsB ip link set $INTERFACE2 up

# verify link speed (inside each namespace)
sudo ip netns exec nsA ethtool $INTERFACE1
sudo ip netns exec nsB ethtool $INTERFACE2

# start iperf3 server in nsA bound to that IP
sudo ip netns exec nsA iperf3 -s -B 192.0.2.1 &

# run client in nsB, binding to nsB's IP
sudo ip netns exec nsB iperf3 -c 192.0.2.1 -B 192.0.2.2 -t 30 -P 8
```

---



# Re-requesting ip lease from DHCP server (e.g. after changing MAC address or updating router config etc)

Careful: this will drop your current connection, so if you're connected via ssh, you will get disconnected.

```bash
sudo dhclient -r <interface> & sudo dhclient <interface>
```

OR:

```bash
sudo dhcpcd -k <interface> & sudo dhcpcd <interface>
```



# Multiple DNS servers:

On my home-laptop, I wanted to have conditional DNS resolution. So easy way is:

`sudo nano /etc/systemd/network/10-enp11s0.network` and paste:

```
[Match]
Name=enp11s0

[Network]
DNS=192.168.20.1
Domains=lan
```

Afterwards:

```bash
sudo systemctl restart systemd-networkd
sudo systemctl restart systemd-resolved
resolvectl flush-caches
```

