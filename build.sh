#!/usr/bin/env bash
set -euo pipefail

# Build script for macOS Big Sur Sound Theme for KDE Plasma
# Converts BigSurSounds to OGA format matching ocean-sound-theme structure
# Falls back to ocean-sound-theme sounds when no BigSur equivalent exists

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OCEAN_DIR="${SCRIPT_DIR}/ocean-sound-theme"
BIGSUR_DIR="${SCRIPT_DIR}/BigSurSounds"
THEME_NAME="bigsur"
OUTPUT_DIR="${SCRIPT_DIR}/theme/${THEME_NAME}"
STEREO_DIR="${OUTPUT_DIR}/stereo"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# ── Sound mapping ────────────────────────────────────────────────────
# Maps KDE sound names to BigSurSounds source files (relative to BigSurSounds/sounds/)
# Format: kde_sound_name=bigsur_relative_path
declare -A SOUND_MAP=(
    # ── Alarms & notifications ───────────────────────────────────────
    [alarm-clock-elapsed]="alerts/alarm.caf"                        # macOS alarm clock
    [message-new-instant]="alerts/ReceivedMessage.caf"              # iMessage received
    [message-sent-instant]="system/SentMessage.caf"                 # iMessage sent whoosh
    [message-attention]="alerts/new/Calypso.caf"                    # attention notification
    [message-highlight]="alerts/sms-received1.caf"                  # message highlight ping
    [message-contact-in]="facetime/multiway_join.caf"               # contact came online
    [message-contact-out]="facetime/multiway_leave.caf"             # contact went offline
    [phone-incoming-call]="ringtones/Opening.m4r"                   # incoming call ringtone

    # ── System bells ─────────────────────────────────────────────────
    [bell]="error/Ping.aiff"                                        # terminal bell
    [bell-window-system]="error/Glass.aiff"                         # classic Mac system bell

    # ── Button & UI feedback ─────────────────────────────────────────
    [audio-volume-change]="error/Tink.aiff"                         # short tick for volume
    [button-pressed]="error/Pop.aiff"                               # pop on click
    [button-pressed-modifier]="accessibility/Sticky-Keys-MODIFER.aif" # modifier key press

    # ── Login & logout ───────────────────────────────────────────────
    [desktop-login]="@sounds/mac-os-big-sur-startup.mp3"            # macOS Big Sur startup chime
    [desktop-logout]="dock/poof_item_off_dock.aif"                  # poof disappear sound
    [service-login]="siri/jbl_confirm.caf"                          # Siri confirm = logged in
    [service-logout]="siri/jbl_cancel.caf"                          # Siri cancel = logged out

    # ── Devices & power ──────────────────────────────────────────────
    [device-added]="system/Volume_Mount.aif"                        # macOS disk mount
    [device-removed]="system/Volume_Unmount.aif"                    # macOS disk unmount
    [power-plug]="system/begin_record.caf"                          # short ascending chime
    [power-unplug]="system/end_record.caf"                          # short descending chime

    # ── Dialogs & errors (macOS System Preferences alert sounds) ─────
    [dialog-error]="error/Basso.aiff"                               # deep bass thud
    [dialog-error-serious]="error/Funk.aiff"                        # dramatic funk
    [dialog-error-critical]="error/Submarine.aiff"                  # deep sonar alert
    [dialog-information]="error/Bottle.aiff"                        # gentle bottle pop
    [dialog-question]="error/Purr.aiff"                             # soft query purr
    [dialog-warning]="error/Blow.aiff"                              # breathy warning
    [dialog-warning-auth]="error/Hero.aiff"                         # heroic chime for auth

    # ── Battery ──────────────────────────────────────────────────────
    [battery-caution]="error/Morse.aiff"                            # beeping alert
    [battery-full]="alerts/modern/Complete.m4r"                     # "Complete" chime
    [battery-low]="error/Sosumi.aiff"                               # urgent xylophone alert

    # ── Completion & outcomes ────────────────────────────────────────
    [completion-fail]="system/burn_failed.aif"                      # burn failed
    [completion-partial]="alerts/new/Ladder.caf"                    # stepping up, partial
    [completion-rotation]="alerts/new/Telegraph.caf"                # tick-like cycling
    [completion-success]="system/burn_complete.aif"                 # burn complete chime
    [complete-media-burn]="system/burn_complete.aif"                # CD burn done
    [complete-media-error]="system/burn_failed.aif"                 # CD burn failed
    [outcome-failure]="system/payment_failure.aif"                  # Apple Pay failure
    [outcome-success]="system/payment_success.aif"                  # Apple Pay success

    # ── Games ────────────────────────────────────────────────────────
    [game-over-loser]="alerts/new/Descent.caf"                      # descending = lost
    [game-over-winner]="alerts/new/Fanfare.caf"                     # fanfare = won

    # ── Misc ─────────────────────────────────────────────────────────
    [media-insert-request]="alerts/new/Bloom.caf"                   # gentle prompt
    [trash-empty]="finder/empty_trash.aif"                          # crumpling paper
    [theme-demo]="error/Glass.aiff"                                 # THE iconic Mac sound
)

