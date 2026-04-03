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
			copyindent = true; # Re-use the current indentation style when opening a new line
			expandtab = false; # Keep real tab characters; do not replace <TAB> with spaces
			hidden = true; # Allow switching buffers without saving; unsaved changes are preserved
			history = 1000; # Remember up to 1000 commands and search patterns in history
			ignorecase = false; # Searches are case-sensitive by default
			modeline = true; # Honor per-file modeline directives (e.g. `# vim: set ft=sh:`)
			mouse = "a"; # Enable mouse support in all modes (normal, visual, insert, command, …)
			mousefocus = true; # Automatically focus the window under the mouse pointer (GUI builds only)
			mousehide = true; # Hide the mouse pointer while typing to avoid visual clutter
			#mousemode = "extend"; # Mode, one of "extend", "popup", "popup_setpos"
			number = true; # Show absolute line numbers; must be set explicitly because vim-numbertoggle controls this
			relativenumber = true; # Show line-distance numbers around the cursor; combines with `number` for hybrid mode
			shiftwidth = 0; # Mirror tabstop for auto-indent width so the two settings never diverge
			# smartcase = true;
			tabstop = 2; # One tab stop equals two columns, matching the project indentation standard
			# FIXME(Krey): Implement undodir and undofile
		};
		extraConfig = concatStringsSep "\n" [
			# Disable Vim's built-in indentexpr for Nix files so the indentation
			# is driven purely by the tabstop/shiftwidth settings below rather
			# than by an indent script that doesn't understand Nix syntax well
			"autocmd FileType nix setlocal indentexpr="
			# Enforce project tab style for every Nix buffer regardless of
			# global defaults or any indent plugin that might be loaded
			"autocmd BufEnter,BufRead *.nix setlocal noexpandtab tabstop=2 shiftwidth=2 softtabstop=0"

			"syntax enable" # Enable syntax highlighting

			# Render invisible characters so whitespace issues are immediately visible:
			#   space → ·   eol → ↵   tab → --▷   trailing → ~
			#   line overflow → >/<
			"set list"
			"set listchars=space:·,eol:↵,tab:--▷,trail:~,extends:>,precedes:<"
			"highlight NonText guifg=#444444 ctermfg=238" # Dim EOL markers so they don't compete with real code
			"highlight SpecialKey guifg=#444444 ctermfg=238" # Dim tab/space markers for the same reason

			# NERDTree — toggle the file-tree sidebar with Ctrl-N
			"nnoremap <C-n> :NERDTreeToggle<CR>"

			# Rainbow parentheses — colorize bracket pairs by nesting depth so
			# deeply nested expressions are easier to parse at a glance
			# (https://github.com/luochen1990/rainbow)
			"let g:rainbow_active = 1" # Enable rainbow coloring globally on startup

			# Indentation rainbow — color each indentation level a distinct hue so
			# deeply nested blocks are easy to track visually, mirroring the
			# oderwat.indent-rainbow extension used in VSCodium
			# (https://github.com/preservim/vim-indent-guides)
			#
			# NOTE: vim-indent-guides is architecturally limited to two alternating
			# highlight groups (IndentGuidesOdd / IndentGuidesEven) — it cannot do
			# per-level coloring the way oderwat.indent-rainbow does.  This is a
			# hard constraint of the plugin; no amount of configuration can add more
			# groups.  If full rainbow coloring is needed, use Neovim instead, which
			# uses indent-blankline-nvim with six distinct per-level colors.
			"let g:indent_guides_enable_on_vim_startup = 1" # Activate on startup without needing :IndentGuidesToggle
			"let g:indent_guides_auto_colors = 0"           # Use manually defined highlight groups instead of auto-derived colors
			# Two vivid alternating colors — teal background for odd levels,
			# purple background for even levels; chosen to be clearly readable on
			# dark backgrounds while staying out of the way of syntax highlighting
			"highlight IndentGuidesOdd  ctermbg=23  guibg=#1d4040"
			"highlight IndentGuidesEven ctermbg=54  guibg=#2d1f3d"
		];

		plugins = [
			pkgs.vimPlugins.vim-numbertoggle # Hybrid absolute/relative line numbers (https://github.com/jeffkreeftmeijer/vim-numbertoggle)
			pkgs.vimPlugins.nerdtree # File-tree sidebar navigator
			pkgs.vimPlugins.vim-commentary # Toggle comments with gc/gcc motions
			pkgs.vimPlugins.vim-strip-trailing-whitespace # Remove trailing whitespace on save
			pkgs.vimPlugins.vim-better-whitespace # Highlight and strip stray whitespace
			pkgs.vimPlugins.rainbow # Colorize parentheses/brackets by nesting depth (https://github.com/luochen1990/rainbow)
			pkgs.vimPlugins.vim-indent-guides # Colorize indentation levels to aid navigation in deeply nested files (https://github.com/preservim/vim-indent-guides)
		];
	};
}
