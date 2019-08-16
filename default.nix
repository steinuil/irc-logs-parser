{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation rec {
  name = "irc-logs-parser";

  buildInputs = [ libffi ruby_2_6 ];
}

