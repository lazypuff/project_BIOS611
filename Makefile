all: BetRatio.png HomeTeam_performance.png avg_points_heatmap_big6.png Team_Fouls.png report.pdf


BetRatio.png: source_data/train_data.csv source_data/test_data.csv plot_Rscript/BetRatio_plot.R
	Rscript plot_Rscript/BetRatio_plot.R

HomeTeam_performance.png: source_data/train_data.csv source_data/test_data.csv plot_Rscript/HTavgG_plot.R
	Rscript plot_Rscript/HTavgG_plot.R

avg_points_heatmap_big6.png: source_data/train_data.csv source_data/test_data.csv plot_Rscript/avg_points_heatmap.R
	Rscript plot_Rscript/avg_points_heatmap.R

# Variables
YEARS := $(shell seq 2009 2019)
CSV_FILES := $(foreach year,$(YEARS),source_data/Datasets/$(year)-$(shell expr $(year) - 2000 + 1 | xargs printf '%02d').csv) source_data/Datasets/2020-2021.csv source_data/Datasets/2021-2022.csv

# Target for the PNG file
Team_Fouls.png: plot_Rscript/Team_Fouls_plot.R $(CSV_FILES)
	Rscript plot_Rscript/Team_Fouls_plot.R

report.pdf: report.tex
	pdflatex report.tex
	pdflatex report.tex  # Running pdflatex twice to ensure proper referencing


# Clean task
clean:
	rm -f avg_points_heatmap_big6.png
	rm -f Team_Fouls.png
	rm -f HomeTeam_performance.png
	rm -f BetRatio.png
	rm -f report.pdf report.aux report.log report.out

# Phony targets
.PHONY: clean
