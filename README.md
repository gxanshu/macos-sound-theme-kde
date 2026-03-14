# macOS Big Sur Sound Theme for KDE Plasma

A complete macOS Big Sur sound theme for KDE Plasma that replaces every sound from the default Ocean sound theme with authentic macOS Big Sur sounds. Drop-in replacement — every single sound event covered by Ocean is included, no gaps.

## Features

- **Complete 1:1 replacement** for the default KDE Plasma Ocean sound theme — all 44 sound events covered
- **Authentic macOS Big Sur sounds** including login, logout, notifications, errors, warnings, device connect/disconnect, trash, and more
- **Ready to use** — download from the [Releases](../../releases) page and install in seconds
- **No ocean fallbacks** — every sound is sourced from macOS Big Sur

## Sound Mapping

| KDE Sound Event | macOS Big Sur Sound |
|---|---|
| Desktop Login | Payment Success |
| Desktop Logout | Swish |
| Bell / System Bell | Glass / Ping |
| Button Pressed | Tink |
| Dialog Error | Basso |
| Dialog Warning | Blow |
| Dialog Information | Bottle |
| Dialog Question | Purr |
| Notification / New Message | ReceivedMessage |
| Message Sent | Mail Sent |
| Device Added | Volume Mount |
| Device Removed | Volume Unmount |
| Trash Empty | Empty Trash |
| Phone Incoming Call | Opening ringtone |
| Completion Success | Burn Complete |
| Completion Fail | Burn Failed |
| Battery Low | Sosumi |
| Power Plug / Unplug | Grab / Volume Unmount |
| Game Over (Win/Lose) | Fanfare / Descent |
| ...and 25 more | Full list in `build.sh` |

## Install from Release

1. Download the latest release archive from the [Releases](../../releases) page
2. Extract it:
   ```sh
   tar -xzf bigsur-sound-theme-kde.tar.gz
   ```
3. Copy to your local sounds directory:
   ```sh
   cp -r bigsur ~/.local/share/sounds/
   ```
4. Open **System Settings → Sounds** and select **Big Sur**

## Build from Source

### Requirements

- `git`
- `ffmpeg`

### Build

```sh
# Clone this repo
git clone https://github.com/AnshumanMahato/macos-sound-theme-kde.git
cd macos-sound-theme-kde

# Check tools, clone source repos, and build
make all

# Or step by step:
make check   # verify git and ffmpeg are installed
make clone   # clone ocean-sound-theme and BigSurSounds
make build   # convert and assemble the theme
```

### Install / Uninstall

```sh
make install    # copies to ~/.local/share/sounds/bigsur
make uninstall  # removes it
make clean      # deletes build output
```

## Theme Structure

```
bigsur/
├── index.theme
└── stereo/
    ├── alarm-clock-elapsed.oga
    ├── audio-volume-change.oga
    ├── battery-caution.oga
    ├── battery-full.oga
    ├── battery-low.oga
    ├── bell.oga
    ├── bell-window-system.oga
    ├── button-pressed.oga
    ├── button-pressed-modifier.oga
    ├── completion-fail.oga
    ├── completion-partial.oga
    ├── completion-rotation.oga
    ├── completion-success.oga
    ├── desktop-login.oga
    ├── desktop-logout.oga
    ├── device-added.oga
    ├── device-removed.oga
    ├── dialog-error.oga
    ├── dialog-error-critical.oga
    ├── dialog-error-serious.oga
    ├── dialog-information.oga
    ├── dialog-question.oga
    ├── dialog-warning.oga
    ├── dialog-warning-auth.oga
    ├── game-over-loser.oga
    ├── game-over-winner.oga
    ├── media-insert-request.oga
    ├── message-attention.oga
    ├── message-contact-in.oga
    ├── message-contact-out.oga
    ├── message-highlight.oga
    ├── message-new-instant.oga
    ├── message-sent-instant.oga
    ├── outcome-failure.oga
    ├── outcome-success.oga
    ├── phone-incoming-call.oga
    ├── power-plug.oga
    ├── power-unplug.oga
    ├── service-login.oga
    ├── service-logout.oga
    ├── theme-demo.oga
    └── trash-empty.oga
```

## Credits

- macOS Big Sur sounds from [BigSurSounds](https://github.com/ThisIsNoahEvans/BigSurSounds) by Noah Evans
- Theme structure based on [Ocean Sound Theme](https://github.com/KDE/ocean-sound-theme) by KDE

## License

The sounds in this theme are the property of Apple Inc. This project is provided for personal use only.
