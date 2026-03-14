SHELL := /bin/bash

OCEAN_REPO := git@github.com:KDE/ocean-sound-theme.git
BIGSUR_REPO := git@github.com:ThisIsNoahEvans/BigSurSounds.git
OCEAN_DIR := ocean-sound-theme
BIGSUR_DIR := BigSurSounds
THEME_DIR := theme/bigsur
INSTALL_DIR := $(HOME)/.local/share/sounds/bigsur

.PHONY: all check clone build test clean install uninstall

all: check clone build

# ── Check required tools ─────────────────────────────────────────────
check:
	@echo "Checking required tools..."
	@command -v git >/dev/null 2>&1 || { echo "ERROR: git is not installed"; exit 1; }
	@echo "  git:    $$(git --version)"
	@command -v ffmpeg >/dev/null 2>&1 || { echo "ERROR: ffmpeg is not installed"; exit 1; }
	@echo "  ffmpeg: $$(ffmpeg -version | head -1)"
	@echo "All tools found."

# ── Clone source repos ──────────────────────────────────────────────
clone:
	@if [ ! -d "$(OCEAN_DIR)/.git" ]; then \
		echo "Cloning ocean-sound-theme..."; \
		git clone --depth 1 $(OCEAN_REPO) $(OCEAN_DIR); \
	else \
		echo "ocean-sound-theme already cloned."; \
	fi
	@if [ ! -d "$(BIGSUR_DIR)/.git" ]; then \
		echo "Cloning BigSurSounds..."; \
		git clone --depth 1 $(BIGSUR_REPO) $(BIGSUR_DIR); \
	else \
		echo "BigSurSounds already cloned."; \
	fi

# ── Build the theme ─────────────────────────────────────────────────
build:
	@bash build.sh

# ── Validate the built theme ─────────────────────────────────────────
test:
	@echo "Running validation tests..."
	@PASS=0; FAIL=0; \
	\
	echo ""; \
	echo "1. Checking theme directory exists..."; \
	if [ -d "$(THEME_DIR)/stereo" ]; then \
		echo "   PASS: $(THEME_DIR)/stereo exists"; \
		PASS=$$((PASS + 1)); \
	else \
		echo "   FAIL: $(THEME_DIR)/stereo not found. Run 'make build' first."; \
		exit 1; \
	fi; \
	\
	echo ""; \
	echo "2. Checking index.theme exists and has required keys..."; \
	if [ ! -f "$(THEME_DIR)/index.theme" ]; then \
		echo "   FAIL: index.theme not found"; \
		FAIL=$$((FAIL + 1)); \
	else \
		missing=""; \
		grep -q '^\[Sound Theme\]' "$(THEME_DIR)/index.theme" || missing="$$missing [Sound Theme]"; \
		grep -q '^Name=' "$(THEME_DIR)/index.theme" || missing="$$missing Name"; \
		grep -q '^Comment=' "$(THEME_DIR)/index.theme" || missing="$$missing Comment"; \
		grep -q '^Directories=stereo' "$(THEME_DIR)/index.theme" || missing="$$missing Directories"; \
		grep -q '^Example=theme-demo' "$(THEME_DIR)/index.theme" || missing="$$missing Example"; \
		grep -q '^\[stereo\]' "$(THEME_DIR)/index.theme" || missing="$$missing [stereo]"; \
		grep -q '^OutputProfile=stereo' "$(THEME_DIR)/index.theme" || missing="$$missing OutputProfile"; \
		if [ -z "$$missing" ]; then \
			echo "   PASS: index.theme has all required keys"; \
			PASS=$$((PASS + 1)); \
		else \
			echo "   FAIL: index.theme missing:$$missing"; \
			FAIL=$$((FAIL + 1)); \
		fi; \
	fi; \
	\
	echo ""; \
	echo "3. Checking file list matches ocean-sound-theme..."; \
	ocean_list=$$(ls $(OCEAN_DIR)/ocean/stereo/*.oga 2>/dev/null | xargs -I{} basename {} | sort); \
	bigsur_list=$$(ls $(THEME_DIR)/stereo/*.oga 2>/dev/null | xargs -I{} basename {} | sort); \
	if [ "$$ocean_list" = "$$bigsur_list" ]; then \
		count=$$(echo "$$bigsur_list" | wc -l); \
		echo "   PASS: all $$count sound files match"; \
		PASS=$$((PASS + 1)); \
	else \
		echo "   FAIL: file lists differ"; \
		diff <(echo "$$ocean_list") <(echo "$$bigsur_list") || true; \
		FAIL=$$((FAIL + 1)); \
	fi; \
	\
	echo ""; \
	echo "4. Checking directory structure matches ocean-sound-theme..."; \
	ocean_dirs=$$(cd $(OCEAN_DIR)/ocean && find . -type d | sort); \
	bigsur_dirs=$$(cd $(THEME_DIR) && find . -type d | sort); \
	if [ "$$ocean_dirs" = "$$bigsur_dirs" ]; then \
		echo "   PASS: directory structure matches"; \
		PASS=$$((PASS + 1)); \
	else \
		echo "   FAIL: directory structure differs"; \
		diff <(echo "$$ocean_dirs") <(echo "$$bigsur_dirs") || true; \
		FAIL=$$((FAIL + 1)); \
	fi; \
	\
	echo ""; \
	echo "5. Checking audio format (Ogg Vorbis, 48000 Hz, stereo)..."; \
	bad_files=""; \
	for f in $(THEME_DIR)/stereo/*.oga; do \
		info=$$(ffprobe -v error -show_entries stream=codec_name,sample_rate,channels -of csv=p=0 "$$f" 2>&1); \
		if [ "$$info" != "vorbis,48000,2" ]; then \
			bad_files="$$bad_files $$(basename $$f)($$info)"; \
		fi; \
	done; \
	if [ -z "$$bad_files" ]; then \
		echo "   PASS: all files are Ogg Vorbis, 48000 Hz, stereo"; \
		PASS=$$((PASS + 1)); \
	else \
		echo "   FAIL: bad format:$$bad_files"; \
		FAIL=$$((FAIL + 1)); \
	fi; \
	\
	echo ""; \
	echo "────────────────────────────────────"; \
	echo "Results: $$PASS passed, $$FAIL failed"; \
	if [ $$FAIL -gt 0 ]; then \
		echo "TESTS FAILED"; \
		exit 1; \
	else \
		echo "ALL TESTS PASSED"; \
	fi

# ── Install to local sounds directory ────────────────────────────────
install: build
	@echo "Installing to $(INSTALL_DIR)..."
	@mkdir -p "$(INSTALL_DIR)"
	@cp -r $(THEME_DIR)/* "$(INSTALL_DIR)/"
	@echo "Installed. Select 'Big Sur' in System Settings > Sounds."

# ── Uninstall ────────────────────────────────────────────────────────
uninstall:
	@echo "Removing $(INSTALL_DIR)..."
	@rm -rf "$(INSTALL_DIR)"
	@echo "Uninstalled."

# ── Clean build output ──────────────────────────────────────────────
clean:
	@echo "Cleaning build output..."
	@rm -rf theme/
	@echo "Done."
