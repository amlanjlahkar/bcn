TARGETDIR ?= $(HOME)
AGENTDIR := agent
SCRIPTDIR := $(HOME)/.local/launchd_scripts
AGENTFILE := $(shell find ${AGENTDIR} -name '*.plist')
INTERVAL := 900
UID := $(shell id -u)

all: link bootstrap

.PHONY: link bootstrap bootout update-interval clean

link:
	@if [[ ! -L ${SCRIPTDIR}/bcn ]]; then \
		ln -s bcn ${SCRIPTDIR}; \
	fi
	@stow --verbose --target=${TARGETDIR} ${AGENTDIR}

bootstrap:
	-@launchctl bootstrap gui/${UID} ${AGENTFILE} 2>/dev/null

bootout:
	-@launchctl bootout gui/${UID} ${AGENTFILE} 2>/dev/null

update-interval:
ifeq ($(shell xmllint --xpath "number(//integer)" ${AGENTFILE}), ${INTERVAL})
else
	@make bootout
	@sed -i '' 's|<integer>[1-9][0-9]*</integer>|<integer>$(INTERVAL)</integer>|' ${AGENTFILE}
	@echo "Updated interval to ${INTERVAL}."
	@make bootstrap
endif

clean: bootout
	@stow --verbose --delete --target=${TARGETDIR} ${AGENTDIR}
