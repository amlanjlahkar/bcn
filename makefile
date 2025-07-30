TARGETDIR ?= $(HOME)
AGENTDIR := agent
SCRIPTDIR := script
AGENTFILE := $(shell find ${AGENTDIR} -name '*.plist')
INTERVAL := 900

.PHONY: stow clean update-interval

stow:
	@stow --verbose --target=${TARGETDIR} ${SCRIPTDIR} ${AGENTDIR}

clean:
	@stow --verbose --delete --target=${TARGETDIR} ${SCRIPTDIR} ${AGENTDIR}

update-interval:
ifeq ($(shell xmllint --xpath "number(//integer)" ${AGENTFILE}), ${INTERVAL})
else
	@sed -i '' 's|<integer>[1-9][0-9]*</integer>|<integer>$(INTERVAL)</integer>|' ${AGENTFILE}
	@echo "Updated interval to ${INTERVAL}."
	$(MAKE) clean
	$(MAKE) stow
endif

