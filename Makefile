override ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
RUBY ?= ruby
ANDROID_HOME ?=
ANDROID_SDK_ROOT ?=
ANDROID_SDK := $(if $(ANDROID_HOME),$(ANDROID_HOME),$(ANDROID_SDK_ROOT))

.PHONY: build check dependency lint test verify

dependency:
	@if [ -n "$(ANDROID_SDK)" ] && [ -d "$(ANDROID_SDK)" ]; then \
		cd "$(ROOT)" && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" scripts/run-android-gradle.sh verifyOkHttpResolution; \
	else \
		echo "Android SDK not configured; resolved dependency verification skipped."; \
	fi

lint:
	$(RUBY) "$(ROOT)/scripts/check-android-contract.rb"
	@if [ -n "$(ANDROID_SDK)" ] && [ -d "$(ANDROID_SDK)" ]; then \
		cd "$(ROOT)" && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" scripts/run-android-gradle.sh lint; \
	else \
		echo "Android SDK not configured; Gradle lint skipped."; \
	fi

test:
	$(RUBY) "$(ROOT)/scripts/test-android-manifest-contract.rb"
	$(RUBY) "$(ROOT)/scripts/test-ride-up-guards.rb"
	$(RUBY) "$(ROOT)/scripts/test-delayed-marker-contract.rb"
	@if [ -n "$(ANDROID_SDK)" ] && [ -d "$(ANDROID_SDK)" ]; then \
		cd "$(ROOT)" && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" scripts/run-android-gradle.sh test; \
	else \
		echo "Android SDK not configured; Gradle tests skipped."; \
	fi

build:
	@if [ -n "$(ANDROID_SDK)" ] && [ -d "$(ANDROID_SDK)" ]; then \
		cd "$(ROOT)" && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" scripts/run-android-gradle.sh assembleDebug assembleRelease; \
	else \
		echo "Android SDK not configured; Gradle build skipped."; \
	fi

verify: dependency lint test build

check: verify
