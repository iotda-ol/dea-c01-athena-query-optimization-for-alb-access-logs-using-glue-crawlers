# Root Makefile - forwards all commands to build/Makefile
# This provides a convenient interface from the repository root

.DEFAULT_GOAL := help

# Forward all targets to build/Makefile
%:
	@$(MAKE) -C build $@

.PHONY: help
