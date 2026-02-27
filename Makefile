.PHONY: generate build run clean release

generate:
	xcodegen generate

build: generate
	xcodebuild -scheme ZenzaPomodori -configuration Debug build

run: build
	open build/Debug/Zenza\ Pomodori.app

clean:
	rm -rf build DerivedData
	xcodebuild -scheme ZenzaPomodori clean 2>/dev/null || true

release: generate
	xcodebuild -scheme ZenzaPomodori -configuration Release build
	cd build/Release && zip -r ../../ZenzaPomodori.zip "Zenza Pomodori.app"
	@echo "Release built: ZenzaPomodori.zip"
