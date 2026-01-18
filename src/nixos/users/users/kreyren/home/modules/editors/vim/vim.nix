{ config, lib, pkgs, ... }:

# Kreyren's adjustment to Vim, designed to be used for quick file edits

# Reference: https://www.shortcutfoo.com/blog/top-50-vim-configuration-options
# Reference: https://github.com/tpope/vim-sensible/blob/master/plugin/sensible.vim

let
	inherit (lib) mkIf;
in mkIf config.programs.vim.enable {
	programs.vim = {
		settings = {
			# encoding = "utf-8";
			# fileencoding = "utf-8";

			tabstop = 2; # Set indent lenght

			# autoindent = true; # New lines inherit the indentation of previous lines
			# hlsearch = true; # Enable search highlights

			# Show line breaks
			#ffs = "unix";
			# listcharts = "eol:↵";
			# list = true;

			# number = true; # Explicitly has to be `set number` bcs we use vim-numbertoggle plugin

			# scrolloff = 3; # The number of screen lines to keep above and below the cursor

			# wrap = true; # Enable Line Wrapping
			# ruler = true; # Always Show Cursor Positio
			# visualbell = true; # Flash the screen instead of beeping on errors
		};
		extraConfig = builtins.concatStringsSep "\n" [
			"set encoding=utf-8"
			"set fileencoding=utf-8"
			"set ffs=unix"
			"set autoindent"
			"set hlsearch"
			"set list"
			"set listchars=eol:↵"
			"set ruler"
			"set scrolloff=3"
			"set visualbell"
			"set wrap"
			"set number"
			"syntax enable" # Enable syntax highlighting
		];

		plugins = [
			pkgs.vimPlugins.vim-numbertoggle # Intelligent line numbers (https://github.com/jeffkreeftmeijer/vim-numbertoggle)
		];
	};
}
