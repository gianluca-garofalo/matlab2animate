Installation
============

1. Clone the git repository.
2. Make sure to have [matlab2tikz](https://github.com/matlab2tikz/matlab2tikz) and [Slidy](https://www.w3.org/Talks/Tools/Slidy2/#(1))
    (they are also included as submodules)
3. Add the `src/` and `matlab2tikz/src/` folders to your path in MATLAB/Octave: e.g. 
    - using the "Set Path" dialog in MATLAB, or 
    - by running the `addpath` function from your command window, or
    - using the `init_matlab2animate` script.

Make sure that your LaTeX installation is up-to-date and includes:

* [Animate](https://ctan.org/pkg/animate)
* [TikZ/PGF](http://www.ctan.org/pkg/pgf) version 3.0 or higher
* [Pgfplots](http://www.ctan.org/pkg/pgfplots) version 1.13 or higher
* [Amsmath](https://www.ctan.org/pkg/amsmath) version 2.14 or higher
* [Standalone](http://www.ctan.org/pkg/standalone) (optional)

It is recommended to use the latest stable version of these packages.
Older versions may work depending on the actual MATLAB(R) figure you are converting.


Description
=====

matlab2animate is a Matlab/Octave function that can generate animated slides.
The main outputs of the function are:
- slide_pdf.tex
- slide_svg.tex
- Makefile

The basename "slide" is the default value and can be changed.\
Both slide_pdf.tex and slide_svg.tex generate a slide containing the animation created in Matlab/Octave.
The file extension of the slide is pdf and svg, respectively.
The reason for the different file types is twofold.
First, slide_pdf.tex not only generates an animated slide, but also a pdf for each frame.
This is useful to speed up future recompilation of the slide since pdf frames are more quickly used by the animate package to create the animation (see the workflow below).
Secondly, the animated pdf slide can only be played on Windows, since there seems to be no pdf reader on Linux with this capability.
The svg animation is therefore the only option for Linux users, who will have to create the whole presentation by adding more slides in slide_svg.tex.

### Workflow:
Assume to generate an animation in Matlab by updating a plot in a loop.
By calling matlab2animate within the loop used to generate each frame of the animation, matlab2animate relies on matlab2tikz to export the frame as a tex file.
At the end of the loop, slide_pdf.tex is created and it uses the latex package animate to create the animation out of the tex frames.
slide_pdf.tex will also generate a pdf file for each of the tex frames.
These pdf frames are used by slide_svg.tex to generate an animated svg (using once again the animated package).
If slide_svg.tex contains multiple slides, one svg file per page is generate.
Finally, an html file can be automatically created with matlab2animate to include all the generated svg slides in one html presentation.
The latter is based on Slidy.

The recommended output is the pdf presentation, since some beamer features might be lost when generating the presentation in svg.\
Linux users will obtain directly the html presentation after using matlab2animate in Matlab/Octave (see the examples) thanks to the Makefile.\
Windows users should check the recipes in the Makefile to see how to produce the target slide.
It is also recommended to use slide_pdf.tex to generate the pdf frames and then replace the animated command in slide_pdf.tex with the one in slide_svg.tex.
As mentioned before, this allows to generate the animation out of the pdf frames and it is much faster.


Warning 1 - The lack of documentation has been replaced with two detailed examples.

Warning 2 - example_2.m generates 150 frames, so it will take looong to complete.


Notes
-----

If you are curious about the equations that you see in the result of example_2, check out this [paper](https://elib.dlr.de/128416/1/root.pdf).
I think it is a pretty cool control law, but then I am the author of the paper so my judgment might be slightly biased.
