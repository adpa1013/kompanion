{ pkgs, config, ... }:
{
  # ENVs
  env.KEYSTORE_PASSWORD = config.secretspec.secrets.KEYSTORE_PASSWORD or "";

  # Setup
  android.enable = true;

  android.flutter.enable = true;

  languages.java.enable = true;

  languages.java.jdk.package = pkgs.jdk17;

  enterShell = ''
    echo "Flutter development environment loaded!"
    flutter --version
  '';
}
