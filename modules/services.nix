{ config, pkgs, ... }:

{
  services.jellyfin.enable = true;

  services.transmission = {
    enable = true;
    settings = {
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist-enabled = false;
      rpc-host-whitelist-enabled = true;
      rpc-host-whitelist = "torrent.local,localhost,127.0.0.1";
      download-dir = "/var/lib/media/downloads";
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

  users.groups.media = { };

  users.users.transmission.extraGroups = [ "media" ];
  users.users.jellyfin.extraGroups = [ "media" ];
  
  systemd.tmpfiles.rules = [
    "d /var/lib/media 0775 root media -"
    "d /var/lib/media/downloads 0775 transmission media -"
  ]; 

  services.caddy = {
    enable = true;
    virtualHosts = {
      "jellyfin.local" = {
        extraConfig = "reverse_proxy localhost:8096";
      };
      "torrent.local" = {
        extraConfig = "reverse_proxy localhost:9091";
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

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
