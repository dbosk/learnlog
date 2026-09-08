NOTANGLEFLAGS.py=

MODULES+=	__init__.py _autostart.py learnlog.tex students.md
MODULES+=	capture.py capture.tex
MODULES+=	gitrepo.py gitrepo.tex
MODULES+=	commits.py commits.tex
MODULES+=	progsnap2.py progsnap2.tex
MODULES+=	metrics.py metrics.tex
MODULES+=	viewer.py viewer.tex
MODULES+=	cli.py cli.tex
# The tutorial catalog has its own Makefile in tutorials/, so that the
# doc build can recurse into that directory for a missing weave; all,
# clean and distclean recurse into it from here.
SUBDIR+=	tutorials
SUBDIR_GOALS=	all clean distclean

.PHONY: all
all: ${MODULES}

__init__.py: learnlog.nw
	${NOTANGLE.py}

_autostart.py: learnlog.nw
	${NOTANGLE.py}

students.md: learnlog.nw
	${NOTANGLE}

capture.py: capture.nw
gitrepo.py: gitrepo.nw
commits.py: commits.nw
progsnap2.py: progsnap2.nw
metrics.py: metrics.nw
viewer.py: viewer.nw
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
include ${INCLUDE_MAKEFILES}/subdir.mk
