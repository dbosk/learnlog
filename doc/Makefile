LATEXFLAGS += -shell-escape

.PHONY: all weave clean distclean
all: learnlog.pdf

weave: learnlog.tex

../src/learnlog/learnlog.tex: ../src/learnlog/learnlog.nw
../src/learnlog/capture.tex: ../src/learnlog/capture.nw
../src/learnlog/gitrepo.tex: ../src/learnlog/gitrepo.nw
../src/learnlog/cli.tex: ../src/learnlog/cli.nw

%.tex: %.nw
	${MAKE} -C $(dir $@) $(notdir $@)

../src/%.tex: ../src/%.nw
	${MAKE} -C $(dir $@) $(notdir $@)

learnlog.pdf: learnlog.tex
learnlog.pdf: ../src/learnlog/learnlog.tex
learnlog.pdf: ../src/learnlog/capture.tex
learnlog.pdf: ../src/learnlog/gitrepo.tex
learnlog.pdf: ../src/learnlog/cli.tex
learnlog.pdf: bibliography.bib preamble.tex

clean:
	${RM} learnlog.tex learnlog.pdf

distclean:

INCLUDE_MAKEFILES = ../makefiles
include ${INCLUDE_MAKEFILES}/noweb.mk
include ${INCLUDE_MAKEFILES}/tex.mk
