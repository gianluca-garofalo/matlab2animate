.PHONY: all clean slide dvitest
all: slide clean

slide: slide.tex build/video0.tex build/video1.tex build/video2.tex build/video3.tex build/video4.tex build/video5.tex build/video6.tex build/video7.tex build/video8.tex build/video9.tex build/video10.tex build/video11.tex build/video12.tex build/video13.tex build/video14.tex build/video15.tex build/video16.tex build/video17.tex build/video18.tex build/video19.tex build/video20.tex build/video21.tex 
	latexmk -quiet -bibtex -f -pdf -pdflatex="lualatex -interaction=nonstopmode" slide.tex

clean:
	latexmk -c -bibtex slide.tex

dvitest: slide.tex build/video0.tex build/video1.tex build/video2.tex build/video3.tex build/video4.tex build/video5.tex build/video6.tex build/video7.tex build/video8.tex build/video9.tex build/video10.tex build/video11.tex build/video12.tex build/video13.tex build/video14.tex build/video15.tex build/video16.tex build/video17.tex build/video18.tex build/video19.tex build/video20.tex build/video21.tex 
	lualatex -interaction=nonstopmode --output-format=dvi slide.tex
	lualatex -interaction=nonstopmode --output-format=dvi slide.tex
	dvisvgm --font-format=woff --exact --bbox=papersize --zoom=-1 -p1,- slide
