{
  name = "ghostty";
  # nixpkgs' `ghostty` is the source build (not for darwin); `ghostty-bin` is the signed app bundle
  package = "ghostty-bin";
  cask = "ghostty";
  default = "nix";
}
