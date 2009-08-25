

all: manual.pdf

%.pdf: %.tex
	pdflatex $< && pdflatex $< || echo Error while building PDF file


clean: manual.pdf-clean


manual.pdf-clean:
	@rm -f manual.pdf \
			manual.aux\
			manual.idx\
			manual.log\
			manual.lot\
			manual.pdf\
			manual.toc

#manual.pdf:
#	pdflatex manual.tex

