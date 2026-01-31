{ config, lib, myServices, tailscaleIP, ... }:

{
  services.tailscale.enable = true;

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
        rewrites = lib.flatten (lib.mapAttrsToList (name: s:
	  let
	    main = { domain = s.dns; answer = tailscaleIP; enabled = true; };
	  in [ main ]
	) myServices);
      };
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts = lib.mapAttrs' (name: s: lib.nameValuePair s.dns {
      extraConfig = ''
        tls internal
	reverse_proxy localhost:${toString s.port} ${if name == "syncthing" then "{ header_up Host localhost }" else ""}
      '';
    }) myServices;
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedTCPPorts = [ 53 80 443 ];
}
