.PHONY: help book chapters test test-judge clean cleanall all FORCE

SHELL := /bin/bash
SRCDIR := src
BUILDDIR := build
OUTDIR := output
CHAPTERS_OUTDIR := $(OUTDIR)/chapters

# 已經動筆的章（目錄名稱）。新的一章開始寫時加進來，book.tex 也要取消註解。
WRITTEN := 01_Knapsack 02_SubsequenceDP 03_IntervalDP 04_BitmaskDP 05_DigitDP 06_DAGTopo 07_DSUCyclesBipartite 08_ShortestPaths 09_MST 10_TreeDP

# Compile from BUILDDIR so aux/log/minted/pdf intermediates never land in src/.
# Trailing colon on TEXINPUTS keeps TeX Live's default search path.
BUILD_TEXINPUTS := ../$(SRCDIR):../$(SRCDIR)/packages:
LATEXMK := latexmk -xelatex -cd- -output-directory=. -aux-directory=. -latexoption="-file-line-error -halt-on-error" -shell-escape -silent -interaction=nonstopmode

# 所有章的目錄，例如 07_Greedy；chN 依編號找到對應的目錄。
CHAPTER_DIRS := $(notdir $(wildcard $(SRCDIR)/chapters/[0-9][0-9]_*))
chapter_dir = $(filter $(shell printf '%02d' $(1))_%,$(CHAPTER_DIRS))

help:
	@echo "Book build system"
	@echo ""
	@echo "Targets:"
	@echo "  make book         - Build full book PDF (output/book.pdf)"
	@echo "  make ch7          - Build one chapter (output/chapters/)"
	@echo "  make chapters     - Build every written chapter"
	@echo "  make test         - Extract examples from .tex, compile and check iosample"
	@echo "  make test-judge   - Run examples on the full judge tests (local only, see README)"
	@echo "  make clean        - Delete build artifacts"
	@echo "  make cleanall     - Delete all PDFs + artifacts"

all: book chapters

book: $(OUTDIR)/book.pdf
	@:

chapters: $(foreach d,$(WRITTEN),$(CHAPTERS_OUTDIR)/$(d).pdf)
	@echo "✓ All written chapters compiled to $(CHAPTERS_OUTDIR)/"

# make ch7、make ch12 …
ch%:
	@d="$(call chapter_dir,$*)"; \
	if [ -z "$$d" ]; then echo "No chapter $*"; exit 1; fi; \
	$(MAKE) --no-print-directory $(CHAPTERS_OUTDIR)/$$d.pdf

# Full book: copy the driver into BUILDDIR (do not compile ../src/book.tex in
# place — latexmk/xelatex would write aux/log/minted next to the source).
$(OUTDIR)/book.pdf: FORCE
	@mkdir -p $(BUILDDIR) $(OUTDIR)
	@echo "Building: Full book..."
	@cp $(SRCDIR)/book.tex $(BUILDDIR)/book.tex
	@TEXINPUTS="$(BUILD_TEXINPUTS)" scripts/build_tex.sh $(BUILDDIR) book.tex $(LATEXMK)
	@cp $(BUILDDIR)/book.pdf $(OUTDIR)/book.pdf
	@echo "✓ $(OUTDIR)/book.pdf"

# 單章：把 book.tex 的導言區複製一份，只放這一章。
$(CHAPTERS_OUTDIR)/%.pdf: FORCE
	@mkdir -p $(BUILDDIR) $(CHAPTERS_OUTDIR)
	@echo "Building chapter: $*..."
	@wrapper="$(BUILDDIR)/chapter-$*.tex" && \
	chap_num=$$(echo "$*" | grep -o '^[0-9]\+') && \
	sed -e '/\\include{chapters/d' -e '/\\input{chapters/d' -e '/\\setcounter{chapter}/d' \
	    -e '/\\end{document}/d' -e '/\\maketitle/d' -e '/\\romantableofcontents/d' \
	    -e '/\\tableofcontents/d' $(SRCDIR)/book.tex > "$$wrapper" && \
	echo "\\setcounter{chapter}{$$(( 10#$$chap_num - 1 ))}" >> "$$wrapper" && \
	echo "\\input{../$(SRCDIR)/chapters/$*/chapter}" >> "$$wrapper" && \
	echo "\\end{document}" >> "$$wrapper" && \
	TEXINPUTS="$(BUILD_TEXINPUTS)" scripts/build_tex.sh $(BUILDDIR) chapter-$*.tex $(LATEXMK) && \
	cp $(BUILDDIR)/chapter-$*.pdf $(CHAPTERS_OUTDIR)/$*.pdf && echo "✓ $(CHAPTERS_OUTDIR)/$*.pdf"

# 從 .tex 抽出範例程式，編譯後拿 iosample 的輸入跑，和預期輸出比對。
test:
	@rm -rf $(BUILDDIR)/code
	@python3 scripts/extract_code.py --out $(BUILDDIR)/code $(foreach d,$(WRITTEN),$(SRCDIR)/chapters/$(d)/chapter.tex)
	@scripts/run_tests.sh $(BUILDDIR)/code

# 例題對完整測資：需要另外的題目資料，見 README。
test-judge:
	@rm -rf $(BUILDDIR)/code
	@python3 scripts/extract_code.py --out $(BUILDDIR)/code $(foreach d,$(WRITTEN),$(SRCDIR)/chapters/$(d)/chapter.tex)
	@scripts/test_judge.sh $(BUILDDIR)/code

FORCE:

clean:
	@rm -rf ./$(BUILDDIR)
	@echo "✓ Build artifacts cleaned"

cleanall: clean
	@rm -rf ./$(OUTDIR)
	@echo "✓ All outputs cleaned"
