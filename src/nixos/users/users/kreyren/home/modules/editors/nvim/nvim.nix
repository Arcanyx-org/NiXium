{ pkgs, self, ... }:

# Kreyren's Neovim configuration for quick file edits
#
# Mirrors vim indentation settings from editors/vim/vim.nix
# Reference: https://www.shortcutfoo.com/blog/top-50-vim-configuration-options

let
	inherit (builtins) concatStringsSep;

	# mkVimConfig validates vimscript at build time and returns the content string if valid, failing the build otherwise.  It is defined in lib/mkVimConfig/ and exposed on self.lib so it can be used from any home-manager module that receives `self` via specialArgs
	mkVimConfig = self.lib.mkVimConfig pkgs;
in {
	programs.neovim = {
		extraConfig = mkVimConfig {
			name = "kreyren-nvim-config";
			content = concatStringsSep "\n" [
				"set noexpandtab" # Keep real tab characters; do not replace <TAB> with spaces
				"set tabstop=2" # One tab stop equals two columns, matching the project indentation standard
				"set shiftwidth=0" # Mirror tabstop for auto-indent width so the two settings never diverge
				"set copyindent" # Re-use the current indentation style when opening a new line

				# Disable Vim's built-in indentexpr for Nix files so the indentation is driven purely by the tabstop/shiftwidth settings above rather than by an indent script that doesn't understand Nix syntax well
				"autocmd FileType nix setlocal indentexpr="
				# Enforce project tab style for every Nix buffer regardless of
				# global defaults or any indent plugin that might be loaded
				"autocmd BufEnter,BufRead *.nix setlocal noexpandtab tabstop=2 shiftwidth=2 softtabstop=0"

				# Render invisible characters so whitespace issues are immediately visible:
				#   space → ·   eol → ↵   tab → --▷   trailing → ~
				#   line overflow → >/<
				"set list"
				"set listchars=space:·,eol:↵,tab:--▷,trail:~,extends:>,precedes:<"
				"highlight NonText guifg=#444444 ctermfg=238"    # Dim EOL markers so they don't compete with real code
				"highlight SpecialKey guifg=#444444 ctermfg=238" # Dim tab/space markers for the same reason

				# Rainbow parentheses — colorize bracket pairs by nesting depth so
				# deeply nested expressions are easier to parse at a glance
				# (https://github.com/luochen1990/rainbow)
				"let g:rainbow_active = 1" # Enable rainbow coloring globally on startup

				# Define the six cycling highlight groups consumed by blink-indent
				# below.  These are set here (vimscript) so they are established before
				# the Lua setup() call, which only names them — it does not define colors.
				#
				# NOTE: terminal Neovim cannot background-fill an entire indent column
				# the way VSCodium's oderwat.indent-rainbow extension does, because the
				# virtual-text overlay API only colorizes the guide character itself, not
				# the surrounding whitespace cells.  The ▎ (LEFT ONE QUARTER BLOCK) char
				# chosen below is the widest practical approximation; guifg is used
				# because guibg on virtual-text overlays is ignored by most terminals.
				#
				# Colors mirror the oderwat.indent-rainbow VSCodium extension defaults:
				# red → orange → yellow → green → blue → violet, fully saturated so the
				# thin bar is clearly visible without being overwhelming.
				# cterm values are 256-color approximations for terminals without truecolor.
				"highlight RainbowIndent1 guifg=#E06C75 ctermfg=167" # red
				"highlight RainbowIndent2 guifg=#E5C07B ctermfg=179" # orange/yellow
				"highlight RainbowIndent3 guifg=#E5E56C ctermfg=185" # yellow
				"highlight RainbowIndent4 guifg=#98C379 ctermfg=114" # green
				"highlight RainbowIndent5 guifg=#61AFEF ctermfg=75"  # blue
				"highlight RainbowIndent6 guifg=#C678DD ctermfg=176" # violet
			];
		};

		# blink-indent draws a ▎ (LEFT ONE QUARTER BLOCK) guide character at each
		# indent level, cycling through the six RainbowIndentN highlight groups
		# defined in extraConfig above.  scope is disabled for the same reason as
		# with ibl: it requires treesitter parsers to detect block boundaries.
		# (https://github.com/Saghen/blink.indent)
		extraLuaConfig = ''
			require("blink.indent").setup({
				static = {
					-- ▎ (U+258E LEFT ONE QUARTER BLOCK) gives the widest practical
					-- bar without overflowing into the next column
					char = "▎",
					-- Cycle through the six RainbowIndentN highlight groups so each
					-- indentation level gets a distinct color, mirroring the
					-- oderwat.indent-rainbow extension used in VSCodium
					highlights = {
						"RainbowIndent1",
						"RainbowIndent2",
						"RainbowIndent3",
						"RainbowIndent4",
						"RainbowIndent5",
						"RainbowIndent6",
					},
				},
				-- scope requires treesitter parsers to detect block boundaries;
				-- disabled here to avoid errors when treesitter is not configured
				scope = { enabled = false },
			})
		'';

		plugins = [
			pkgs.vimPlugins.rainbow      # Colorize parentheses/brackets by nesting depth (https://github.com/luochen1990/rainbow)
			pkgs.vimPlugins.blink-indent # Colorize indentation levels to aid navigation in deeply nested files (https://github.com/Saghen/blink.indent)
		];
	};
}
