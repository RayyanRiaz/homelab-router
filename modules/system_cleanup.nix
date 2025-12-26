{ config, pkgs, ... }:

{

  ##############################
  # 🧾 Garbage collection
  ##############################

  # Automatic gc
  nix.gc = {
    automatic = true;
    dates = "Mon *-*-* 02:00:00";
    options = "--delete-older-than 30d"; # Delete items older than 30 days
  };

  # Deduplicate identical store paths automatically
  nix.optimise.automatic = true;

  # keep last 10 boot entries
  boot.loader = {
    grub = {
      configurationLimit = 10;
    };
    systemd-boot.configurationLimit = 10;
  };

  # Clean /tmp automatically. Automated by builtin timer `systemd-tmpfiles-clean`, that we configure below.
  systemd = {
    tmpfiles.rules = [
      "q /tmp 1777 root root 7d"
      "q /var/tmp 1777 root root 30d"
    ];

    services = {
      # custom service to clean old nix logs
      nix-log-cleanup = {
        description = "Prune old nix derivation logs (older than 30 days)";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.findutils}/bin/find /nix/var/log/nix/drvs/ -type f -mtime +30 -delete";
        };
      };
    };
  };

  systemd.timers = {
    # this section shows two different ways to schedule periodic tasks
    systemd-tmpfiles-clean = {
      enable = true;
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "1h";
      };
    };

    nix-log-cleanup = {
      description = "Run nix-log-cleanup monthly";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "Tue *-*-* 04:00:00";
        Persistent = true; # ensures missed runs are executed after downtime
      };
    };
  };

  ##############################
  # 🧾 Log management
  ##############################

  services.journald = {
    # https://www.freedesktop.org/software/systemd/man/latest/journald.conf.html
    extraConfig = ''
      SystemMaxFileSize=10M
      SystemMaxUse=200M
      RuntimeMaxUse=100M
      MaxRetentionSec=180day
      Compress=yes
      Seal=yes
    '';
  };

}
