{ pkgs, myServices, ... }:

{
  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.readeck = {
    image = "codeberg.org/readeck/readeck:latest";
    ports = [ "127.0.0.1:8000:${toString myServices.readeck.port}" ];
    volumes = [ "/mnt/storage/readeck:/readeck" ];
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "gergo";
    group = "users";
    dataDir = "/home/gergo";
    configDir = "/home/gergo/.config/syncthing";
    guiAddress = "127.0.0.1:${toString myServices.syncthing.port}";
    settings.gui.tls = false;
  };
}
