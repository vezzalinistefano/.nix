{
  name = "brave";
  package = "brave";
  cask = "brave-browser";
  # brave was removed from nixpkgs (no maintainers for security fixes), so Homebrew is the only working source
  default = "homebrew";
}
