BUILDDIR = build
PDFframes = $(wildcard $(BUILDDIR)/slide_pdf-figure*.pdf)
TEXframes = $(wildcard $(BUILDDIR)/video*.tex)

.PHONY: all clean slide

all: slide clean

clean:
	latexmk -c -bibtex slide_pdf.tex
	latexmk -c -bibtex slide_svg.tex
	rm -f *.auxlock *.dpth *.log *.md5 *.nav *.snm

slide: slide_svg.dvi
	dvisvgm --font-format=woff --exact --bbox=papersize --zoom=-1 -p1,- slide_svg

slide_svg.dvi: slide_svg.tex $(PDFframes)
	latex -interaction=nonstopmode slide_svg.tex
	latex -interaction=nonstopmode slide_svg.tex

$(PDFframes): slide_pdf.pdf $(TEXframes)

slide_pdf.pdf: slide_pdf.tex $(TEXframes)
	latexmk -quiet -bibtex -f -pdf -pdflatex="lualatex -interaction=nonstopmode -shell-escape" slide_pdf.tex
	mv slide_pdf-figure*.pdf build/
