{ config, pkgs, lib, ... }:

let
  tailscaleIP = "100.93.244.94"; # tailscale ip -4
in
{
  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers."readeck" = {
    image = "codeberg.org/readeck/readeck:latest";
    ports = [ "127.0.0.1:8000:8000" ];
    volumes = [
      "/mnt/storage/readeck:/readeck"
    ];
  };

  services.radarr = {
    enable = true;
    settings.server.port = 7878;
    openFirewall = false;
  };

  services.prowlarr = {
    enable = true;
    settings.server.port = 9696;
    openFirewall = false;
  };

  services.gatus = {
    enable = true;
    settings = {
      endpoints = [
        {
          name = "AdGuard";
          url = "https://adguard.ts";
          interval = "1m";
          conditions = [ "[CONNECTED] == true" "[STATUS] == 200" ];
	  client = {
	    insecure = true;
	  };
        }
        {
          name = "Homepage";
          url = "https://homepage.ts";
          interval = "1m";
          conditions = [ "[CONNECTED] == true" "[STATUS] == 200" ];
	  client = {
	    insecure = true;
	  };
        }
        {
          name = "Transmission";
          url = "https://transmission.ts";
          interval = "1m";
          conditions = [ "[CONNECTED] == true" "[STATUS] == 200" ];
	  client = {
	    insecure = true;
	  };
        }
        {
          name = "Jellyfin";
          url = "https://jellyfin.ts";
          interval = "1m";
          conditions = [ "[CONNECTED] == true" "[STATUS] == 200" ];
	  client = {
	    insecure = true;
	  };
        }
        {
          name = "Readeck";
          url = "https://readeck.ts";
          interval = "1m";
          conditions = [ "[CONNECTED] == true" "[STATUS] == 200" ];
	  client = {
	    insecure = true;
	  };
        }
        {
          name = "Syncthing";
          url = "https://syncthing.ts";
          interval = "1m";
          conditions = [ "[CONNECTED] == true" "[STATUS] == 200" ];
	  client = {
	    insecure = true;
	  };
        }
        {
          name = "Nullpont";
          url = "https://nullpontmuhely.hu";
          interval = "1m";
          conditions = [ "[CONNECTED] == true" "[STATUS] == 200" ];
        }
	{
          name = "Radarr";
          url = "https://radarr.ts";
          interval = "1m";
          conditions = [ "[CONNECTED] == true" "[STATUS] == 200" ];
          client = { insecure = true; };
        }
        {
          name = "Prowlarr";
          url = "https://prowlarr.ts";
          interval = "1m";
          conditions = [ "[CONNECTED] == true" "[STATUS] == 200" ];
          client = { insecure = true; };
        }
      ];
    };
  };

  services.homepage-dashboard = {
    enable = true;
    allowedHosts = "homepage.ts";
    services = [
      {
        "Core" = [
	  {
            "Caddy" = {
              icon = "caddy.png";
              widget = {
                type = "caddy";
                url = "http://localhost:2019";
              };
            };
	  }
          {
            "AdGuard Home" = {
              icon = "adguard-home.png";
              href = "https://adguard.ts";
              description = "Hálózati reklámszűrő és DNS szerver";
	      widget = {
                type = "adguard";
                url = "http://localhost:3000";
              };
            };
          }
          {
            "Tailscale" = {
              icon = "tailscale.png";
              description = "Mesh VPN";
              href = "https://login.tailscale.com/admin/machines";
            };
          }
        ];
      }
      {
        "Média és Letöltés" = [
          {
            "Jellyfin" = {
              icon = "jellyfin.png";
              href = "https://jellyfin.ts";
              description = "Saját Netflix";
            };
          }
          {
            "Transmission" = {
              icon = "transmission.png";
              href = "https://transmission.ts";
              description = "Torrent kliens";
	      widget = {
                type = "transmission";
	        url = "http://localhost:9091";
	      };
            };
          }
        ];
      }
      {
        "Eszközök" = [
          {
            "Readeck" = {
              icon = "readeck.png";
              href = "https://readeck.ts";
              description = "Mentett cikkek és könyvjelzők";
            };
          }
          {
            "Syncthing" = {
              icon = "syncthing.png";
              href = "https://syncthing.ts";
              description = "Fájlszinkronizálás";
            };
          }
        ];
      }
      {
        "Monitorozás" = [
          {
            "Gatus" = {
              icon = "gatus.png";
              href = "https://gatus.ts";
              description = "Uptime";
	      widget = {
                type = "gatus";
		url = "https://gatus.ts";
	      };
            };
          }
	];
      }
    ];
    settings = {
      title = "Gergo Home Server";
      layout = {
        "Core" = { style = "grid"; columns = 1; };
        "Média és Letöltés" = { style = "grid"; columns = 1; };
        "Eszközök" = { style = "grid"; columns = 1; };
        "Monitorozás" = { style = "grid"; columns = 1; };
      };
    };
    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/mnt/storage";
        };
      }
      {
        datetime = {
          format = {
            timeStyle = "short";
            dateStyle = "short";
          };
        };
      }
    ];
  };
  
  services.tailscale.enable = true;

  services.jellyfin.enable = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvpl            
    ];
  };

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
	    domain = "readeck.ts";
	    answer = tailscaleIP;
	    enabled = true;
	  }
	  {
	    domain = "readeck.home";
	    answer = "192.168.0.123";
	    enabled = true;
	  }
	  {
	    domain = "syncthing.ts";
	    answer = tailscaleIP;
	    enabled = true;
	  }
	  {
	    domain = "homepage.ts";
	    answer = tailscaleIP;
	    enabled = true;
	  }
	  {
	    domain = "gatus.ts";
	    answer = tailscaleIP;
	    enabled = true;
	  }
          {
	    domain = "radarr.ts";
	    answer = tailscaleIP;
	    enabled = true;
	  }
	  {
	    domain = "prowlarr.ts";
	    answer = tailscaleIP;
	    enabled = true;
	  }
	];
      };
    };
  };

  users.groups.media = { };

  users.users.transmission.extraGroups = [ "media" ];
  users.users.jellyfin.extraGroups = [ "media" "render" "video" ];

  users.groups.prowlarr = { };
  users.users.prowlarr = {
    isSystemUser = true;
    group = "prowlarr";
    extraGroups = [ "media" ];
  }; 
  users.groups.radarr = { };
  users.users.radarr = {
    isSystemUser = true;
    group = "radarr";
    extraGroups = [ "media" ];
  };

  systemd.services.radarr.serviceConfig = {
    SupplementaryGroups = [ "media" ];
    UMask = "0002";
  };

  systemd.services.transmission.serviceConfig = {
    SupplementaryGroups = [ "media" ];
  };
  
  systemd.tmpfiles.rules = [
    "d /mnt/storage 0775 root media -"
    "d /mnt/storage/torrents 2775 transmission media -"
    "d /mnt/storage/torrents/radarr 2775 transmission media -"
    "d /mnt/storage/readeck 0700 root root -"
    "d /mnt/storage/radarr 2775 radarr media -"
    "d /mnt/storage/prowlarr 2775 prowlarr media -"
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
      "readeck.ts, readeck.home" = {
        extraConfig = ''
          tls internal
	  reverse_proxy localhost:8000
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
      "homepage.ts" = {
        extraConfig = ''
          tls internal
	  reverse_proxy localhost:8082
	'';
      };
      "gatus.ts" = {
        extraConfig = ''
          tls internal
	  reverse_proxy localhost:8080
	'';
      };
      "radarr.ts" = {
        extraConfig = ''
          tls internal
          reverse_proxy localhost:7878
        '';
      };

      "prowlarr.ts" = {
        extraConfig = ''
          tls internal
          reverse_proxy localhost:9696
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
