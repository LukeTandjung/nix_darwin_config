{ pkgs, ... }:

{
  # 1) Core engine settings
  stylix.enable = true;
  stylix.autoEnable = true;

  # 2) Inline Base16 “Bauh Nord” scheme
  stylix.base16Scheme = {
    scheme = "Kanagawa";
    author = "Tommaso Laurenzi (https://github.com/rebelot)";
    base00 = "1F1F28";
    base01 = "16161D";
    base02 = "223249";
    base03 = "54546D";
    base04 = "727169";
    base05 = "DCD7BA";
    base06 = "C8C093";
    base07 = "717C7C";
    base08 = "C34043";
    base09 = "FFA066";
    base0A = "C0A36E";
    base0B = "76946A";
    base0C = "6A9589";
    base0D = "7E9CD8";
    base0E = "957FB8";
    base0F = "D27E99";
  };

  # 3) Fonts
  stylix.fonts = {
    monospace = {
      package = pkgs.jetbrains-mono;
      name = "JetBrains Mono";
    };
    sansSerif = {
      package = pkgs.jetbrains-mono;
      name = "JetBrains Mono";
    };
    serif = {
      package = pkgs.jetbrains-mono;
      name = "JetBrains Mono";
    };
    emoji = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrains Mono NF";
    };

    sizes = {
      applications = 14;
      desktop = 12;
      popups = 12;
      terminal = 14;
    };
  };

  # 4) Now these will be valid because stylix.nixosModules.stylix was already imported
}
