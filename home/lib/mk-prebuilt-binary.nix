# Build a derivation from a prebuilt release tarball: select the asset for the
# host system and apply the boilerplate shared by the claude/pi/hunk packages
# (autoPatchelfHook on ELF, dontBuild/dontStrip, meta defaults).
{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,

  pname,
  version,
  assets, # { <system> = { url; hash; ... }; }
  sourceRoot ? null, # string, or a function: asset -> string
  nativeBuildInputs ? [ ],
  buildInputs ? [ ],
  installPhase,
  meta ? { },
}:
let
  asset =
    assets.${stdenvNoCC.hostPlatform.system}
      or (throw "${pname}: unsupported system ${stdenvNoCC.hostPlatform.system}");
  resolvedSourceRoot = if lib.isFunction sourceRoot then sourceRoot asset else sourceRoot;
in
stdenvNoCC.mkDerivation (
  {
    inherit
      pname
      version
      buildInputs
      installPhase
      ;

    src = fetchurl { inherit (asset) url hash; };

    nativeBuildInputs =
      nativeBuildInputs ++ lib.optionals stdenvNoCC.hostPlatform.isElf [ autoPatchelfHook ];

    dontBuild = true;
    dontStrip = true;

    meta = {
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      platforms = builtins.attrNames assets;
    }
    // meta;
  }
  // lib.optionalAttrs (resolvedSourceRoot != null) { sourceRoot = resolvedSourceRoot; }
)
