-include Config.mk

PWD=$(shell pwd)

PACKAGES= \
  $(PREFIX)/ivory/ivory/ \
  $(PREFIX)/ivory/ivory-artifact/ \
  $(PREFIX)/ivory/ivory-backend-c/ \
  $(PREFIX)/ivory/ivory-stdlib/ \
  $(PREFIX)/ivory/ivory-serialize/ \
  $(PREFIX)/ivory/ivory-opts/ \
  $(PREFIX)/tower/tower/ \
  $(PREFIX)/tower/tower-config \
  $(PREFIX)/tower/tower-aadl/ \
  $(PREFIX)/ivory-tower-posix/

all: add-srcs

run_om:
	cabal exec runghc OM/OM.hs -- --src-dir=om_aadl

# run_omso: add-srcs
# 	cabal exec runghc OMSO.hs

.PHONY: add-srcs
add-srcs:
	cabal sandbox init
	cabal sandbox add-source $(PACKAGES)
	cabal install tower-aadl

.PHONY: clean
clean:
	-rm -rf AADL

.PHONY: veryclean
veryclean: clean
	-rm -rf dist
	-rm -rf .cabal-sandbox
	-rm -rf cabal.sandbox.config