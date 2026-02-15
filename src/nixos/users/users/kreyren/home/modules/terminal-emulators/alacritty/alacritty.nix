{ ... }:

# Common configuration of Alacritty

{
	programs.alacritty.settings = {
		keyboard.bindings = [
			{	mods = "Control"; key = "Plus"; action = "IncreaseFontSize"; }
			{	mods = "Control"; key = "Minus"; action = "DecreaseFontSize"; }
			{	mods = "Control"; key = "Equals"; action = "ResetFontSize"; }
		];
	};
}
