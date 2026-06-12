ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
RUBY ?= ruby
ANDROID_HOME ?=
ANDROID_SDK_ROOT ?=
ANDROID_SDK := $(if $(ANDROID_HOME),$(ANDROID_HOME),$(ANDROID_SDK_ROOT))

.PHONY: build check lint test verify

lint:
	$(RUBY) "$(ROOT)/scripts/check-android-contract.rb"
	@if [ -n "$(ANDROID_SDK)" ] && [ -d "$(ANDROID_SDK)" ]; then \
		cd "$(ROOT)" && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" scripts/run-android-gradle.sh lint; \
	else \
		echo "Android SDK not configured; Gradle lint skipped."; \
	fi

test:
	$(RUBY) "$(ROOT)/scripts/test-ride-up-guards.rb"
	@if [ -n "$(ANDROID_SDK)" ] && [ -d "$(ANDROID_SDK)" ]; then \
		cd "$(ROOT)" && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" scripts/run-android-gradle.sh test; \
	else \
		echo "Android SDK not configured; Gradle tests skipped."; \
	fi

build:
	@if [ -n "$(ANDROID_SDK)" ] && [ -d "$(ANDROID_SDK)" ]; then \
		cd "$(ROOT)" && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" scripts/run-android-gradle.sh assembleDebug; \
	else \
		echo "Android SDK not configured; Gradle build skipped."; \
	fi

verify: lint test build

check: verify
