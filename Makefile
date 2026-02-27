.PHONY: generate build test run clean release

generate:
	xcodegen generate

DERIVED_DATA = .build

build: generate
	xcodebuild -scheme ZenzaPomodori -configuration Debug -derivedDataPath $(DERIVED_DATA) build

test: generate
	xcodebuild -scheme ZenzaPomodori -configuration Debug -derivedDataPath $(DERIVED_DATA) test -destination 'platform=macOS'

run: build
	open "$(DERIVED_DATA)/Build/Products/Debug/Zenza Pomodori.app"

clean:
	rm -rf $(DERIVED_DATA)
	xcodebuild -scheme ZenzaPomodori clean 2>/dev/null || true

release: generate
	xcodebuild -scheme ZenzaPomodori -configuration Release -derivedDataPath $(DERIVED_DATA) build
	cd "$(DERIVED_DATA)/Build/Products/Release" && zip -r ../../../../ZenzaPomodori.zip "Zenza Pomodori.app"
	@echo "Release built: ZenzaPomodori.zip"
