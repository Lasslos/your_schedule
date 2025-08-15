{
  description = "Flutter + Android dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    android-nixpkgs.url = "github:tadfisher/android-nixpkgs";
  };

  outputs = { self, nixpkgs, android-nixpkgs, ... }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    # Tadfisher Android SDK components
    androidPkgs = android-nixpkgs.sdk.${system} (sdkPkgs: with sdkPkgs; [
      cmdline-tools-latest
      build-tools-36-0-0
      platform-tools
      platforms-android-36
      # emulator # optional, if you need the Android emulator
    ]);

    flutter = pkgs.flutter335;
    openjdk = pkgs.openjdk17;
  in
  {
    devShells.${system}.default = pkgs.mkShell {
      name = "flutter-android-dev-shell";

      packages = with pkgs; [
        flutter
        dart
        git
        unzip
        zip
        openjdk
        androidPkgs
        mesa-demos
        # Optional: gradle, if you need it for builds outside Flutter
        gradle
      ];

      shellHook = ''
        # Android SDK
        export ANDROID_SDK_ROOT=${androidPkgs}/share/android-sdk

        # Java
        export JAVA_HOME=${openjdk}

        # Add Flutter and Android platform-tools to PATH
        export PATH=$PATH:${flutter}/bin:${androidPkgs}/platform-tools/bin

        echo "Flutter + Android dev environment ready!"
      '';
    };
  };
}
