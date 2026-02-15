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
      incomplete-dir = "/mnt/storage/torrents/incomplete";
      incomplete-dir-enabled = true;
      umask = 2;
    };
  };

  services.radarr.enable = true;
  services.prowlarr.enable = true;
  services.sonarr.enable = true;
  services.jellyseerr.enable = true;
  services.bazarr.enable = true;

  systemd.services.bazarr.serviceConfig = {
    ProtectHome = "no";
    ReadWritePaths = [ "/mnt/storage/media" ];
    UMask = "0002";
  };

  systemd.services.radarr.serviceConfig.UMask = "0002";
  systemd.services.sonarr.serviceConfig.UMask = "0002";
  
  users.groups.media = { };

  users.users.transmission.extraGroups = [ "media" ];
  users.users.jellyfin.extraGroups = [ "media" "render" "video" ];
  users.users.radarr.extraGroups = [ "media" ];
  users.users.sonarr.extraGroups = [ "media" ];
  users.users.bazarr.extraGroups = [ "media" ];

  systemd.tmpfiles.rules = [
    "d /mnt/storage/torrents 0775 transmission media -"
    "d /mnt/storage/torrents/movies 0775 transmission media -"
    "d /mnt/storage/torrents/tv 0775 transmission media -"
    "d /mnt/storage/torrents/incomplete 0775 transmission media -"
    "d /mnt/storage/media 0775 radarr media -"
    "d /mnt/storage/media/movies 0775 radarr media -"
    "d /mnt/storage/media/tv 0775 sonarr media -"
  ];
}

