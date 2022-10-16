{
  description = "Redbot Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    (flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        instance-name = "muzik_trouville";
        pkgs = import nixpkgs {
          inherit system;
        };
        python = pkgs.python39.withPackages (p: [ p.pip ]);
        shell = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.jdk11_headless
            python
          ];
        };
        run = pkgs.writeShellScript "run-redbot.sh" ''
          declare -x PATH="${pkgs.jdk11_headless}/bin:$PATH"
          ${python}/bin/python3.9 -m venv ./redenv
          source ./redenv/bin/activate
          python -m pip install -U pip setuptools wheel
          python -m pip install -U Red-DiscordBot
          redbot ${instance-name} || redbot-setup --instance-name ${instance-name}
        '';
      in
      {
        packages.default = run;
        devShells.default = shell;
        apps.default = {
          type = "app";
          program = "${run.outPath}";
        };
      }));
}
