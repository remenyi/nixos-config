{ config, pkgs, ... }:

let
  tailscaleIP = "100.93.244.94"; # tailscale ip -4
in
{
  services.tailscale.enable = true;

  services.jellyfin.enable = true;

  services.transmission = {
    enable = true;
    settings = {
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist-enabled = false;
      rpc-host-whitelist-enabled = false;
      download-dir = "/mnt/storage/torrents";
      umask = 2;
    };
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "gergo";
    group = "users";
    dataDir = "/home/gergo";
    configDir = "/home/gergo/.config/syncthing";
    guiAddress = "127.0.0.1:8384";
    settings.gui.tls = false;
  };

  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    settings = {
      schema_version = 32;
      dns = {
	bootstrap_dns = [
	  "8.8.8.8"
	  "1.1.1.1"
	];
	upstream_dns = [
          "https://dns10.quad9.net/dns-query"
        ];
      };
      filtering = {
        enabled = true;
        protection_enabled = true;
	rewrites_enabled = true;
        rewrites = [
	  {
	    domain = "jellyfin.ts";
	    answer = tailscaleIP;
	    enabled = true;
	  }
	  {
	    domain = "transmission.ts";
	    answer = tailscaleIP;
	    enabled = true;
	  }
	  {
	    domain = "adguard.ts";
	    answer = tailscaleIP;
	    enabled = true;
	  }
	  {
	    domain = "syncthing.ts";
	    answer = tailscaleIP;
	    enabled = true;
	  }
	];
      };
    };
  };

  users.groups.media = { };

  users.users.transmission.extraGroups = [ "media" ];
  users.users.jellyfin.extraGroups = [ "media" ];
  
  systemd.tmpfiles.rules = [
    "d /mnt/storage/torrents 0775 root media -"
    "d /mnt/storage/torrents 0775 transmission media -"
  ]; 

  services.caddy = {
    enable = true;
    virtualHosts = {
      "jellyfin.ts" = {
        extraConfig = ''
          tls internal
	  reverse_proxy localhost:8096
	'';
      };
      "transmission.ts" = {
        extraConfig = ''
          tls internal
	  reverse_proxy localhost:9091
	'';
      };
      "adguard.ts" = {
        extraConfig = ''
          tls internal
	  reverse_proxy localhost:3000
	'';
      };
      "syncthing.ts" = {
        extraConfig = ''
          tls internal
	  reverse_proxy localhost:8384 {
            header_up Host localhost
	  }
	'';
      };
    };
  };

  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 80 443 ];
  };
}
