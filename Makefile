.PHONY: build check lint test verify

RUN_LEGACY_GRADLE ?= 0

lint:
	ruby scripts/check-android-contract.rb

test: lint
	@if [ "$(RUN_LEGACY_GRADLE)" = "1" ]; then \
		if [ -n "$(ANDROID_HOME)" ]; then ANDROID_HOME="$(ANDROID_HOME)" ./gradlew test ; else ./gradlew test ; fi ; \
	else \
		echo "legacy Gradle test skipped; set RUN_LEGACY_GRADLE=1 with SDK 23 and archived dependencies"; \
	fi

build:
	@if [ "$(RUN_LEGACY_GRADLE)" = "1" ]; then \
		if [ -n "$(ANDROID_HOME)" ]; then ANDROID_HOME="$(ANDROID_HOME)" ./gradlew assembleDebug ; else ./gradlew assembleDebug ; fi ; \
	else \
		echo "legacy Gradle build skipped; set RUN_LEGACY_GRADLE=1 with SDK 23 and archived dependencies"; \
	fi

verify: lint test build

check: verify
