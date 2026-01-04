I have `os-haproxy=4.6_1` on my `OPNsense 25.7.10-amd64`
This allows me to use single records e.g. for k8s api-server loadbalancing.
To setup a basic haproxy config, go to `Services > HAProxy` and do the following:
- add the actual servers as Real Servers.
- join them into a Backend Pool under Virtual Services > Backend Pools. For k8s api-server, I have TCP mode and Round Robin balancing.
- create a Frontend under Virtual Services > Public Services. Here, I bind to listen-address `10.20.0.50` on port `6443` (k8s api-server port) and point to the Backend Pool created earlier. Mode is TCP.
- Now, go to `Services: Unbound DNS: Overrides->Hosts` and add an A-record for `k8s-api.lab` pointing to `10.20.0.50`. This way I can do `curl -k https://k8s-api.lab:6443/version` from any device using the OPNsense router as DNS server and reach the k8s api-server loadbalancer served by haproxy.