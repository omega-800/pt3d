{
  description = "typst development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    typix = {
      url = "github:loqusion/typix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      typix,
      nix-github-actions,
      pre-commit-hooks,
      treefmt-nix,
      self,
    }:
    let
      systems = nixpkgs.lib.platforms.unix;
      eachSystem =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              config = { };
              overlays = [ ];
            }
          )
        );
      treefmt = eachSystem (
        pkgs:
        treefmt-nix.lib.evalModule pkgs (_: {
          projectRootFile = "flake.nix";
          programs = {
            # typst
            # typstyle.enable = true;
            # markdown
            mdformat.enable = true;
            # nix
            nixfmt.enable = true;
            statix.enable = true;
            # TODO: plantuml
          };
        })
      );
      mkApp = drv: {
        type = "app";
        program = "${drv}${drv.passthru.exePath or "/bin/${drv.pname or drv.name}"}";
      };
      typixPkgs =
        pkgs:
        let
          typixLib = typix.lib.${pkgs.system};
          sources = [ "examples/main.typ" ];
          commonArgs = {
            typstSource = builtins.elemAt sources 0;
            fontPaths = with pkgs; [
              "${nerd-fonts.jetbrains-mono}/share/fonts/truetype"
              "${fira-math}/share/fonts/opentype"
            ];
            virtualPaths = [ ];
          };
          extraArgs = {
            src = typixLib.cleanTypstSource ./.;
            unstable_typstPackages = [ ];
          };
          watchScriptsPerDoc = map (
            typstSource:
            typixLib.watchTypstProject (
              commonArgs
              // {
                inherit typstSource;
                typstOutput = (pkgs.lib.removeSuffix ".typ" typstSource) + ".pdf";
              }
            )
          ) sources;
          watch-script = typixLib.watchTypstProject commonArgs;
        in
        {
          inherit
            typixLib
            commonArgs
            extraArgs
            watch-script
            ;
          build-drv = typixLib.buildTypstProject (commonArgs // extraArgs);
          build-script = typixLib.buildTypstProjectLocal (commonArgs // extraArgs);
          watch-all = pkgs.writeShellApplication {
            text = "(trap 'kill 0' SIGINT; ${
              pkgs.lib.concatMapStringsSep " & " (s: "${s}/bin/typst-watch") watchScriptsPerDoc
            })";
            name = "typst-watch-all";
          };
          watch-open = pkgs.writeShellApplication {
            text = "${pkgs.writeShellScript "watch-with-zathura" ''
              (trap 'kill 0' SIGINT; ${pkgs.zathura}/bin/zathura "$PWD/${
                builtins.replaceStrings [ ".typ" ] [ "" ] commonArgs.typstSource
              }.pdf" &
              ${(mkApp watch-script).program})
            ''}";
            name = "typst-watch-open";
          };
        };
    in
    {
      packages = eachSystem (pkgs: {
        default = (typixPkgs pkgs).build-drv;
      });

      apps = eachSystem (
        pkgs:
        let
          inherit (typixPkgs pkgs) watch-script build-script watch-open;
          wopen = mkApp watch-open;
        in
        {
          inherit wopen;
          default = wopen;
          build = mkApp build-script;
          watch = mkApp watch-script;
        }
      );

      devShells = eachSystem (
        pkgs:
        let
          inherit (typixPkgs pkgs)
            watch-script
            watch-open
            build-script
            watch-all
            commonArgs
            typixLib
            ;
          inherit (self.checks.${pkgs.system}) pre-commit-check;
        in
        {
          default = typixLib.devShell {
            buildInputs = pre-commit-check.enabledPackages;
            inherit (pre-commit-check) shellHook;
            inherit (commonArgs) fontPaths virtualPaths;
            packages = [
              build-script
              watch-script
              watch-open
              watch-all
              pkgs.typstyle
            ];
          };
        }
      );

      checks = eachSystem (pkgs: {
        pre-commit-check = pre-commit-hooks.lib.${pkgs.system}.run {
          # TODO: filter src
          src = ./.;
          hooks = {
            treefmt = {
              enable = true;
              packageOverrides.treefmt = self.formatter.${pkgs.system};
            };
          };
        };
      });

      formatter = eachSystem (pkgs: treefmt.${pkgs.system}.config.build.wrapper);

      githubActions = nix-github-actions.lib.mkGithubMatrix {
        checks =
          let
            onlySupported = nixpkgs.lib.getAttrs [
              "x86_64-linux"
              "aarch64-darwin"
            ];
          in
          (onlySupported self.checks) // (onlySupported self.packages);
      };
    };
}
