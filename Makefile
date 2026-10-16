# Build system for redborder sensor programs
# Targets:
#   all: Builds all programs and installs them to dist/
#   clean: Removes built binaries from dist/

INSTALL_DIR = dist

# Go programs
GO_FILES = $(wildcard programs/go/*.go)
GO_BINS = $(patsubst programs/go/%.go, $(INSTALL_DIR)/%, $(GO_FILES))

# C programs
C_FILES = $(wildcard programs/c/*.c)
C_BINS = $(patsubst programs/c/%.c, $(INSTALL_DIR)/%, $(C_FILES))

.PHONY: all clean go_progs c_progs rpm srpm distclean

all: $(INSTALL_DIR) go_progs c_progs

$(INSTALL_DIR):
	mkdir -p $(INSTALL_DIR)

go_progs: $(GO_BINS)

c_progs: $(C_BINS)

# Build static Go binaries
$(INSTALL_DIR)/%: programs/go/%.go
	@echo "[+] Building static Go binary: $@"
	CGO_ENABLED=0 go build -ldflags "-s -w -extldflags '-static'" -o $@ $<

# Build static C binaries
$(INSTALL_DIR)/%: programs/c/%.c
	@echo "[+] Building static C binary: $@"
	gcc -static -O2 -o $@ $<

clean:
	@echo "[+] Cleaning up binaries in $(INSTALL_DIR)..."
	rm -f $(GO_BINS) $(C_BINS)
	@if [ -d packaging/rpm ]; then $(MAKE) -C packaging/rpm clean; fi

rpm: clean
	$(MAKE) -C packaging/rpm rpm

srpm: clean
	$(MAKE) -C packaging/rpm srpm

distclean: clean
	$(MAKE) -C packaging/rpm distclean
