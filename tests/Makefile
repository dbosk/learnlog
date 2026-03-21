# Makefile for test suite
#
# Tests are written in .nw files throughout the src/ tree using
# chunks named "<<test [[modulename.py]]>>". This Makefile automatically
# discovers those chunks and tangles them to tests/unit/test_*.py files.

# Auto-discover test chunks in .nw files
# Output format: "unit/test_modulename.py:sourcefile.nw:test%20[[modulename.py]]"
define find_tests
( \
	find ../src -name '*.nw' | xargs grep -l '<<test \[\[.*\.py\]\]>>' | \
		while read file; do \
			chunk=$$(grep -o '<<test \[\[\([^]]*\)\.py\]\]>>' "$$file" | head -1 | \
			         sed 's/<<test \[\[\(.*\)\.py\]\]>>/\1/'); \
			chunk_safe=$$(echo "$$chunk" | sed 's/ /%20/g'); \
			echo "unit/test_$${chunk_safe}.py:$$file:test%20[[$$chunk_safe.py]]"; \
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

# Main targets
.PHONY: all
all: $(TEST_MODULES)

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
	$(RM) $(TEST_MODULES)
	$(RM) -r .pytest_cache __pycache__ unit/__pycache__
	$(RM) -r htmlcov .coverage
