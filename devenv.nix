{ pkgs, ... }:
{
  android.enable = true;

  android.flutter.enable = true;

  languages.java.enable = true;

  languages.java.jdk.package = pkgs.jdk17;

  packages = with pkgs; [

  ];

  enterShell = ''
    echo "Flutter development environment loaded!"
    flutter --version
  '';
}
