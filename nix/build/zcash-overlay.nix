# SPDX-FileCopyrightText: 2022 Oxhead Alpha
# SPDX-License-Identifier: LicenseRef-MIT-OA
self: super:
with self.nixpkgs;
let
  zcash = callPackage ./zcash.nix { };

  inject-zcash = oa: {
    nativeBuildInputs = oa.nativeBuildInputs ++ [ makeWrapper ];
    postFixup = ''
      for bin in $(find $out/bin -not -name '*.sh' -type f -executable); do
        wrapProgram "$bin" --prefix XDG_DATA_DIRS : ${zcash}
      done
    '';
  };

  relevant-packages =
    "tezos-((node|client|codec|admin-client|signer)|((accuser|baker|endorser).*))";
in builtins.mapAttrs (name: pkg:
  if !isNull (builtins.match relevant-packages name) then
    pkg.overrideAttrs inject-zcash
  else
    pkg) super
