PAPER_FILE = slide.tex

FIGURE_DIR = .
FIGURE_TEX := $(shell find $(FIGURE_DIR) -type f -name "video*.tex")
FIGURE_PDF := $(subst tex,pdf,$(FIGURE_TEX))

.PHONY: figures
#.SECONDEXPANSION:

define fig_template =
 $(1): $$($(subst pdf,tex,$(1)))
endef

$(foreach fig,$(FIGURE_PDF),$(eval $(call fig_template,$(fig))))

figures:$(FIGURE_PDF)

$(FIGURE_PDF):
	$(eval bsname = $(shell echo $@ | sed -e "s/^.*\/\([^.]*\).*/\1/"))
	@echo "\documentclass[$(PAPER_FILE)]{subfiles}" >> m2t.tex
	@echo "\begin{document}" >> m2t.tex
	@echo "\nopagecolor" >> m2t.tex
	@echo "\pagestyle{empty}" >> m2t.tex
	@echo "\begin{figure}" >> m2t.tex
	@echo "\centering" >> m2t.tex
	@echo "\setlength{\figH}{0.4\columnwidth}" >> m2t.tex
	@echo "\input{$(subst pdf,tex,$@)}" >> m2t.tex
	@echo "\end{figure}" >> m2t.tex
	@echo "\end{document}" >> m2t.tex
	latexmk -quiet -bibtex -f -pdf -pdflatex="lualatex -interaction=nonstopmode" m2t.tex
	pdfcrop m2t.pdf
	mv m2t-crop.pdf $@
	latexmk -CA -bibtex m2t.tex
	rm -f m2t.tex

