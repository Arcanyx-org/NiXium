# HANA

Role: Experimental Chromebook device for development

## TODO
* [ ] Requires Secrets Managed
* [ ] Adjust for secure boot via experimental deployment script

## Bootloader Build

```console
$ nix-build --system aarch64-linux --argstr device lenovo-hana -A outputs.default
```

Utilizing the Arcanyx's fork of mobile-nixos in google-hana branch
