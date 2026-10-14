{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  bash,
  coreutils,
  findutils,
  gnugrep,
  gnused,
  gawk,
  procps,
  perl,
  fd,
  fzf,
  jq,
  ripgrep,
  kitty,
  sway,
  i3,
}:
rustPlatform.buildRustPackage rec {
  pname = "dfzf";
  version = "0.19.3";

  src = fetchFromGitHub {
    owner = "parisni";
    repo = "dfzf";
    rev = "0b43671d2e165aa709d83e5c261e2719a426ccc8";
    hash = "sha256-NXEA9KrvEXJWGumkGrWjsXwly5C4D9iEgmNUtP5/GdU=";
  };

  cargoRoot = "dfzf-utils";
  buildAndTestSubdir = cargoRoot;
  cargoLock = {
    lockFile = "${src}/dfzf-utils/Cargo.lock";
    outputHashes."i3ipc-0.10.1" = "sha256-rFPkSV60lkJJhvBi+ejZkclwUeLagIwUM4oxHnoNpZw=";
  };

  nativeBuildInputs = [makeWrapper];

  postInstall = ''
    install -m755 bin/dfzf-* -t "$out/bin"
    patchShebangs "$out/bin"
    for script in bin/dfzf-*; do
      wrapProgram "$out/bin/$(basename "$script")" \
        --prefix PATH : "${lib.makeBinPath [bash coreutils findutils gnugrep gnused gawk procps perl fd fzf jq ripgrep kitty sway i3]}:$out/bin"
    done
    install -Dm644 README.md "$out/share/doc/dfzf/README.md"
  '';

  meta = {
    description = "Fzf window navigation and terminal scrollback search for Sway and i3";
    homepage = "https://github.com/parisni/dfzf";
    license = [lib.licenses.gpl3Only lib.licenses.mit];
    platforms = lib.platforms.linux;
    mainProgram = "dfzf-windows";
  };
}
