{
  pkgs,
  inputs,
  ...
}: {
  hardware.xpadneo.enable = true;

  environment.systemPackages = [
    inputs.eden-flake.packages.${pkgs.stdenv.hostPlatform.system}.eden
  ];
}
