{ config, pkgs, ... }:

{
  # Node-level system metrics (CPU, RAM, disk, network)
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
  };

  # Container metrics (Docker, containerd, Podman)
  services.cadvisor = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 8080;
  };

  networking.firewall.allowedTCPPorts = [
    8080
    9100
  ];
}
