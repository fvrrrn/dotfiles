{
  lib,
  stdenvNoCC,
  makeWrapper,
  python3,
  fzf,
  kitty,
  sway,
  glib,
  bash,
  foot,
}:
stdenvNoCC.mkDerivation {
  pname = "dfzf-search";
  version = "1.0.0";
  src = ./dfzf-search.py;
  dontUnpack = true;
  nativeBuildInputs = [makeWrapper];
  installPhase = ''
    install -Dm644 "$src" "$out/libexec/dfzf-search.py"
    # GIO's Terminal=true fallback looks for xterm, not Foot or Kitty.
    # Foot accepts the same -e command convention; let GIO expand Exec fields.
    mkdir -p "$out/libexec/terminal"
    makeWrapper ${foot}/bin/foot "$out/libexec/terminal/xterm"
    makeWrapper ${python3}/bin/python3 "$out/bin/dfzf-search" \
      --add-flags "$out/libexec/dfzf-search.py" \
      --prefix PATH : ${lib.makeBinPath [fzf kitty sway glib bash foot]}
  '';
  meta = {
    description = "Unified Sway window, desktop application and Kitty scrollback search";
    platforms = lib.platforms.linux;
    mainProgram = "dfzf-search";
  };
}
