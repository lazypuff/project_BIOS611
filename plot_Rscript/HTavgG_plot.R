# packages
library(dplyr)
library(ggplot2)
library(patchwork)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)
if(length(args) > 0) {
  setwd(args[1])
}

train_cleaned_df <- read.csv("source_data/train_data.csv")
train_cleaned_df <- train_cleaned_df[,-1]
test_cleaned_df <- read.csv("source_data/test_data.csv")
test_cleaned_df <- test_cleaned_df[,-1]
plot_df <- rbind(train_cleaned_df,test_cleaned_df)

### home host game
# home team average goals
Hometeam_avggoal <- plot_df %>%
  group_by(HomeTeam) %>%
  summarise(avg_FTHG = mean(FTHG, na.rm = TRUE)) %>%
  arrange(-avg_FTHG) %>%   # Arrange in descending order
  mutate(HomeTeam = factor(HomeTeam, levels = HomeTeam))
# home team average goals being goaled by away team
Hometeam_avggoal_away <- plot_df %>%
  group_by(HomeTeam) %>%
  summarise(avg_FTAG = mean(FTAG, na.rm = TRUE)) %>%
  arrange(avg_FTAG) %>%   # Arrange in ascending order
  mutate(HomeTeam = factor(HomeTeam, levels = HomeTeam))

Hometeam_data <- merge(Hometeam_avggoal,Hometeam_avggoal_away, by = "HomeTeam")

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
Hometeam_data$Category <- sapply(Hometeam_data$HomeTeam, categorize_team)

# Bar plot
p1 <- ggplot(Hometeam_data, aes(x = HomeTeam, y = avg_FTHG, fill = Category)) +
  geom_bar(stat = "identity") +
  scale_fill_brewer(palette = "Set3") + # Use a color palette from RColorBrewer
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Average Full-Time Goals at Home by Teams",
       x = "Home Team",
       y = "Average Full-Time Goals")

# Plot 2: Average Full-Time Goals being Goaled by Away Team at Home by Teams
p2 <- ggplot(Hometeam_data, aes(x = reorder(HomeTeam, avg_FTAG), y = avg_FTAG, fill = Category)) +
  geom_bar(stat = "identity") +
  scale_fill_brewer(palette = "Set3") + # Use the same or a different color palette
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Average Full-Time Goals being Goaled by Away Team at Home by Teams",
       x = "Home Team",
       y = "Average Full-Time Goals being Goaled by Away Team")

p_combined <- p1 / p2

p_combined

ggsave("HomeTeam_performance.png", plot = p_combined, width = 10, height = 6, units = "in")


