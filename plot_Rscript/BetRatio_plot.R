library(dplyr)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
if(length(args) > 0) {
  setwd(args[1])
}

train_cleaned_df <- read.csv("source_data/train_data.csv")
train_cleaned_df <- train_cleaned_df[,-1]

Hometeam_avgbetratio <- train_cleaned_df %>%
  group_by(HomeTeam) %>%
  summarise(avgbetr = mean(B365H, na.rm = TRUE)) %>%
  arrange(-avgbetr) %>%   # Arrange in descending order
  mutate(HomeTeam = factor(HomeTeam, levels = HomeTeam))

# Bar plot
p2 <- ggplot(Hometeam_avgbetratio, aes(x = HomeTeam, y = avgbetr)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + # Rotate x-axis labels for better readability
  labs(title = "Average Bet Ratio for Home Team Winning",
       x = "Home Team",
       y = "Bet Ratio for Home Team Winning")

ggsave("BetRatioHT.png", plot = p2)