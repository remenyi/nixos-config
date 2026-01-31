{ pkgs, ... }:

{
  services.jellyfin.enable = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver intel-vaapi-driver libvpl ];
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

  services.radarr.enable = true;
  services.prowlarr.enable = true;

  users.groups.media = { };
  users.groups.radarr = { };
  users.groups.prowlarr = { };
  users.users.transmission.extraGroups = [ "media" ];
  users.users.jellyfin.extraGroups = [ "media" "render" "video" ];
  users.users.radarr = { isSystemUser = true; group = "radarr"; extraGroups = [ "media" ]; };
  users.users.prowlarr = { isSystemUser = true; group = "prowlarr"; extraGroups = [ "media" ]; };

  systemd.tmpfiles.rules = [
    "d /mnt/storage 0775 root media -"
    "d /mnt/storage/torrents 2775 transmission media -"
    "d /mnt/storage/radarr 2775 radarr media -"
  ];
}
