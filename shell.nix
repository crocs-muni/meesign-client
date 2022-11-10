# source:
# https://github.com/NixOS/nixpkgs/issues/36759#issuecomment-953751281
{ pkgs ? import <nixos-unstable> { } }:

pkgs.mkShell rec {
  nativeBuildInputs = with pkgs; [
    dart
    gdk-pixbuf
    glib
    epoxy
    atk
    harfbuzz
    pango
    cairo
    libselinux
    libsepol
    xorg.xorgproto
    xorg.libXft
    xorg.libXinerama
    pcre
    xorg.libX11.dev
    xorg.libX11
    flutter
    cmake
    ninja
    clang
    pkg-config
    gtk3-x11
    gtk3.dev
    util-linux

    cargo
    gnome.zenity
  ];

  CPATH = with pkgs; "${xorg.libX11.dev}/include:${xorg.xorgproto}/include:${epoxy}/lib";

  LD_LIBRARY_PATH = with pkgs; pkgs.lib.makeLibraryPath [
    pango
    epoxy
    gtk3
    gtk3.dev
    harfbuzz
    atk
    cairo
    gdk-pixbuf
    glib
    pcre
  ];

  PROJECT_ROOT = builtins.toString ./.;
  # NOTE: not 
  shellHook = ''
    flutter pub get
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${PROJECT_ROOT}/meesign_native/native/mpc-sigs/target/x86_64-unknown-linux-gnu/release"
  '';
}
