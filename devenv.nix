{ pkgs, config, ... }:
{
  # ENVs
  env.KEYSTORE_PASSWORD = config.secretspec.secrets.KEYSTORE_PASSWORD or "";

  # Setup
  android.enable = true;
  android.platforms.version = [
    "34"
    "35"
    "36"
  ];
  android.buildTools.version = [
    "35.0.0"
    "36.0.0"
  ];

  android.flutter.enable = true;

  languages.java.enable = true;

  languages.java.jdk.package = pkgs.jdk17;

  packages = with pkgs; [
    apksigner
    fdroidcl
    fdroidserver
  ];

  enterShell = ''
    echo "Flutter development environment loaded!"
    flutter --version
  '';
}
