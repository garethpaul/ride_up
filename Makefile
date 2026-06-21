.DEFAULT_GOAL := check

.PHONY: build check dependency lint root-test test verify

override SHELL := /bin/sh
override .SHELLFLAGS := -c
override RUBY := ruby
ifneq ($(strip $(MAKEFILES)),)
$(error MAKEFILES must be empty; repository verification requires this Makefile to be loaded alone)
endif
override MAKEFILES :=
ifneq ($(origin MAKEFILE_LIST),file)
$(error MAKEFILE_LIST must not be overridden)
endif
override ROOT := $(shell path='$(subst ','"'"',$(MAKEFILE_LIST))'; path=$$(printf '%s' "$$path" | /usr/bin/sed 's/^ //'); [ -f "$$path" ] || exit 1; directory=$$(/usr/bin/dirname -- "$$path"); CDPATH= cd -- "$$directory" && /bin/pwd -P)
export ROOT
ifeq ($(strip $(ROOT)),)
$(error repository Makefile path could not be resolved)
endif
ANDROID_HOME ?=
ANDROID_SDK_ROOT ?=
override ANDROID_SDK := $(if $(ANDROID_HOME),$(ANDROID_HOME),$(ANDROID_SDK_ROOT))
export ANDROID_SDK

dependency:
	@if [ -n "$${ANDROID_SDK}" ] && [ -d "$${ANDROID_SDK}" ]; then \
		cd "$$ROOT" && ANDROID_HOME="$${ANDROID_SDK}" ANDROID_SDK_ROOT="$${ANDROID_SDK}" scripts/run-android-gradle.sh verifyOkHttpResolution; \
	else \
		echo "Android SDK not configured; resolved dependency verification skipped."; \
	fi

lint:
	$(RUBY) "$$ROOT/scripts/check-android-contract.rb"
	@if [ -n "$${ANDROID_SDK}" ] && [ -d "$${ANDROID_SDK}" ]; then \
		cd "$$ROOT" && ANDROID_HOME="$${ANDROID_SDK}" ANDROID_SDK_ROOT="$${ANDROID_SDK}" scripts/run-android-gradle.sh lint; \
	else \
		echo "Android SDK not configured; Gradle lint skipped."; \
	fi

test:
	$(RUBY) "$$ROOT/scripts/test-android-manifest-contract.rb"
	$(RUBY) "$$ROOT/scripts/test-ride-up-guards.rb"
	$(RUBY) "$$ROOT/scripts/test-delayed-marker-contract.rb"
	$(RUBY) "$$ROOT/scripts/test-layout-resource-contract.rb"
	$(RUBY) "$$ROOT/scripts/test-layout-lint-contract.rb"
	@if [ -n "$${ANDROID_SDK}" ] && [ -d "$${ANDROID_SDK}" ]; then \
		cd "$$ROOT" && ANDROID_HOME="$${ANDROID_SDK}" ANDROID_SDK_ROOT="$${ANDROID_SDK}" scripts/run-android-gradle.sh test; \
	else \
		echo "Android SDK not configured; Gradle tests skipped."; \
	fi

build:
	@if [ -n "$${ANDROID_SDK}" ] && [ -d "$${ANDROID_SDK}" ]; then \
		cd "$$ROOT" && ANDROID_HOME="$${ANDROID_SDK}" ANDROID_SDK_ROOT="$${ANDROID_SDK}" scripts/run-android-gradle.sh assembleDebug assembleRelease; \
	else \
		echo "Android SDK not configured; Gradle build skipped."; \
	fi

root-test:
	"$$ROOT/scripts/test-makefile-root.sh"

verify: root-test dependency lint test build

check: verify
