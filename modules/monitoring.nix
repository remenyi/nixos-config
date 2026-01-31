{ config, lib, myServices, ... }:

let
  allServices = lib.mapAttrsToList (name: value: value // { inherit name; }) myServices;
  grouped = lib.groupBy (s: s.category) allServices;

  homepageConfig = lib.mapAttrsToList (category: services: {
    "${category}" = map (s: {
      "${s.name}" = {
        icon = s.icon;
        href = "https://${s.dns}";
        description = s.desc;
      };
    }) services;
  }) grouped;

in
{
  services.gatus = {
    enable = true;
    settings.endpoints = map (s: {
      name = s.dns;
      url = "https://${s.dns}";
      interval = "1m";
      conditions = [ "[CONNECTED] == true" "[STATUS] == 200" ];
      client.insecure = true;
    }) (builtins.attrValues myServices);
  };

  services.homepage-dashboard = {
    enable = true;
    allowedHosts = "homepage.ts";
    services = homepageConfig;
    settings = {
      title = "Gergo Home Server";
      layout = lib.mapAttrs (category: _: { style = "grid"; columns = 1; }) grouped;
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
}
