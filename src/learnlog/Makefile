NOTANGLEFLAGS.py=

MODULES+=	__init__.py learnlog.tex
MODULES+=	capture.py capture.tex
MODULES+=	gitrepo.py gitrepo.tex
MODULES+=	cli.py cli.tex

.PHONY: all
all: ${MODULES}

__init__.py: learnlog.nw
	${NOTANGLE.py}

capture.py: capture.nw
gitrepo.py: gitrepo.nw
cli.py: cli.nw


.PHONY: clean
clean:
	${RM} ${MODULES}

.PHONY: distclean
distclean:
	${RM} -Rf __pycache__


INCLUDE_MAKEFILES=../../makefiles
include ${INCLUDE_MAKEFILES}/tex.mk
include ${INCLUDE_MAKEFILES}/noweb.mk
