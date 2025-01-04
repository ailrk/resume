TEX = pandoc
SRC = template.tex details.yaml
TGT = resume.pdf
FLAGS = --pdf-engine=xelatex

all:
	make haskell
	make webdev
	make ccpp

webdev: $(SRC) details-webdev.yaml
	$(TEX) $(filter-out $<,$^ ) -o webdev/$(TGT) --template=$< $(FLAGS)

ccpp: $(SRC) details-ccpp.yaml
	$(TEX) $(filter-out $<,$^ ) -o ccpp/$(TGT) --template=$< $(FLAGS)

haskell: $(SRC) details-haskell.yaml
	$(TEX) $(filter-out $<,$^ ) -o haskell/$(TGT) --template=$< $(FLAGS)


.PHONY: clean
clean :
	find . -name 'resume.pdf' -delete -print
