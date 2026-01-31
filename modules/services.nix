{ config, pkgs, lib, ... }:

let
  tailscaleIP = "100.93.244.94";
  
  myServices = {
    adguard = {
      dns = "adguard.ts";
      port = 3000;
      category = "Core";
      icon = "adguard-home.png";
      desc = "Hálózati reklámszűrő";
    };
    homepage = {
      dns = "homepage.ts";
      port = 8082;
      category = "Monitor";
      icon = "homepage-dashboard.png";
      desc = "Home Dashboard";
    };
    jellyfin = {
      dns = "jellyfin.ts";
      port = 8096;
      category = "Média";
      icon = "jellyfin.png";
      desc = "Saját Netflix";
    };
    transmission = {
      dns = "transmission.ts";
      port = 9091;
      category = "Média";
      icon = "transmission.png";
      desc = "Torrent kliens";
    };
    radarr = { 
      dns = "radarr.ts";
      port = 7878;
      category = "Média";
      icon = "radarr.png";
      desc = "Filmek";
    };
    sonarr = { 
      dns = "sonarr.ts";
      port = 8989;
      category = "Média";
      icon = "sonarr.png";
      desc = "Sorozatok";
    };
    prowlarr = {
      dns = "prowlarr.ts";
      port = 9696;
      category = "Média";
      icon = "prowlarr.png";
      desc = "Indexelő";
    };
    jellyseerr = {
      dns = "jellyseerr.ts";
      port = 5055;
      category = "Média";
      icon = "jellyseerr.png";
      desc = "Igénykezelő";
    };
    gatus = {
      dns = "gatus.ts";
      port = 8080;
      category = "Monitor";
      icon = "gatus.png";
      desc = "Uptime";
      };
    readeck = {
      dns = "readeck.ts";
      port = 8000;
      category = "Utils";
      icon = "readeck.png";
      desc = "Könyvjelzők";
    };
    syncthing = {
      dns = "syncthing.ts";
      port = 8384;
      category = "Utils";
      icon = "syncthing.png";
      desc = "Fájlszinkron";
    };
  };
in
{
  imports = [
    ./core.nix
    ./media.nix
    ./monitoring.nix
    ./utils.nix
  ];

  _module.args = { 
    inherit myServices tailscaleIP; 
  };
}
