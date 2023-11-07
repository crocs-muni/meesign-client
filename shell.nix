# source:
# https://github.com/NixOS/nixpkgs/issues/36759#issuecomment-953751281
{ pkgs ? import <nixos-unstable> { } }:

pkgs.mkShell rec {
  nativeBuildInputs = with pkgs; [
    # dart
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
    protobuf
    xorg.libXft
    xorg.libXinerama
    pcre2
    xorg.libX11.dev
    xorg.libX11
    flutter
    cmake
    ninja
    clang
    clang-tools
    pkg-config
    gtk3-x11
    gtk3.dev
    util-linux
    sqlite
    poppler_utils
    libllvm
    libclang

    cargo
    gnome.zenity
    openssl
    openssl.dev
  ];


  PROTOC = with pkgs; "${protobuf}/bin/protoc";
  CPATH = builtins.concatStringsSep ":" (with pkgs; [
    "${xorg.libX11.dev}/include"
    "${xorg.xorgproto}/include"
    "${epoxy}/lib"
    # "${libclang.lib.outPath}/lib/${libclang.lib.pname}/${libclang.lib.version}/include"
  ]);
  OPENSSL_LIB_DIR = with pkgs; pkgs.lib.makeLibraryPath [ openssl ];
  OPENSSL_INCLUDE_DIR = with pkgs; "${openssl.dev}/include";

  LD_LIBRARY_PATH = with pkgs; pkgs.lib.makeLibraryPath [
    pango
    epoxy
    gtk3
    gtk3.dev
    sqlite
    harfbuzz
    # clang-tools
    # libclang
    atk
    cairo
    # clang
    libllvm
    gdk-pixbuf
    glib
    pcre2
  ];
  # + [ "${PROJECT_ROOT}/meesign_native/native/"];


  PROJECT_ROOT = builtins.toString ./.;
  # NOTE: not 
  shellHook = ''
    flutter pub get upgrade

    pushd meesign_native
    dart pub get
    popd

    LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${PROJECT_ROOT}/meesign_native/native/meesign-crypto/target/x86_64-unknown-linux-gnu/release"
    export PATH="$PATH":"$HOME/.pub-cache/bin"
  '';
}
