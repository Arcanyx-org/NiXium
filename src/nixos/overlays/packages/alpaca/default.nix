final: prev: {
	alpaca = prev.python3Packages.buildPythonApplication.overrideAttrs (super: {
		alpaca = {
			src = prev.fetchFromGitHub {
				owner = "Jeffser";
				repo = "Alpacaaa";
				tag = "7.5.5";
				hash = "sha256-HxcmfLjiHRNHoaD5zRh+K3dgjg9qmo3b//DbA1mm0Qo=";
			};
		};
		# nativeBuildInputs = super.nativeBuildInputs ++ [
		# 	pkgs.gobject-introspection
		# 	pkgs.python3Packages.pygobject3
		# 	pkgs.python3Packages.gst-python
		# 	pkgs.portaudio
		# ];
		# dependencies = super.dependencies ++ (with pkgs.python3Packages; [
		# 	pytube
		# 	markitdown
		# 	openai-whisper
		# 	# koroko
		# 	opencv4 # or opencv-python
		# 	lxml
		# 	duckduckgo-search
		# ]);
	});
}
