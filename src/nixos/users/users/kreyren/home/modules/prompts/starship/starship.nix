{ config, pkgs, lib, ... }:

let
	inherit (lib) mkIf mkMerge;
in mkIf config.programs.starship.enable (mkMerge [
	{
		"24.11" = {
			home.packages = [
				# Add the fonts that we are using in the shell
				# FIXME-OPTIMIZE(Krey): This package takes a lot of resources to build and significant amount of resources for few (~5 font characters), we should just include the invidual symbols instead to speed up the evaluation
				# This override was recommended, because nerdfonts might have issues with rendering -- https://github.com/TanvirOnGH/nix-config/blob/nix%2Bhome-manager/desktop/customization/font.nix#L4-L39
				(pkgs.nerdfonts.override { fonts = [ "Noto" "FiraCode"]; }) # Add NerdFont's Noto and FiraCode
			];
		};
		"25.05" = {
			home.packages = [
				# Add the fonts that we are using in the shell
				# FIXME-OPTIMIZE(Krey): This package takes a lot of resources to build and significant amount of resources for few (~5 font characters), we should just include the invidual symbols instead to speed up the evaluation
				# This override was recommended, because nerdfonts might have issues with rendering -- https://github.com/TanvirOnGH/nix-config/blob/nix%2Bhome-manager/desktop/customization/font.nix#L4-L39
				# (pkgs.nerdfonts.override { fonts = [ "Noto" "FiraCode"]; }) # Add NerdFont's Noto and FiraCode
				pkgs.nerd-fonts.noto
				pkgs.nerd-fonts.fira-code
			];
		};
	}."${lib.trivial.release}" or (throw "Release not implemented: ${lib.trivial.release}")
	{
		programs.starship = {
			settings = {
				# ├ ❯ ╰ ─ ┌ ❮	 
				format = builtins.concatStringsSep "\n" [
					''[](#9A348E)$os$username[@](bg:#9A348E)$hostname[](bg:#DA627D fg:#9A348E)$time[](fg:#DA627D bg:#33658A)$cmd_duration[](fg:#33658A)''
					''├─ $directory$all''
				];

				# Timeout for git which appears to require at minimum 300 ms to load all of it's modules
				command_timeout = 300; # ms

				username = {
					show_always = true;
					style_user = "bg:#9A348E";
					style_root = "bg:#9A348E";
					format = "[$user]($style)";
				};

				hostname = {
						ssh_only = false;
						trim_at = "";
						format = "[$ssh_symbol$hostname ](bg:#9A348E)";
					};

				cmd_duration = {
					show_milliseconds = true;
					format = "[ $duration](fg:#FFFFFF bg:#33658A)";
					# FIXME(Krey): Can't be arsed to figure out how to make that work atm
					#min_time = "0_000";
				};

				time = {
					format = "[ $time ](fg:#FFFFFF bg:#DA627D)";
					time_format = "%T %d.%m.%Y %Z";
					disabled = false;
				};

				os = {
					style = "bg:#9A348E";
					disabled = false;
				};

				# FIXME(Krey): This should show exit status as well
				character = {
					format = "╰───$symbol ";
					success_symbol = "[❯](bold green)";
					error_symbol = "[❯](bold red)";
					vimcmd_symbol = "[❮](bold green)";
					vimcmd_replace_one_symbol = "[╰❮](bold purple)";
					vimcmd_replace_symbol = "[❮](bold purple)";
					vimcmd_visual_symbol = "[❮](bold yellow)";
				};
			};
		};
	}
])
