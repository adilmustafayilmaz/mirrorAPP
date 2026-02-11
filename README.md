# mirrorAPP

A lightweight macOS menu bar application that turns your webcam into a quick mirror. Click the camera icon in the menu bar to check your appearance anytime.

## Features

- **Menu Bar App** — Lives in the macOS menu bar with a camera icon. No dock icon, no clutter.
- **Instant Mirror** — Left-click the icon to open a popover showing your mirrored camera feed.
- **Edge Light** — Built-in edge lighting with adjustable brightness and color temperature (White, Warm, Cool) to illuminate your face.
- **Launch at Login** — Automatically starts when you log in. Toggle via right-click menu.
- **Auto Camera Management** — Camera starts when the popover opens and stops when it closes to save battery.

## Requirements

- macOS 13.0 or later
- Mac with a built-in or connected camera
- Xcode 15+ to build from source

## Installation

1. Open `mirrorAPP.xcodeproj` in Xcode
2. Select **My Mac** as the build destination
3. Go to **Product > Archive**
4. Click **Distribute App > Custom > Copy App**
5. Choose `/Applications` as the destination

## Usage

| Action | Result |
|---|---|
| Left-click menu bar icon | Open/close the mirror |
| Right-click menu bar icon | Settings menu (Launch at Login, Quit) |
| Light icon (top bar) | Toggle edge light on/off |
| Color circles (top bar) | Switch light color temperature |
| Slider (bottom bar) | Adjust light brightness |

## Privacy

mirrorAPP requires camera access. The camera is only active while the mirror popover is open. No images or video are recorded or stored.

## License

MIT
