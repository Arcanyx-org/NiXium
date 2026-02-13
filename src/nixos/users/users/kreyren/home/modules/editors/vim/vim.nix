{ config, lib, pkgs, ... }:

# Kreyren's adjustment to Vim, designed to be used for quick file edits

# Reference: https://www.shortcutfoo.com/blog/top-50-vim-configuration-options
# Reference: https://github.com/tpope/vim-sensible/blob/master/plugin/sensible.vim

let
	inherit (lib) mkIf;
	inherit (builtins) concatStringsSep;
in mkIf config.programs.vim.enable {
	programs.vim = {
		settings = {
			# backgroud = "dark"; # Vim sets this automatically based on system
			copyindent = true; # Re-Use the current indentation in the file
			expandtab = false; # Turning all tabs into spaces on <TAB> press
			hidden = true; # Allows escaping current buffer without saving changes
			history = 1000; # Set how many entries vim menu remembers
			ignorecase = false; # Make all searches case-insensitive
			modeline = true; # Support modelines in files that specify code formatting
			mouse = "a"; # Enable mouse support based on mode, one of n v i c h a r
			mousefocus = true; # Set window active on mouse hover (GUI-only)
			mousehide = true; # Hides the mouse pointer while typing to keep the screen clear
			#mousemode = "extend"; # Mode, one of "extend", "popup", "popup_setpos"
			number = true; # Explicitly has to be `set number` bcs we use vim-numbertoggle plugin
			relativenumber = true; # Show number based on cursor distance, when used with number it uses hybrid mode
			shiftwidth = 0; # Set number of spaces for auto-indent
			# smartcase = true;
			tabstop = 2; # Set indent lenght
			# FIXME(Krey): Implement undodir and undofile
		};
		extraConfig = concatStringsSep "\n" [
			"autocmd FileType nix setlocal indentexpr="
			"autocmd BufEnter,BufRead *.nix setlocal noexpandtab tabstop=2 shiftwidth=2 softtabstop=0"

			"syntax enable" # Enable syntax highlighting
			"set list"
			"set listchars=space:·,eol:↵,tab:--▷,trail:~,extends:>,precedes:<"
			"highlight NonText guifg=#444444 ctermfg=238" # Change color of EOL character to be less visible
			"highlight SpecialKey guifg=#444444 ctermfg=238" # Make tab characters less visible

			# NERDTree
			"nnoremap <C-n> :NERDTreeToggle<CR>"
		];

		plugins = [
			pkgs.vimPlugins.vim-numbertoggle # Intelligent line numbers (https://github.com/jeffkreeftmeijer/vim-numbertoggle)
			pkgs.vimPlugins.nerdtree
			pkgs.vimPlugins.vim-commentary
			pkgs.vimPlugins.vim-strip-trailing-whitespace
			pkgs.vimPlugins.vim-better-whitespace
		];
	};
}
