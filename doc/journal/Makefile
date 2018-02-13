DIR=pdflatex
DOC=paper
BIB=bib.bib
LATEX=pdflatex -recorder

FIGS=./Figs

all: $(DIR) $(DOC).tex $(BIB)
	$(LATEX) -output-directory $(DIR) $(DOC)
	bibtex $(DIR)/$(DOC).aux
	$(LATEX) -output-directory $(DIR) $(DOC)
	$(LATEX) -output-directory $(DIR) $(DOC)
	cp $(DIR)/$(DOC).pdf .

$(DIR):
	mkdir -p $(DIR)

.PHONY: clean
clean:
	rm -rf $(DIR) *.aux *.toc *.log
