{
  description = "A very basic flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils/master";
    smunix-monoid-extras.url = "github:smunix/monoid-extras/fix.diagrams";
    smunix-diagrams-svg.url = "github:smunix/diagrams-svg/fix.diagrams";
    smunix-diagrams-lib.url = "github:smunix/diagrams-lib/fix.diagrams";
    smunix-diagrams-core.url = "github:smunix/diagrams-core/fix.diagrams";
    smunix-diagrams-solve.url = "github:smunix/diagrams-solve/fix.diagrams";
  }; 
  outputs = { self, nixpkgs, flake-utils, smunix-diagrams-svg, smunix-diagrams-lib,
              smunix-diagrams-core, smunix-diagrams-solve, ... }:
    with flake-utils.lib;
    with nixpkgs.lib;
    eachSystem [ "x86_64-darwin" ] (system:
      let version = "${substring 0 8 self.lastModifiedDate}.${self.shortRev or "dirty"}";
          overlay = self: super:
            with self;
            with haskell.lib;
            with haskellPackages;
            {
              diagrams-contrib = rec {
                package = overrideCabal (callCabal2nix "diagrams-contrib" ./. {
                  inherit (smunix-diagrams-core.packages.${system}) diagrams-core;
                  inherit (smunix-diagrams-solve.packages.${system}) diagrams-solve;
                  inherit (smunix-diagrams-lib.packages.${system}) diagrams-lib;
                }) (o: { version = "${o.version}-${version}"; });
                };
            };
          overlays = [ overlay ];
      in
        with (import nixpkgs { inherit system overlays; });
        rec {
          packages = flattenTree (recurseIntoAttrs { diagrams-contrib = diagrams-contrib.package; });
          defaultPackage = packages.diagrams-contrib;
        });
}
