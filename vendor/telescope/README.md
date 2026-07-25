# telescope
See the stars! Telescope is a bundled installation for the linux XR display server **Stardust XR**, that includes the [Stardust XR Server](https://github.com/StardustXR/server), [Hexagon Launcher](https://github.com/StardustXR/protostar), [Flatland](https://github.com/StardustXR/flatland), and [Black Hole](https://github.com/StardustXR/black-hole)

This is the easiest way to quickly experience what Stardust XR has to offer!

> [!NOTE]
> For help with setting up an XR headset on linux, visit https://stardustxr.org/docs/get-started/setup-openxr

## Installation
The [Terra repository is required](https://terra.fyralabs.com/). If you're using [Ultramarine Linux](https://ultramarine-linux.org), this comes pre-installed, otherwise Standard Fedora Editions and derivatives can directly install terra-release:
```bash
sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
```
Then install Telescope using:
```bash
sudo dnf install telescope
```

On **Arch Linux**, Stardust XR is available in the Arch Linux User Repository [AUR](https://aur.archlinux.org/packages/stardust-xr-telescope). We suggest using an [AUR helper](https://wiki.archlinux.org/title/AUR_helpers), like Paru:
```
paru -S stardust-xr-telescope
```
On NixOS, use the [Nix package manager](https://nixos.org/download/#nix-install-linux) Make sure [flakes are enabled](https://nixos.wiki/wiki/flakes).

```
nix run github:StardustXR/telescope
```

An [appimage](https://github.com/StardustXR/telescope/releases) is also available for download

# After Installation
From here, just run `telescope -f` in your terminal for flatscreen mode!  

### Flatscreen Navigation
A video guide showcasing flatscreen controls is available [here](https://www.youtube.com/watch?v=JCYecSlKlDI)  

To move around, hold down `Shift + W A S D`, with `Q` for moving down and `E` for moving up.
![wasd](https://github.com/StardustXR/website/blob/main/static/img/updated_flat_wasd.GIF)

To look around, hold down `Shift + Right` Click while moving the mouse. 
![updated_look](https://github.com/StardustXR/website/blob/main/static/img/updated_flat_look.GIF)

To drag applications out of the app launcher, hold down `Shift + ~`
![updated_drag](https://github.com/StardustXR/website/blob/main/static/img/updated_flat_drag.GIF)

### XR Navigation
Run `telescope` and if it detects an XR headset is running, it should launch within it.

A video guide showcasing XR controls is available [here](https://www.youtube.com/watch?v=RbxFq6JjliA)  

**Quest 3 Hand tracking**:
Pinch to drag and drop, grasp with full hand for grabbing, point and click with pointer finger to click or pinch from a distance  

![hand_pinching](https://github.com/StardustXR/website/blob/main/static/img/hand_pinching.GIF)

**Quest 3 Controller**:
Grab with the grip buttons, click by touching the tip of the cones or by using the trigger from a distance  

![controller_click](https://github.com/StardustXR/website/blob/main/static/img/controller_click.GIF)