# ── Preflight checks ────────────────────────────────────────────────
check_sources() {
    local ok=true
    if [[ ! -d "${OCEAN_DIR}/ocean/stereo" ]]; then
        error "ocean-sound-theme not found at ${OCEAN_DIR}"
        error "Run 'make clone' first"
        ok=false
    fi
    if [[ ! -d "${BIGSUR_DIR}/sounds" ]]; then
        error "BigSurSounds not found at ${BIGSUR_DIR}"
        error "Run 'make clone' first"
        ok=false
    fi
    if [[ "$ok" == false ]]; then
        exit 1
    fi
}

# ── Generate index.theme ────────────────────────────────────────────
generate_index_theme() {
    cat > "${OUTPUT_DIR}/index.theme" << 'THEME'
[Sound Theme]
Name=Big Sur
Comment=macOS Big Sur Sound Theme for KDE Plasma
Directories=stereo
Example=theme-demo

[stereo]
OutputProfile=stereo
THEME
    info "Generated index.theme"
}

# ── Convert a single sound ──────────────────────────────────────────
# Args: $1 = source file, $2 = destination .oga file
convert_sound() {
    local src="$1"
    local dst="$2"
    ffmpeg -y -i "$src" -c:a libvorbis -q:a 5 -ar 48000 -ac 2 "$dst" -loglevel error
}

# ── Build theme ─────────────────────────────────────────────────────
build() {
    check_sources

    info "Building Big Sur sound theme for KDE Plasma..."

    # Create output directories
    mkdir -p "${STEREO_DIR}"

    # Get list of all ocean sound names (without extension)
    local ocean_stereo="${OCEAN_DIR}/ocean/stereo"
    local total=0
    local from_bigsur=0
    local from_ocean=0

    for oga_file in "${ocean_stereo}"/*.oga; do
        [[ ! -f "$oga_file" ]] && continue
        local basename
        basename="$(basename "$oga_file")"
        local sound_name="${basename%.oga}"
        local dst="${STEREO_DIR}/${basename}"

        total=$((total + 1))

        # Check if we have a mapping for this sound
        if [[ -n "${SOUND_MAP[$sound_name]+x}" ]]; then
            local mapping="${SOUND_MAP[$sound_name]}"
            local src_file

            # Paths starting with @ are relative to project root
            if [[ "$mapping" == @* ]]; then
                src_file="${SCRIPT_DIR}/${mapping#@}"
            else
                src_file="${BIGSUR_DIR}/sounds/${mapping}"
            fi

            if [[ -f "$src_file" ]]; then
                info "Converting: ${sound_name} <- ${mapping}"
                convert_sound "$src_file" "$dst"
                from_bigsur=$((from_bigsur + 1))
                continue
            else
                warn "Source missing: ${mapping}"
            fi
        fi

        # Fallback: copy from ocean theme (convert to ensure consistent format)
        warn "Fallback to ocean: ${sound_name}"
        convert_sound "$oga_file" "$dst"
        from_ocean=$((from_ocean + 1))
    done

    generate_index_theme

    echo ""
    info "Build complete!"
    info "  Total sounds:    ${total}"
    info "  From Big Sur:    ${from_bigsur}"
    info "  From Ocean:      ${from_ocean}"
    info "  Output:          ${OUTPUT_DIR}"
    echo ""
    info "To install, copy the theme folder to ~/.local/share/sounds/"
    info "  cp -r ${OUTPUT_DIR} ~/.local/share/sounds/${THEME_NAME}"
}

# ── Main ─────────────────────────────────────────────────────────────
build
