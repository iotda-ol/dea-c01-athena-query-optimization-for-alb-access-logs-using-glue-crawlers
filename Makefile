# Root Makefile - forwards all commands to build/Makefile
# This provides a convenient interface from the repository root

.PHONY: help init plan apply destroy validate validate-all diagrams cost test test-coverage fmt clean install setup deploy-all status

help:
	@$(MAKE) -C build help

init:
	@$(MAKE) -C build init $(MAKEFLAGS)

plan:
	@$(MAKE) -C build plan $(MAKEFLAGS)

apply:
	@$(MAKE) -C build apply $(MAKEFLAGS)

destroy:
	@$(MAKE) -C build destroy $(MAKEFLAGS)

validate:
	@$(MAKE) -C build validate $(MAKEFLAGS)

validate-all:
	@$(MAKE) -C build validate-all

diagrams:
	@$(MAKE) -C build diagrams

cost:
	@$(MAKE) -C build cost

test:
	@$(MAKE) -C build test

test-coverage:
	@$(MAKE) -C build test-coverage

fmt:
	@$(MAKE) -C build fmt

clean:
	@$(MAKE) -C build clean

install:
	@$(MAKE) -C build install

setup:
	@$(MAKE) -C build setup

deploy-all:
	@$(MAKE) -C build deploy-all

status:
	@$(MAKE) -C build status
