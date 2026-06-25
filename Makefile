.DEFAULT_GOAL := check

.PHONY: build check dependency lint root-test test verify
.SECONDEXPANSION:

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
override ROOT := $(shell sed_path=/usr/bin/sed; [ -x "$$sed_path" ] || sed_path=/bin/sed; [ -x "$$sed_path" ] || exit 1; path=$$(printf '%s' '$(subst ','"'"',$(MAKEFILE_LIST))' | "$$sed_path" 's/^ //'); [ -f "$$path" ] || exit 1; directory=$${path%/*}; [ "$$directory" != "$$path" ] || directory=.; CDPATH= cd "$$directory" && pwd -P)
export ROOT
ifeq ($(strip $(ROOT)),)
$(error repository Makefile path could not be resolved)
endif
build check dependency lint root-test test verify: $$(if $$(filter file,$$(origin MAKEFILE_LIST)),,$$(error MAKEFILE_LIST must not be overridden))
build check dependency lint root-test test verify: $$(if $$(shell sed_path=/usr/bin/sed && [ -x "$$$$sed_path" ] || sed_path=/bin/sed && [ -x "$$$$sed_path" ] && path=$$$$(printf '%s' '$$(subst ','"'"',$$(MAKEFILE_LIST))' | "$$$$sed_path" 's/^ //') && [ -f "$$$$path" ] && printf '%s' ok),,$$(error repository Makefile must be loaded alone))
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
	$(RUBY) "$$ROOT/scripts/test-java-toolchain-resolution.rb"
	$(RUBY) "$$ROOT/scripts/test-java-contract-runner.rb"
	$(RUBY) "$$ROOT/scripts/test-ride-up-guards.rb"
	$(RUBY) "$$ROOT/scripts/test-pickup-map-contract.rb"
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
