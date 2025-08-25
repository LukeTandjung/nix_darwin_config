{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  home.username = "luketandjung";
  home.homeDirectory = "/Users/luketandjung"; # Standard macOS home directory path
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
  programs.zsh.enable = true;

  # Adds config file to oh-my-poshi
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromJSON (builtins.readFile ./kanagawa.omp.json);
  };

  # Adds config file to skhd
  services.skhd = {
    enable = true;
    config = ''
      cmd - left : yabai -m window --focus west
      cmd - down : yabai -m window --focus south
      cmd - up : yabai -m window --focus north
      cmd - right : yabai -m window --focus east

      cmd + shift - left : yabai -m window --warp west
      cmd + shift - down : yabai -m window --warp south
      cmd + shift - up : yabai -m window --warp north
      cmd + shift - right : yabai -m window --warp east

      cmd - 0x1B : yabai -m window --resize rel:-50:-50
      cmd - 0x18 : yabai -m window --resize rel:50:50

      cmd - 0x12 : yabai -m space --focus 1
      cmd - 0x13 : yabai -m space --focus 2
      cmd - 0x14 : yabai -m space --focus 3
      cmd - 0x15 : yabai -m space --focus 4
      cmd - 0x17 : yabai -m space --focus 5

      cmd + shift - 0x12 : yabai -m window --space 1; yabai -m space --focus 1
      cmd + shift - 0x13 : yabai -m window --space 2; yabai -m space --focus 2
      cmd + shift - 0x14 : yabai -m window --space 3; yabai -m space --focus 3
      cmd + shift - 0x15 : yabai -m window --space 4; yabai -m space --focus 4
      cmd + shift - 0x17 : yabai -m window --space 5; yabai -m space --focus 5

      cmd - 0x0C : open -na kitty
      cmd - 0x0E : open -a Finder
      cmd - 0x07 : kill $(yabai -m query --windows --window | jq '.pid')
    '';
  };

  # Zed Editor Configuration
  programs.zed-editor = {
    enable = true;
    extraPackages = [ pkgs.nodejs_22 ]; # Ensure nodejs_22 is available on macOS
    userSettings = {
      node = {
        path = lib.getExe pkgs.nodejs_22;
        npm_path = lib.getExe' pkgs.nodejs_22 "npm";
      };
      tab_size = 2;
      languages = {
        Python = {
          language_servers = [
            "pyright"
            "ruff"
          ];
        };
      };
      direnv = {
        enable = true;
      };
      helix_mode = true;
      show_edit_predictions = false;
      buffer_font_size = lib.mkForce 14.0;
      ui_font_size = lib.mkForce 14.0;
    };
  };

  # Direnv Configuration
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Vesktop Configuration
  programs.vesktop.enable = true;

  # Kitty Configuration
  programs.kitty = {
    enable = true;
  };

  # Helix Configuration
  programs.helix = {
    enable = true;
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
      }
      {
        name = "typst";
        auto-format = true;
        formatter.command = "typstyle";
      }
    ];
  };

  # Btop Configuration
  programs.btop = {
    enable = true;
  };

  # Htop Configuration
  programs.htop = {
    enable = true;
  };

  # Zellij Configuration
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    attachExistingSession = true;
    exitShellOnExit = true;
  };

  # Spotify-player Configuration
  programs.spotify-player.enable = true;

  # LazyDocker Configuration
  programs.lazydocker.enable = true;

  # Zen Browser Configuration
  programs.zen-browser = {
    enable = true;
    profiles.luke = {
      isDefault = true;
      settings = {
        "zen.welcome-screen.seen" = true;
      };
    };
  };

  stylix.targets.zen-browser.profileNames = [ "luke" ];

  # --- Package Management ---
  home.packages = [
  ];

  # This suppresses the login message that appears for Kitty!
  home.file.".hushlogin".text = "";

  # --- MIGRATING YOUR RICE ---
  # Use home.file.source to manage raw configuration files.
  # Ensure these paths exist in your repo (e.g., ~/nix-darwin)

  # Aerospace Configuration
  # home.file.".config/aerospace/aerospace.toml".source = ./config/aerospace/aerospace.toml;

  # Sketchybar Configuration
  # home.file.".config/sketchybar/sketchybarrc".source = ./config/sketchybar/sketchybarrc;
  # home.file.".config/sketchybar/icons".source = ./config/sketchybar/icons; # Example for other files
}
