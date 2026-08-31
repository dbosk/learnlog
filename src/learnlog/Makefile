NOTANGLEFLAGS.py=

MODULES+=	__init__.py _autostart.py learnlog.tex students.md
MODULES+=	capture.py capture.tex
MODULES+=	gitrepo.py gitrepo.tex
MODULES+=	commits.py commits.tex
MODULES+=	progsnap2.py progsnap2.tex
MODULES+=	metrics.py metrics.tex
MODULES+=	viewer.py viewer.tex
MODULES+=	cli.py cli.tex
TUTORIAL_IDS=	getting-started playback-and-tagging \
		export-and-share metrics analysing-progsnap2
TUTORIAL_MD=	$(TUTORIAL_IDS:%=tutorials/%.md)
# The expert variants tangle from the same .nw as their novice twin,
# so they are listed here rather than derived from TUTORIAL_IDS
# (which would also demand nonexistent -expert.tex weaves).
TUTORIAL_MD+=	tutorials/getting-started-expert.md \
		tutorials/playback-and-tagging-expert.md \
		tutorials/export-and-share-expert.md \
		tutorials/metrics-expert.md
TUTORIAL_TEX=	$(TUTORIAL_IDS:%=tutorials/%.tex)
TUTORIAL_TEX+=	tutorials/tutorials.tex

MODULES+=	$(TUTORIAL_MD) $(TUTORIAL_TEX)

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

tutorials/%.md: tutorials/%.nw
	@mkdir -p $(dir $@)
	notangle -R"[[$(notdir $@)]]" $< | ${CPIF} $@ && noroots $<

tutorials/%-expert.md: tutorials/%.nw
	@mkdir -p $(dir $@)
	notangle -R"[[$(notdir $@)]]" $< | ${CPIF} $@ && noroots $<


.PHONY: clean
clean:
	${RM} ${MODULES}

.PHONY: distclean
distclean:
	${RM} -Rf __pycache__


INCLUDE_MAKEFILES=../../makefiles
include ${INCLUDE_MAKEFILES}/tex.mk
include ${INCLUDE_MAKEFILES}/noweb.mk
