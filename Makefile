SUBDIR_GOALS=	all clean distclean

SUBDIR+=		src/learnlog
SUBDIR+=		tests
SUBDIR+=		doc

version=$(shell sed -n 's/^ *version *= *\"\([^\"]\+\)\"/\1/p' pyproject.toml)


.PHONY: all
all: compile doc/learnlog.pdf test

.PHONY: test
test: compile
	${MAKE} -C tests test

.PHONY: install
install: compile
	pip install -e .

.PHONY: compile
compile:
	${MAKE} -C src/learnlog all
	poetry build

.PHONY: publish publish-github publish-pypi
publish: publish-github publish-pypi

publish-github: doc/learnlog.pdf
	git push
	gh release create -t v${version} v${version} doc/learnlog.pdf

doc/learnlog.pdf:
	${MAKE} -C $(dir $@) $(notdir $@)

publish-pypi: compile
	poetry publish


.PHONY: clean
clean:

.PHONY: distclean
distclean:
	${RM} -R build dist learnlog.egg-info src/learnlog.egg-info


INCLUDE_MAKEFILES=makefiles
include ${INCLUDE_MAKEFILES}/subdir.mk
