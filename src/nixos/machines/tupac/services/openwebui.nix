{ self, config, lib, pkgs, unstable, ... }:

# TUPAC-specific configuration of Open-WebUI

# FIXME(Krey): Wrong /var/lib/private permissions:
	# Oct 05 08:45:10 tupac systemd[1]: Starting Server for local large language models...
	# Oct 05 08:45:10 tupac (ollama)[281416]: Directory "/var/lib/private" already exists, but has mode 0755 that is too permissive (0700 was requested), refusing.
	# Oct 05 08:45:10 tupac (ollama)[281416]: ollama.service: Failed to set up special execution directory in /var/lib: File exists
	# Oct 05 08:45:10 tupac (ollama)[281416]: ollama.service: Failed at step STATE_DIRECTORY spawning /nix/store/idlkxlr1rqwy9k55kqh5say6ch143vk3-ollama-0.11.10/bin/ollama: File exists
	# Oct 05 08:45:10 tupac systemd[1]: ollama.service: Main process exited, code=exited, status=238/STATE_DIRECTORY
	# Oct 05 08:45:10 tupac systemd[1]: ollama.service: Failed with result 'exit-code'.
	# Oct 05 08:45:10 tupac systemd[1]: Failed to start Server for local large language models.

# FIXME(Krey): Fails to detect GPU:
	# Oct 05 08:46:59 tupac ollama[286890]: time=2025-10-05T08:46:59.408+02:00 level=WARN source=gpu.go:616 msg="unknown error initializing cuda driver library /nix/store/ikx3iqd996g3gk4c5f9sbal75ly1823p-nvidia-x11-570.153.02-6.12.49/lib/libcuda.so.570.153.02: cuda driver library init failure: 999. see https://github.com/ollama/ollama/blob/main/docs/troubleshooting.md for more information"
	# Oct 05 08:46:59 tupac ollama[286890]: time=2025-10-05T08:46:59.412+02:00 level=INFO source=gpu.go:388 msg="no compatible GPUs were discovered"

let
	inherit (lib) mkIf;
