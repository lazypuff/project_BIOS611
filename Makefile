all: BetRatioHT.png HTavgG.png


BetRatioHT.png: source_data/train_data.csv plot_Rscript/BetRatio_plot.R
	Rscript plot_Rscript/BetRatio_plot.R $(PWD)

HTavgG.png: source_data/train_data.csv plot_Rscript/HTavgG_plot.R
	Rscript plot_Rscript/HTavgG_plot.R $(PWD)

clean:
	rm -f BetRatioHT.png HTavgG.png