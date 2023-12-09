Hi, this is my 611 Data Science Project. More to come.

This project was planned to develop a gambling model on the English Premier Leauge soccer games. Due to time limit,now it reduces to a multinomial logsitic regression model that predicts the results of EPL soccer games and some interesting visulization on EPL teams.

Dataset:
Original dataset is downloaded from https://www.kaggle.com/datasets/saife245/english-premier-league.
The original data contain 20 years of EPL(English Premier League) data. I take data started from 09-10 season as they started to have a bet ratio from gambling company. After some data cleaning(Code please see the data_cleaning.R inside the source_data folder), I create a more compact dataset which includes many variables I think is relevant with the result of a game (detailed description is in the folder of source_data, called data_description.txt).

In this repository, four final polished graphs are 'BetRatio.png', 'HomeTeam_performance.png', 'avg_points_heatmap_big6.png' and 'Team_Fouls.png'. The final report is named as 'report.pdf'.

You can also get these graphs, report and analysis results inside the report by following the steps below.

# Clone this repository from GitHub.
Method 1:

Navigate to desired directory: "cd /path/to/your/directory". Then use "git clone https://github.com/lazypuff/project_BIOS611.git"

Method 2:

Download this whole repository via Github website or app.

# Enter this main folder in your terminal.
"cd /path/to/your/directory/project_BIOS611"

# Dockerfile:
Before we are using docker, we need to download docker if we don't have it.

Steps that using docker:

build the image:
"docker build -t r_latex_image ."

run the container:
"docker run -e PASSWORD=Your_Password -p 8787:8787 -it r_latex_image"
# Access Rstudio built in the container
After get the docker container running, we can access any browser and navigate to http://localhost:8787, and enter "rstudio" as username and "Your_Password" as Password. Then we will get into a local host RStudio.

After enter Rstudio via any browsers, we can use the terminal inside the Rstudio to generate all the results we want. 
# Accuracy of multinomial logistic regression on prediction the results of games
Simply Run "Rscript multinom.R" in the terminal. It will output the accuracy I had in the report, which is 0.4859.

# Makefile:
This project uses Makefile to generate four graphs and a complete report on the project.

Simply Run "make" in the terminal. It will output four graphs named as 'BetRatio.png', 'HomeTeam_performance.png', 'avg_points_heatmap_big6.png' and 'Team_Fouls.png', and also a report named as 'report.pdf'. The report contains detailed analysis and interpretation for this project and each graph.

After read it, you can run "make clean" to delete all things created via command "make".