{
  config,
  lib,
  pkgs,
  ...
}:

let
  lokiServer = "http://monitoring.lan:3100";
in
{
  services.promtail = {
    enable = true;

    after = [ "systemd-tmpfiles-setup.service" ];
    wants = [ "systemd-tmpfiles-setup.service" ];
    preStart = ''
      mkdir -p /var/lib/promtail
      chown promtail:promtail /var/lib/promtail
    '';

    configuration = {
      server = {
        http_listen_port = 9080;
        grpc_listen_port = 0;
      };
      positions = {
        filename = "/var/lib/promtail/positions.yaml";
      };
      clients = [
        { url = "${lokiServer}/loki/api/v1/push"; }
      ];
      scrape_configs = [
        {
          job_name = "systemd-journal";
          journal = { };
          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
            {
              source_labels = [ "__journal__hostname" ];
              target_label = "host";
            }
            {
              source_labels = [ "unit" ];
              target_label = "app";
            }
          ];
        }
        {
          job_name = "dnsmasq";
          static_configs = [
            {
              targets = [ "localhost" ];
              labels = {
                job = "dnsmasq";
                __path__ = "/var/log/dnsmasq.log";
                app = "dnsmasq";
              };
            }
          ];
        }
      ];
    };
  };

  # Export metrics for Prometheus
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "systemd"
      "cpu"
      "diskstats"
      "filesystem"
      "loadavg"
      "meminfo"
      "netdev"
      "netstat"
      "powersupplyclass"
    ];
    port = 9100;
  };

  # # --- Ensure Promtail state directory exists ---
  # systemd.tmpfiles.rules = [
  #   "d /var/lib/promtail 0755 promtail promtail -"
  # ];

  # --- Extend Promtail user permissions ---
  users.users.promtail = {
    extraGroups = [
      "systemd-journal"
      "adm"
    ];
  };

  networking.firewall.allowedTCPPorts = [
    9100
    9080
  ];
}
