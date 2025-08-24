{
  description = "Luke's Nix Darwin System";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    stylix.url = "github:nix-community/stylix/master";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      stylix,
      nix-darwin,
      home-manager,
      zen-browser,
    }:
    let
      system = "aarch64-darwin";
      # Create a pkgs set that allows unfree
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      configuration =
        {
          pkgs,
          inputs,
          ...
        }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wgeti

          environment = {
            systemPackages = with pkgs; [
              git
              yabai
              raycast
              bartender
              postgresql
              dbeaver-bin
              postman
              notion-app
              typst
              typstyle
              typst-live
              tinymist
              aider-chat
            ];
          };

          system.primaryUser = "luketandjung";

          users.users.luketandjung = {
            name = "luketandjung";
            home = "/Users/luketandjung";
          };

          security.sudo.extraConfig = ''
            %staff ALL = (ALL) NOPASSWD: ALL
          '';

          system.defaults.finder.QuitMenuItem = true;

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";

          fonts.packages = with pkgs; [
            font-awesome
            jetbrains-mono
          ];

          services.spacebar = {
            enable = true;
            package = pkgs.spacebar;
            config = {
              position = "top";
              display = "main";
              height = 36;
              title = "on";
              spaces = "on";
              clock = "on";
              padding_left = 20;
              padding_right = 20;
              spacing_left = 25;
              spacing_right = 15;
              text_font = ''"JetBrains Mono:Regular:12.0"'';
              icon_font = ''"Font Awesome 6 Free:Solid:12.0"'';
              background_color = "0xff1f1f28";
              foreground_color = "0xffdcd7ba";
              power_icon_color = "0xffdcd7ba";
              battery_icon_color = "0xffdcd7ba";
              dnd_icon_color = "0xffdcd7ba";
              clock_icon_color = "0xffdcd7ba";
              power_icon_strip = " ";
              space_icon = "•";
              space_icon_strip = "1 2 3 4 5";
              space_icon_color = "0xff2d4f67";
              clock_icon = "";
              dnd_icon = "";
              clock_format = ''"%d/%m/%y %R"'';
            };
          };

          services.yabai = {
            enable = true;
            config = {
              layout = "bsp";
              window_placement = "second_child";
              top_padding = 16;
              bottom_padding = 16;
              left_padding = 16;
              right_padding = 16;
              window_gap = 16;
              mouse_modifier = "cmd";
              focus_follows_mouse = "autoraise";
              menubar_opacity = 0.0;
              window_opacity = "on";
              active_window_opacity = 1.0;
              normal_window_opacity = 0.80;
              external_bar = "all:40:0";
            };
            extraConfig = ''
              yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
              sudo yabai --load-sa
            '';
          };

          services.postgresql = {
            enable = true;
            package = pkgs.postgresql_16;
            port = 5433;
            authentication = pkgs.lib.mkOverride 10 ''
              #type database  DBuser  auth-method
              local all       all     trust
              host    b_connect_test_db    b_connect_test_user    127.0.0.1/32    scram-sha-256
              host    b_connect_test_db    b_connect_test_user    ::1/128         scram-sha-256
            '';
          };

          system.activationScripts.postgresInit = {
            text = ''
              #!/usr/bin/env bash
              set -euo pipefail

              # wait up to 30s for Postgres to be ready
              for i in $(seq 1 30); do
                if sudo -u postgres psql -p 5433 -c '\q' &>/dev/null; then
                  break
                fi
                sleep 1
              done

              # create the role if it doesn't exist
              if ! sudo -u postgres psql -p 5433 \
                   -tAc "SELECT 1 FROM pg_roles WHERE rolname='b_connect_test_user'" \
                   | grep -q 1; then
                sudo -u postgres psql -p 5433 \
                  -c "CREATE ROLE b_connect_test_user WITH LOGIN PASSWORD '123456';"
              fi

              # create the database if it doesn't exist
              if ! sudo -u postgres psql -p 5433 \
                   -lqt \
                 | cut -d '|' -f1 \
                 | grep -qw b_connect_test_db; then
                sudo -u postgres psql -p 5433 \
                  -c "CREATE DATABASE b_connect_test_db OWNER b_connect_test_user;"
              fi
            '';
          };

          system.activationScripts.postActivation.text = ''
            echo "Updated /private/etc/sudoers.d/yabai successfully!"
            su - "$(logname)" -c '${pkgs.skhd}/bin/skhd -r'
          '';
        };
    in
    {
      darwinConfigurations."Lukes-Mac-mini" = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit pkgs inputs; };
        modules = [
          configuration
          stylix.darwinModules.stylix
          ./stylix.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.luketandjung = ./home.nix;
            home-manager.backupFileExtension = "hm-bak";
            home-manager.sharedModules = [
              inputs.zen-browser.homeModules.beta
            ];
            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
    };
}
