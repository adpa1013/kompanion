# Kompanion - KOReader Companion App 

> **Disclaimer:** this project is a fork of [TomasDiLeo's](https://github.com/TomasDiLeo/) [koreader-pageturner-companion](https://github.com/TomasDiLeo/koreader_pageturner_companion). Originally intended to merge to upstream, but now actively maintained and distributed here,
  as the original author no longer has time to maintain it. 

## Demo

https://github.com/user-attachments/assets/bd13a4a6-5d70-472a-961a-e4cc17735913

## Features

 - Frontlight Intensity and Warmth control
 - Nightmode Toggle
 - Full Screen Refresh
 - 5 custom profiles buttons that activate one of your custom profiles
 - Page Turning with the volume buttons and remapping capabilities
 - Navigate back and forward between pressed links, and a custom 'back' button
 - Text Input screen capable of getting, sending and clearing any text inside an input text widget in KOReader, especially useful to write notes from the comfort of your phone screen.
 - Reading Mode: immersive reading mode with minimal UI and minimal brightness. Contribution by [pleguen](https://github.com/pleguen)
 - Keyboard Shortcuts: Common keyboards are supported, so you can use this app as a 'bridge' for most PowerPoint presenter sticks.
 - Host it yourself: Docker image available, see [docker-compose.example.yml](./docker-compose.example.yml) for reference
 - Battery Information: Fetches current battery capacity and creates a graph for the current session


## Shortcuts

### Keyboard & Remote Controls

| Key / Shortcut | Action |
|---|---|
| `←` (Left Arrow) | Previous Page |
| `→` (Right Arrow) | Next Page |
| `↑` (Up Arrow) | Frontlight +10% |
| `↓` (Down Arrow) | Frontlight -10% |
| `Page Up` | Previous Page |
| `Page Down` | Next Page |

### Volume Buttons (Android)

| Button | Default Action | Configurable Actions |
|---|---|---|
| Volume Up | Next Page | Next Page, Previous Page, Frontlight +10%, Frontlight -10% |
| Volume Down | Previous Page | Next Page, Previous Page, Frontlight +10%, Frontlight -10% |

## Install

* Go to releases and Download and install the [latest version](https://github.com/adpa1013/kompanion/releases/latest)
* In KOReader go to `Tools -> More Tools -> KOReader HTTP Inspector` and start the HTTP Server (Take note of the port, 8080 by default)
* In KOReader go to `Settings -> Network -> Network info` and take note of the network and ip
* In the Kompanion app put the IP and PORT and press "CONNECT"
* Enjoy

## Troubleshooting 

|Problem|Try|
|-------|---|
|Profiles don't activate|Make sure the names are written exactly the same way. Check the `Show in action list` checkbox in the profile's settings|
|Can't connect to the KOReader device| Check the device's IP, they tend to change from time to time. Check that both devices are in the same network. Ensure that the HTTP Inspector plugin is running|