in mkIf config.services.open-webui.enable {

	# Ollama
	services.ollama.acceleration = "cuda";
	services.ollama.environmentVariables = {
		# Enable the Nvidia dGPU
			# NOTE(Krey): Those are needed for CUDA support to not fail as it runs on iGPU otherwise (PRIME)
			__NV_PRIME_RENDER_OFFLOAD = toString true;
			__NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
			__GLX_VENDOR_LIBRARY_NAME = "nvidia";
			__VK_LAYER_NV_optimus = "NVIDIA_only";
	};

	# Refer to https://docs.openwebui.com/getting-started/advanced-topics/env-configuration/
	services.open-webui.environment = {
		ENV = "prod"; # Set Production Environment

		CUSTOM_NAME = "NiXium AI";

		# DNM(Krey): This needs to be moved in a secret file and refreshed
		# OLLAMA_BASE_URL = "http://somewhereInTheDark.onion";

		# Registrations
		# ENABLE_SIGNUP = "False";

		DEFAULT_USER_ROLE = "pending";

		# Disable Spyware
			ENABLE_OPENAI_API = "False";
			ANONYMIZED_TELEMETRY = "False";
			DO_NOT_TRACK = "True";
			SCARF_NO_ANALYTICS = "True";
	};

	# services.open-webui.package = unstable.open-webui;

	# Deploy The Onion Service
		services.tor.relay.onionServices."open-webui".map = mkIf config.services.tor.enable [{
			port = 80;
			target = { port = config.services.open-webui.port; };
		}]; # Set up Onionized WebUI

	# Deploy TTS
		systemd.services.openedai-speech = {
			description = "OpenedAI Speech";
			after = [ "network.target" ];
			wantedBy = [ "multi-user.target" ];

			# environment = {
			# 	USE_ROCM = "1";
			# };

			serviceConfig = {
				ExecStartPre = "-${self.inputs.nur-xddxdd.packages.x86_64-linux.openedai-speech}/bin/download_voices_tts-1.sh";
				ExecStart = "${self.inputs.nur-xddxdd.packages.x86_64-linux.openedai-speech}/bin/openedai-speech";
				Restart = "always";
				RestartSec = "3";

				StateDirectory = "openedai-speech";
				WorkingDirectory = "/var/lib/openedai-speech";

				User = "openedai-speech";
				Group = "openedai-speech";
			};
		};

		users.users.openedai-speech = {
			group = "openedai-speech";
			isSystemUser = true;
		};
		users.groups.openedai-speech = { };

		# https://docs.openwebui.com/getting-started/env-configuration/
		services.open-webui.environment = {
			# Set the Voice in OWUI
			AUDIO_TTS_ENGINE = "openai";
			AUDIO_TTS_API_KEY = "unused";
			AUDIO_TTS_OPENAI_API_BASE_URL = "http://127.0.0.1:8000/v1";
			AUDIO_TTS_OPENAI_API_KEY = "unused";
			AUDIO_TTS_MODEL = "tts-1";
			AUDIO_TTS_VOICE = "alloy";
			AUDIO_TTS_SPLIT_ON = "punctuation";

			# Web Search
			ENABLE_WEB_SEARCH = "True";
			ENABLE_SEARCH_QUERY_GENERATION = "True"; # Enables or disables search query generation
			WEB_SEARCH_TRUST_ENV = "False"; # Enables proxy set by http_proxy and https_proxy during web search content fetching.
			WEB_SEARCH_RESULT_COUNT = "5"; # Maximum number of search results to crawl
			WEB_SEARCH_CONCURRENT_REQUESTS = "10"; # Number of concurrent requests to crawl web pages returned from search results
			WEB_SEARCH_ENGINE = "searxng";
			BYPASS_WEB_SEARCH_EMBEDDING_AND_RETRIEVAL = "False"; # Bypasses the web search embedding and retrieval process
			SEARXNG_QUERY_URL = "http://localhost:3002/search?q=<query>"; # The SearXNG search API URL supporting JSON output. <query> is replaced with the search query. Example: http://searxng.local/search?q=<query>

			# Image Generation
			ENABLE_IMAGE_GENERATION = "True";
			IMAGE_GENERATION_ENGINE = "comfyui";
			COMFYUI_BASE_URL = "http://127.0.0.1:7860";
		};

		services.searx.enable = true;
		services = {
			searx = {
				settings = {
					use_default_settings = true;

					general = {
						privacypolicy_url = false;
						enable_metrics = true;
						debug = false;
					};

					default_doi_resolver = "sci-hub.se";

					server = {
						port = 3002;
						bind_address = "127.0.0.1";
						secret_key = "justLocalThings";
						image_proxy = true;
						base_url = "/searx";
						limiter = false;
						public_instance = false;
					};

					enabled_plugins = [
						"Hash plugin"
						"Search on category select"
						"Tracker URL remover"
						"Hostname replace"
						"Unit converter plugin"
						"Basic Calculator"
						"Open Access DOI rewrite"
					];

					search = {
						safe_search = 0; # 0 = None, 1 = Moderate, 2 = Strict
						formats = [
							"html"
							"json"
							"rss"
						];
						# autocomplete = "google"; # "dbpedia", "duckduckgo", "google", "startpage", "swisscows", "qwant", "wikipedia" - leave blank to turn it off by default
						default_lang = "en";
					};
				};
			};
		};

	services.comfyui = {
		enable = false;
		acceleration = "cuda";
		port = 7860;
		models = lib.attrsets.attrVals [
			# Commented models are gated and require special tokens to access
			# "christmas-couture-lora"
			# "flux-ae"
			# "flux-text-encoder-1"
			# "flux1-dev-q4_0"

			"hyper-sd15-1step-lora"
			"ltx-video"
			"stable-diffusion-v1-5"
			"t5-v1_1-xxl-encoder"
			"t5xxl_fp16"
			# "sams"
			"ultrarealistic-lora"
		] pkgs.nixified-ai.models ;
		customNodes = with self.inputs.nixified-ai.packages.x86_64-linux.comfyui-nvidia.pkgs; [
			comfyui-gguf
			comfyui-impact-pack
		];
	};
	nix.settings.trusted-substituters = ["https://ai.cachix.org"];
	nix.settings.trusted-public-keys = ["ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="];

	# Ananicy process scheduling for AI stack
	services.ananicy.extraRules = [
		{ name = "ollama"; type = "LLM-Inference"; } # Responsive LLM inference
		{ name = "comfyui"; type = "LLM-Inference"; oom_score_adj = 500; } # Kill first on OOM (heavy VRAM)
		{ name = "uvicorn"; type = "Service"; } # Open-WebUI web server
		{ name = "openedai-speech"; type = "Player-Audio"; } # TTS responsiveness
	];

	# Impermanence
	# environment.persistence."/nix/persist/system".directories = mkIf config.boot.impermanence.enable [
	# 	# FIXME(Krey): This is a temporary solution as the models should be set declaratively
	# 	{ directory = "/var/lib/ollama/models"; user = "ollama"; group = "ollama"; mode = "u=rwx,g=rwx,o="; } # Persist the models
	# ];
}
