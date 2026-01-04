# My NixOS Config

This repo contains declarative configs for my router.

See main homelab repo for further readme instructions.

## Install (Edge Router)

```bash
git clone https://github.com/RayyanRiaz/homelab
cd homelab/nixos-config

# Adjust /dev/sda in disko/edge-router.nix if the SSD has a different path
#sudo env NIX_CONFIG="experimental-features = nix-command flakes" nix run github:nix-community/disko#disko -- --mode destroy,format,mount ./machines/edge-router/disko.nix
sudo env NIX_CONFIG="experimental-features = nix-command flakes" nix run .#disko -- --mode destroy,format,mount ./machines/edge-router/disko.nix

# Install using the edge-router flake output
# sudo env NIX_CONFIG="experimental-features = nix-command flakes" nix flake update # if needed
sudo env NIX_CONFIG="experimental-features = nix-command flakes" nixos-install --flake .#edge-router
```
