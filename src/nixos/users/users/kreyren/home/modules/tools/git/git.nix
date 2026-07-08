{ config, lib, ... }:

let
	inherit (lib) elem optionalString mkIf mkMerge;
	inherit (lib.trivial) release;
in mkIf config.programs.git.enable (mkMerge [
	{
		"${optionalString (elem release [ "24.05" "24.11" "25.05" ]) release}" = {
			programs.git = {
				userName = "Jacob Hrbek";
				userEmail = "kreyren@fsfe.org";
				signing.key = "D0501F7980EA70D192C03A52667F0DAFAF09BA2B";
				# NOTE(Krey): Temporary disabled due to https://github.com/NixOS/nixpkgs/issues/35464#issuecomment-2134233517
				signing.signByDefault = false;

				delta = {
					enable = config.programs.git.enable;
					# Configuration: https://dandavison.github.io/delta/usage.html
					options = {
						line-numbers = true;
						whitespace-error-style = "22 reverse";
						side-by-side = true;

						features = "decorations";
						decorations = {
							commit-decoration-style = "bold yellow box ul";
							file-decoration-style = "none";
							file-style = "bold yellow ul";
						};
					};
				};

				settings.safe.directory = "/nix/persist/NiXium"; # Consider NiXium Directory Safe

				# TODO(Krey): Pending Management
				# SECURITY(Krey): Contains email password!
				# extraConfig = {
				# 	sendemail = {
				# 		smtpServer = "127.0.0.1";
				# 		smtpUser = "kreyren@proton.me";
				# 		# smtpPass = "REDACTED"; # FIXME-SECURITY(Krey): Set up ragenix for this
				# 		smtpEncryption = "ssl";
				# 		smtpServerport = 1025;
				# 		# Required due to the use of protonmail
				# 		smtpSslCertPath = "";
				# 	};
				# };
			};
		};
		"${optionalString (elem release [ "25.11" "26.05" ]) release}" = {
			programs.git = {
				settings = {
					user = {
						name = "Jacob Hrbek";
						email = "kreyren@fsfe.org";
					};
				};

				signing.key = "D0501F7980EA70D192C03A52667F0DAFAF09BA2B";
				# NOTE(Krey): Temporary disabled due to https://github.com/NixOS/nixpkgs/issues/35464#issuecomment-2134233517
				signing.signByDefault = false;
			};

			programs.delta = {
				enable = config.programs.git.enable;
				enableGitIntegration = config.programs.git.enable;
				options = {
					line-numbers = true;
					whitespace-error-style = "22 reverse";
					side-by-side = true;

					features = "decorations";
					decorations = {
						commit-decoration-style = "bold yellow box ul";
						file-decoration-style = "none";
						file-style = "bold yellow ul";
					};
				};
			};
		};
	}."${release}" or (throw "Release is not implemented: ${release}")
])
