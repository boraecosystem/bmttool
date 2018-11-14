PACKAGE = bmttool
GO      = go
GLIDE   = glide
GOPATH  = $(CURDIR)/.gopath
GOFMT   = gofmt
BASE    = $(GOPATH)/src/$(PACKAGE)

Q = $(if $(filter 1,$V),,@)
M = $(shell printf "\033[34;1m▶\033[0m")

.PHONY: all
all: fmt vendor | $(BASE) ; $(info $(M) building executable...) @ ## Build program binary
	$Q cd $(BASE) && GOPATH=$(GOPATH) $(GO) build -o bin/$(PACKAGE) $(PACKAGE)/$(PACKAGE)

$(BASE): ; $(info $(M) setting GOPATH…)
	@mkdir -p $(dir $@)
	@ln -sf ../.. $@

glide.lock: glide.yaml | $(BASE)
	$Q cd $(BASE) && $(GLIDE) update
	@touch $@

vendor: glide.lock | $(BASE)
#	$Q cd $(BASE) && $(GLIDE) --quiet install
	$Q cd $(BASE) && $(GLIDE) install
	@ln -sf . vendor/src
	@touch $@

.PHONY: fmt
fmt: ; $(info $(M) running gofmt…) @ ## Run gofmt on all source files
	@ret=0 && for d in $$($(GO) list -f '{{.Dir}}' ./... | grep -v /vendor/); do \
		$(GOFMT) -l -w $$d/*.go || ret=$$? ; \
	 done ; exit $$ret

.PHONY: clean
clean: ; $(info $(M) cleaning…)	@ ## Cleanup everything
	@rm -rf $(GOPATH)
	@rm -rf bin
	@rm -rf test/tests.* test/coverage.*

