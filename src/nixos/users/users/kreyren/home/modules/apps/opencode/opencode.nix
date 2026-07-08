{ config, lib, ... }:

let
	inherit (lib) mkForce;
	inherit (builtins) toJSON;
in {
	age.secrets.opencode-auth = {
		file = ./kreyren-opencode-auth.age;
		mode = mkForce "0400";
		path = mkForce "${config.home.homeDirectory}/.local/share/opencode/auth.json";
		symlink = false;
	};

	xdg.configFile."opencode/opencode.json".text = toJSON {
		"$schema" = "https://opencode.ai/config.json";
		agent = {
			plan = {
				model = "openrouter/openrouter/free";
			};
			build = {
				model = "openrouter/openrouter/free";
			};
		};
		default_agent = "plan";
		enabled_providers = [ "openrouter" "opencode" ];
		provider = {
			openrouter = {
				npm = "@ai-sdk/openai-compatible";
				options = {
					baseURL = "https://openrouter.ai/api/v1";
					toolParser = [
						{ type = "raw-function-call"; }
						{ type = "json"; }
					];
				};
				models = {
					"google/gemma-4-31b-it" = {
						name = "Gemma 4 31B";
						tool_call = true;
						limit = {
							context = 65536;
							output = 4096;
						};
						options = {
							include_reasoning = true;
							temperature = 0.0;
						};
					};
				};
			};
		};

		model = "opencode/big-pickle";

		# opencode provider is auto-loaded (no explicit config needed)
		# Model: opencode/big-pickle (free stealth model)
		# Auth: managed via /connect in opencode CLI

		autoupdate = false;
	};
}
