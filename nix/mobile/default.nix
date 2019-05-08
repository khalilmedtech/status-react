{ config, stdenv, pkgs, target-os ? "all", status-go }:

with pkgs;
with stdenv;

let
  gradle = gradle_4_10;
  platform = pkgs.callPackage ../platform.nix { inherit target-os; };
  xcodewrapperArgs = {
    version = "10.1";
  };
  xcodeWrapper = xcodeenv.composeXcodeWrapper xcodewrapperArgs;
  android = callPackage ./android.nix { inherit config; };

in
  {
    inherit (android) androidComposition;
    inherit xcodewrapperArgs;

    buildInputs =
      status-go.packages ++
      lib.optionals platform.targetAndroid android.buildInputs ++
      lib.optional (platform.targetIOS && isDarwin) xcodeWrapper;
    shellHook =
      status-go.shellHook +
      lib.optionalString platform.targetAndroid android.shellHook;
  }
