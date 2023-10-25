# packages
library(dplyr)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
if(length(args) > 0) {
  setwd(args[1])
}

train_cleaned_df <- read.csv("source_data/train_data.csv")
train_cleaned_df <- train_cleaned_df[,-1]

Hometeam_avggoal <- train_cleaned_df %>%
  group_by(HomeTeam) %>%
  summarise(avg_FTHG = mean(FTHG, na.rm = TRUE)) %>%
  arrange(-avg_FTHG) %>%   # Arrange in descending order
  mutate(HomeTeam = factor(HomeTeam, levels = HomeTeam))

# Bar plot
p1 <- ggplot(Hometeam_avggoal, aes(x = HomeTeam, y = avg_FTHG)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + # Rotate x-axis labels for better readability
  labs(title = "Average Full-Time Goals at Home by Teams",
       x = "Home Team",
       y = "Average Full-Time Goals")

ggsave("HTavgG.png", plot = p1)

