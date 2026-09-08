# The tutorial catalog: each id names one literate source, <id>.nw, that
# tangles the pytorial Markdown the package ships and weaves the section
# of the Tutorials chapter.  The expert variants tangle from the same .nw
# as their novice twin, so they are listed separately rather than derived
# from TUTORIAL_IDS (which would also demand nonexistent -expert.tex
# weaves).  tutorials.nw carries the chapter prose and only weaves.
TUTORIAL_IDS=	getting-started playback-and-tagging \
		export-and-share metrics analysing-progsnap2
EXPERT_IDS=	getting-started playback-and-tagging \
		export-and-share metrics

TUTORIAL_MD=	$(TUTORIAL_IDS:%=%.md) $(EXPERT_IDS:%=%-expert.md)
TUTORIAL_TEX=	$(TUTORIAL_IDS:%=%.tex) tutorials.tex

.PHONY: all
all: ${TUTORIAL_MD} ${TUTORIAL_TEX}

# .md is not one of noweb.mk's suffixes, so the tangle rules are spelled
# out; the .tex targets use noweb.mk's generic weave rule.
%.md: %.nw
	${NOTANGLE}

%-expert.md: %.nw
	${NOTANGLE}

.PHONY: clean
clean:
	${RM} ${TUTORIAL_MD} ${TUTORIAL_TEX}

.PHONY: distclean
distclean:

INCLUDE_MAKEFILES=../../../makefiles
include ${INCLUDE_MAKEFILES}/noweb.mk
