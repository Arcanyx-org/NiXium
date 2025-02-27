# NiXium (N/X)

Transparent Nix-based Open-Source Infrastructure as Code (OSS IaaC) Management Solution for Multiple Systems and Domains designed to be a reliable tool for mission-critical tasks in paranoid and high-security environment.

We are using:

* [disko](https://github.com/nix-community/disko) for Declarative Filesystem Management
* [impermanence](https://github.com/nix-community/impermanence) to Enforce Declarative Setup
* [flake-parts](https://github.com/hercules-ci/flake-parts) for Nix Flake Management
* [home-manager](https://github.com/nix-community/home-manager) for User Configuration
* [ragenix](https://github.com/yaxitech/ragenix) for Managing of Secrets
* [mission-control](https://github.com/Platonic-Systems/mission-control) as a Frontend for this repository
* [lanzaboote](https://github.com/nix-community/lanzaboote) for Declarative Secure Boot
* [nixos-generators](https://github.com/nix-community/nixos-generators) to Generate Filesystem Images

## Directory layout

├── **config** -- Project Configuration<br/>
├── **lib** -- Project-Oriented Libraries<br/>
├── **src** -- Source Code Files<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **nixos** -- Source Files Relevant to the NixOS Distribution<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **machines** -- Machine Management in the NixOS Distribution<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **template** -- Example of Machine Management<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **config** -- Invidual System configuration<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **lib** -- Libraries Exported by the Machine to Others<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **releases** -- Management across releases for the invidual machine<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **secrets** -- Machine-invidual secrets<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **services** -- Machine managed services<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **modules** -- NixOS-related Modules<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **programs** -- NixOS-related Programs Adjustments<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **security** -- NixOS-related Security Management<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **services** -- NixOS-related Service Adjustments<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **system** -- NixOS-related System Management<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **impermenance** -- NixOS-related management of impermanence<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **overlays** -- Changes on top of nixpkgs<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **users** -- Management of Users in NixOS Distribution<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **modules** -- Home-Manager specific modules applied to all users<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **users** -- Invidual User Management<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **kreyren** -- Management of Kreyren User<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **home** -- User Kreyren's Home Management<br/>
├── **tasks** -- Routines to work with the project<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **docs** -- Tasks related to the project documentation<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **tree** -- Task used to generate this file hierarchy output<br/>
├── **vendor** -- 3rd party repos used in this projects<br/>

*This file hierarchy output is generated using the `tree` task that processes directories with the `.about` file containing short description about the purpose of the directory*

## Provided Services

All of our services are provided primarely through onion routing, for ease of use we recommend that you configure [MapAddress](https://manpages.org/tor) so that you can use easily memorable URLs instead of the long and cryptic Onion URLs.

Without MapAddress: somewhereInTheDarks45h5f8h76sd7f98h7sd9h6sg876hsl.org<br/>
With MapAddress: cool-service.nx

### [Monero Node](https://www.getmonero.org/resources/moneropedia/node.html)

We provide a private [Monero Node](https://www.getmonero.org/resources/moneropedia/node.html) for all viewers of this repository to process your [Monero](https://en.wikipedia.org/wiki/Monero) transactions through our transparent infrastructure:

```
Recommended MapAddress: monero.nx
Hostname: jj6qehtyrfvvi4gtwttpg2qyaukqzxwaoxvak534nidlnnelmqtlm3qd.onion
Port: 18081
Username: Monerochan
Password: iL0VEMoNeRoChan<3

Providing system: mracek.systems.nx
Configurtion: https://github.com/Arcanyx-org/NiXium/blob/central/src/nixos/machines/mracek/services/monero.nix
```

The node is set up to communicate with the outside world exclusively via Tor-only including it's synchronization with the blockchain for added security and privacy.

#### Beware of deanonymization methods using probabilistic attacks

Please be aware of the probabilistic attack demonstrated by [chainlysis](https://www.chainalysis.com) that can successfully deanonymize the transactions and identities of monero users if:

0. You use an insecure Operating System with proprietary code components.
1. You do not use Tor or have it configured incorrectly.
2. If you do not run your own node then you won't get the benefit of [Dandelion++](https://web.getmonero.org/2020/04/18/dandelion-implemented.html) which is assumed to significantly reduce the effectiveness of the probabilistic attacks.
3. you are changing the default fee rate and ensuring that your used wallet doesn't change this in an indentifiable way.
4. Use exchange services that require [Know Your Customer](https://en.wikipedia.org/wiki/Know_your_customer) identification e.g. photo of Citizen ID Card <ins>or share data with threat actors</ins>.

References:
* Original Leaked presentation: http://dreadytofatroptsdj6io7l3xptbet6onoyno2yv7jicoxknyazubrad.onion/monero-chain.mp4
* Detailed explanation on: http://dreadytofatroptsdj6io7l3xptbet6onoyno2yv7jicoxknyazubrad.onion/post/6de54b143e669e368af6

For those reasons we currently do not recommend stack wallet until the following issue is addressed: https://github.com/cypherstack/stack_wallet/issues/1066

To manage the risk of rogue exchange services, consider using [Haveno](https://haveno.exchange).

#### Post-Quantum Threat

All encrypted transactions on Monero are most likely being harvested by threat actors in a technique called [Harvest Now, Decrypt Later](https://en.wikipedia.org/wiki/Harvest_now,_decrypt_later) which stores the encrypted data until a breakthrough in technology is discovered that enables them to be decrypted.

Monero is currently vulnerable to this threat until the [FCMP++](https://www.reddit.com/r/Monero/comments/1fxee4h/explained_moneros_fcmp_explained_for_beginners)/[Carrot](https://github.com/jeffro256/carrot/blob/master/carrot.md) functionality is implemented.

* https://github.com/monero-project/research-lab/issues/131#issuecomment-2613839657

### [Vikunja](https://vikunja.io)

The open-source to-do app, access is provided upon special request.

```
Recommended MapAddress: vikunja.nx
Hostname: u65cyt3tdc66u7ciin55atl5sattytx3rjzzrzhlfdfc2t7pqbhyd6qd.onion
Port: 80

Providing system: mracek.systems.nx
Configurtion: https://github.com/Arcanyx-org/NiXium/blob/central/src/nixos/machines/mracek/services/vikunja.nix
```

This service is mostly used internally to organize private projects. We recommend you to use the [Vikunja Cloud Services](https://vikunja.cloud) instead to support the upstream developers if you are not in position to self-host it.

## Claim of "NX" Custom Top Level Domain

This repository claims the "NX" as it's Custom Top Level Domain ("cTLD") and kindly asks all DNS providers and Network Solutions to acknowledge it, we don't recognize the Internet Corporation for Assigned Names and Numbers ("ICANN") as authority due to their monopolistic position on assignments of Top Level Domains and their unreasonable high fees for cTLDs to attempt to decentralize this assignment.

## Contributions

### Generic Changes

All changes need to be discussed in a form of an issue to be approved for merge with the exception of "Tagged Code" which is always up for grabs.

### Tagged Code

Tagged Code is code that has a "tag" over it:

```nix
# FIXME-QA(Krey): Make it possible to accept list of strings for better readability without the `toString`
# FIXME-QA(Krey): Figure out how to get a list of unsigned integers into a string `${toString config.services.tor.settings.SOCKSPort}` in `proxy` and `tx-proxy` for Tor port
# FIXME-UPSTREAM(Krey): These options should be added to NixOS Module for better maintanability
services.monero.extraConfig = toString [
  "prune-blockchain=1" # Use the pruned blockchain to save space
  "proxy=127.0.0.1:9050" # Use Tor Proxy to access the internet
  ...
];
```

Which is the self-review which the developer adds in a scenario where they were unable to address the issue in a reasonable amount of time during their development which doesn't block merge. Those are often cosmetic, maintainability and readability issues. If you use the repository-provided vscodium, then you will get a configured extension to find these easily or you can run:

```console
$ grep -A 10 -rP "(FIXME|DOCS|)((\\-.*|)\\(.*\\))" /path/to/this/repository
```

To get them printed in your terminal.

### Peer-Review The Code

The used programming, scripting and frameworking languages are separated into invidual files and all follow coding standardization, any peer-review is always very appreciated.

Notes to the implementation:

* **POSIX Shell Script:** The environment and libraries are managed by the Nix Daemon so they do not include shebang and bash options as those are supplemented by Nix, all these files should include notice at the first line about this management (please report this to us if it's not present). Additionally Nix runs these files through a very strict [shellcheck](https://www.shellcheck.net) where any unhandled failure or warning will terminate evaluation with detailed info about the isuse prior to executing the script.
* **Nix Language:** Is the sole exception that does not follow the standard coding practices provided by upstream as they are considered not sensible and introduce too many security issues that are not fixable at the current NixOS Foundation Administration chaired by Eelco Dolstra for us to be in the process of writting an alternative one. [NixOS/nixpkgs/133088](https://github.com/NixOS/nixpkgs/issues/133088) [NixOS/nixpkgs/133089](https://github.com/NixOS/nixpkgs/issues/133089) [NixOS/nixpkgs/243089](https://github.com/NixOS/nixpkgs/pull/241360) [NixOS/nixpkgs/254625](https://github.com/NixOS/nixpkgs/issues/254625) [NixOS/nixpkgs/296013](https://github.com/NixOS/nixpkgs/issues/296013) [NixOS/nixpkgs/296013](https://github.com/NixOS/nixpkgs/pull/324693)

### Donate - Finance

For financial aid to help us maintain the system and continue provide the public services we accept Monero, refer to https://github.com/Kreyren#donate for details.

### Donate - Hardware

Maintaining a secure infrastructure is a challenging task to do in an independent and reliable way, for that we ask for your help in sourcing the hardware to aid us in being able to provide the needed processing resources for our workflow.

If you want to donate Hardware then contact [@Kreyren](https://github.com/Kreyren) or make a new issue, preferably in the central europe area.

#### Apple M1~M4 Pro/Max/Ultra

We mainly want the chips from these devices to put them on OSHW hardware so even devices that suffered a fatal hardware failure are very appreciated.

#### Snapdragon 845

Devices with Snapdragon 845 such as OnePlus 6, Xiaomi Mi 8, Xiaomi POCO F1, etc.. have linux mainline support and can be salvaged for single board computers or personal devices for the infrastructure members or to refurbish them and provide them with pre-installed linux distribution for the general public.

#### [Xiaomi POCO X3 Pro (xiaomi-vayu)](https://wiki.postmarketos.org/wiki/Xiaomi_POCO_X3_Pro_(xiaomi-vayu))

Next-Gen Mobile device with projected decent linux mainline support which often suffers a hardware failure due to insufficient cooling that melts the solder on internal electronics to render them disfuncitonal to be a point of interest for development.

#### Snapdragon X Elite

Point of interest device for development. - Potential for use in thin clients

#### Snapdragon XR2

Point of Interest device for VR/AR development.

#### Intel Z690-A/Z790-P

Point of interest for x86 coreboot and hardening development as on-demand alternative to arm.

#### AMD Phoenix

Devices with AMD Phoenix architecture are projected to have Proof-of-Concept code for [OpenSIL](https://github.com/openSIL/openSIL) to be used for development and research so that our infrastructure has the option of smooth transition if needed.

#### Broken Hardware

We are almost always accepting any functional or broken hardware (notebooks, phones, PCs, etc..) to either refurbish for resell or add to our infrastructure.

# References

## Manuals

* [home-manager's options](https://nix-community.github.io/home-manager/options.html)

## Guides

* [NixOS Flakes Wiki](https://nixos.wiki/wiki/Flakes)
* [Nix Flakes, Part 3: Managing NixOS systems - Eelco Dolstra](https://www.tweag.io/blog/2020-07-31-nixos-flakes/)
* [NixOS Configuration with Flakes - jordanisaacs](https://jdisaacs.com/series/nixos-desktop/)
* [The working programmer’s guide to setting up Haskell projects - jonascarpay](https://jonascarpay.com/posts/2021-01-28-haskell-project-template.html)
* [Shell Scripts with Nix - Jon Sangster](https://ertt.ca/nix/shell-scripts/)
* [OpenSSH security and hardening - Linux Audit](https://linux-audit.com/audit-and-harden-your-ssh-configuration)
* [sshd_config - How to configure the OpenSSH server - www.ssh.com](https://www.ssh.com/academy/ssh/sshd_config)
* [openssh - mozilla](https://infosec.mozilla.org/guidelines/openssh.html)
* [Arch security wiki](https://wiki.archlinux.org/title/security)
* [Arch openssh wiki](https://wiki.archlinux.org/title/OpenSSH)
* [Ask for a password in POSIX-compliant shell? - stackexchange](https://unix.stackexchange.com/questions/222974/ask-for-a-password-in-posix-compliant-shell)
* [Shell Stlye Guide - google](https://google.github.io/styleguide/shellguide.html)
* [Parameter Expansion - The Open Group Base Specifications Issue](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02)
* [Here Documents](https://linux.die.net/abs-guide/here-docs.html)
* [getopt, getopts or manual parsing - what to use when I want to support both short and long options?](https://unix.stackexchange.com/questions/62950/getopt-getopts-or-manual-parsing-what-to-use-when-i-want-to-support-both-shor)
* [How to autorebase MRs in GitLab CI - Marcin Wosinek](https://how-to.dev/how-to-autorebase-mrs-in-gitlab-ci)
* https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/
* [Paranoid NixOS Setup - Christine Dodrill](https://xeiaso.net/blog/paranoid-nixos-2021-07-18)

*Feel Free To Contribute Relevant Topics*

## NixOS Configs

Collection of NixOS configurations that you might find useful as a reference for your configuration:

* https://github.com/Mic92/dotfiles
* https://github.com/jordanisaacs/dotfiles
* https://github.com/jordanisaacs/dwm-flake
* https://github.com/gvolpe/nix-config
* https://github.com/divnix/digga
* https://github.com/mitchellh/nixos-config
* https://codeberg.org/matthew/nixdot
* https://github.com/terlar/nix-config
* https://github.com/qbit/xin
* https://github.com/mrjones2014/dotfiles
* https://git.sr.ht/~x4d6165/nix-configuration
* https://github.com/TLATER/dotfiles
* https://gitlab.com/engmark/root
* https://codeberg.org/samuelsung/nixos-config (flake-parts)
* https://github.com/srid/nixos-config (flake-parts)
* https://github.com/Mic92/dotfiles (flake-parts)
* https://github.com/chvp/nixos-config
* https://github.com/NickCao/flakes (agenix)
* https://github.com/ocfox/den (agenix)
* https://github.com/Clansty/flake (flakes + deploy-rs)
* https://github.com/fufexan/dotfiles (flakes + agenix + flake-parts + home-manager)
* https://github.com/gvolpe/nix-config
* https://github.com/cole-h/nixos-config (flakes + agenix)
* https://github.com/moni-dz/nix-config (flakes + flake-parts + agenix + home-manager + darwin)
* https://github.com/vkleen/machines
* https://github.com/wimpysworld/nix-config
* https://github.com/gvolpe/nix-config

*Feel Free To Add Yours*

Relevant References through GitHub Querries:

* https://github.com/topics/nixos-configuration -- for other public nixos configurations
* https://github.com/search?q=flake.homeManagerModules&type=code -- home-manager references
* https://github.com/search?q=flake-parts+path%3Aflake.nix&type=code&p=3 -- GitHub repositories which use flake-parts

## Relevant Projects

* [flake-compat](https://github.com/edolstra/flake-compat)
* [sops-nix](https://github.com/Mic92/sops-nix)
* [NixOS hardware repo](https://github.com/NixOS/nixos-hardware)
* [update-flake-lock](https://github.com/DeterminateSystems/update-flake-lock)
* [arkenfox's user.js](https://github.com/arkenfox/user.js)
* [de956's browser-privacy](https://github.com/de956/browser-privacy)
* https://github.com/redcode-labs/RedNixOS

## Krey Nix Tips

### Update your NixOS and other inputs

To update NixOS (and other inputs) run `nix flake update`

You may also update a subset of inputs, e.g.

```console
$ nix flake lock --update-input nixpkgs --update-input home-manager
```

Credit: [Samuel Sung](https://codeberg.org/samuelsung)

### Free Up The Disk Space

To free up disk space you can clear unused nixos generations

```console
# nix-env -p /nix/var/nix/profiles/system --delete-generations +2 # Remove all NixOS Generations but last 2
# nixos-rebuild boot # Build a new generation and deploy it on next reboot
```

This can easily safe you few Gigabytes if you don't have set maximum number of generations.

Credit: [Samuel Sung](https://codeberg.org/samuelsung)

*Feel Free To Add Your Tips*
