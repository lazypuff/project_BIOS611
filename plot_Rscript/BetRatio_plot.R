library(dplyr)
library(ggplot2)
library(patchwork)
library(RColorBrewer)

train_cleaned_df <- read.csv("source_data/train_data.csv")
train_cleaned_df <- train_cleaned_df[,-1]
test_cleaned_df <- read.csv("source_data/test_data.csv")
test_cleaned_df <- test_cleaned_df[,-1]
plot_df <- rbind(train_cleaned_df,test_cleaned_df)

Hometeam_avgbetratio <- plot_df %>%
  group_by(HomeTeam) %>%
  summarise(avgbetr_home = mean(B365H, na.rm = TRUE)) %>%
  arrange(-avgbetr_home) %>%   # Arrange in descending order
  mutate(HomeTeam = factor(HomeTeam, levels = HomeTeam))
Awayteam_avgbetratio <- plot_df %>%
  group_by(AwayTeam) %>%
  summarise(avgbetr_away = mean(B365A, na.rm = TRUE)) %>%
  arrange(-avgbetr_away) %>%   # Arrange in descending order
  mutate(AwayTeam = factor(AwayTeam, levels = AwayTeam))

betratio_data <- merge(Hometeam_avgbetratio, Awayteam_avgbetratio, 
                       by.x = "HomeTeam", by.y = "AwayTeam")
betratio_data$diff <- betratio_data$avgbetr_away - betratio_data$avgbetr_home

# label 39 teams
big_6 <- c("Arsenal", "Chelsea", "Liverpool", "Man City", "Man United", "Tottenham")
regular_epl_teams <- c(
  "Aston Villa", "Everton", "Newcastle", "West Ham", "Southampton", "Leicester", "Fulham", "Stoke", 
  "Sunderland", "West Brom", "Crystal Palace", "Brighton", "Burnley", "Norwich", "Watford", "Wolves", "Leeds"
)
infrequent_epl_teams <- c(
  "Birmingham", "Blackburn", "Blackpool", "Bolton", "Bournemouth", "Brentford", "Cardiff", "Huddersfield", 
  "Hull", "Middlesbrough", "Portsmouth", "QPR", "Reading", "Sheffield United", "Swansea", "Wigan"
)
categorize_team <- function(team) {
  if (team %in% big_6) {
    return("Big 6")
  } else if (team %in% regular_epl_teams) {
    return("Regular EPL Teams")
  } else if (team %in% infrequent_epl_teams) {
    return("Infrequent EPL Teams")
  } else {
    return("Unknown")
  }
}

# Apply the function to the DataFrame
betratio_data$Category <- sapply(betratio_data$HomeTeam, categorize_team)
colnames(betratio_data)[1] <- "Team"

# Bar plot
p1 <- ggplot(betratio_data, aes(x = Team, y = avgbetr_home, fill = Category)) +
  geom_bar(stat = "identity") +
  scale_fill_brewer(palette = "Set3") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + # Rotate x-axis labels for better readability
  labs(title = "Avg Bet Ratio for Winning at Home per Team",
       x = "Team", y = "")

p2 <- ggplot(betratio_data, aes(x = reorder(Team,-avgbetr_away), y = avgbetr_away, fill = Category)) +
  geom_bar(stat = "identity") +
  scale_fill_brewer(palette = "Set3") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + # Rotate x-axis labels for better readability
  labs(title = "Avg Bet Ratio for Winning at Away per Team",
       x = "Team", y = "")

p3 <- ggplot(betratio_data, aes(x = reorder(Team,-diff), y = diff, fill = Category)) +
  geom_bar(stat = "identity") +
  scale_fill_brewer(palette = "Set3") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + # Rotate x-axis labels for better readability
  labs(title = "Avg Difference in Bet Ratio for Winning between Away and Home per Team",
       x = "Team", y = "")

p_combined <- p1 / p2 / p3

ggsave("BetRatio.png", plot = p_combined, width = 10, height = 10, units = "in")
