{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    opencode
    codex
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.chatgpt
    nodejs
  ];
}
