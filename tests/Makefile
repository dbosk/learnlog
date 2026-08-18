# Makefile for test suite
#
# Tests are written in .nw files throughout the src/ tree using
# chunks named "<<test [[modulename.py]]>>". This Makefile automatically
# discovers those chunks and tangles them to tests/unit/test_*.py files.

# The suite imports learnlog into the pytest process itself, which
# would otherwise start a run and commit the checkout into whatever
# repository the upward search finds.  The opt-out is honoured by
# initialize() on every import path (see learnlog.nw), so exporting it
# here keeps the test run out of anybody's log.  Subprocess tests that
# need logging strip it again from the environment they pass on (the
# test_env fixture and _autostart_env do exactly that), so this does
# not weaken what the suite checks.
export LEARNLOG_SKIP_AUTOSTART = 1

# Auto-discover test chunks in .nw files
# A single .nw file may define several "<<test [[X.py]]>>" chunks, one per
# module it tests; emit one target per distinct chunk.
# Output format: "unit/test_modulename.py:sourcefile.nw:test%20[[modulename.py]]"
define find_tests
( \
	find ../src -name '*.nw' | xargs grep -l '<<test \[\[.*\.py\]\]>>' | \
		while read file; do \
			grep -o '<<test \[\[\([^]]*\)\.py\]\]>>' "$$file" | sort -u | \
			sed 's/<<test \[\[\(.*\)\.py\]\]>>/\1/' | \
			while read chunk; do \
				chunk_safe=$$(echo "$$chunk" | sed 's/ /%20/g'); \
				echo "unit/test_$${chunk_safe}.py:$$file:test%20[[$$chunk_safe.py]]"; \
			done; \
		done; \
) | sort -u
endef

# Generate build target for each discovered test
define def_target
$(shell echo $1 | cut -d: -f1): $(shell echo $1 | cut -d: -f2)
	@mkdir -p $$(dir $$@)
	notangle -R"$(shell echo $1 | cut -d: -f3 | sed 's/%20/ /g')" $$< | cpif $$@ && noroots $$<
endef

# Discover all tests
TESTS := $(shell $(find_tests))

# Extract just the test filenames for dependencies
TEST_MODULES := $(foreach entry,$(TESTS),$(shell echo $(entry) | cut -d: -f1))

# Shared test fixtures (conftest.py is defined in gitrepo.nw)
unit/conftest.py: ../src/learnlog/gitrepo.nw
	@mkdir -p $(dir $@)
	notangle -R"[[conftest.py]]" $< | cpif $@

# Main targets
.PHONY: all
all: unit/conftest.py $(TEST_MODULES)

# Generate rules for each test
$(foreach entry,$(TESTS),$(eval $(call def_target,$(entry))))

# Target to run tests after tangling
.PHONY: test
test: all compile
	poetry run pytest -v

.PHONY: compile
compile:
	$(MAKE) -C ../src/learnlog all

# Clean generated test files
.PHONY: clean
clean:
	$(RM) $(TEST_MODULES) unit/conftest.py
	$(RM) -r .pytest_cache __pycache__ unit/__pycache__
	$(RM) -r htmlcov .coverage
