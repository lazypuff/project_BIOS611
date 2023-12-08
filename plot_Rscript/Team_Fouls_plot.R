# packages
library(dplyr)
library(ggplot2)
library(patchwork)
library(RColorBrewer)
library(lubridate)
library(zoo)

data_cleaning <- function(data1_frame) {
  selected_columns <- c("Div","Date","HomeTeam","AwayTeam","FTHG","FTAG","FTR","HTHG",
                        "HTAG","HTR","Referee","HS","AS","HST","AST","HF","AF",
                        "HC","AC","HY","AY","HR","AR","B365H","B365D","B365A")
  new_data <- data1_frame
  new_data <- new_data %>%
    select(all_of(selected_columns))
  # Convert the "Date" column to a Date object
  new_data$Date <- dmy(new_data$Date)
  return(new_data)
}

start_year <- 2009
end_year <- 2019
file_names <- sapply(start_year:end_year, function(y) {
  paste0(y, "-", substring(y+1, 3, 4), ".csv")
})

cleaned_data_list <- lapply(file_names, function(file) {
  if (file.exists(paste0("source_data/Datasets/", file))) {
    raw_data <- read.csv(paste0("source_data/Datasets/", file))
    cleaned_data <- data_cleaning(raw_data)
    return(cleaned_data)
  } else {
    NULL
  }
})

plot_df <- bind_rows(cleaned_data_list)

epl20 <- read.csv("source_data/Datasets/2020-2021.csv")
epl21 <- read.csv("source_data/Datasets/2021-2022.csv")
epl20 <- data_cleaning(epl20)
epl21 <- data_cleaning(epl21)
plot_df <- bind_rows(plot_df,epl20,epl21)

# Calculate total fouls when team is playing at home
home_fouls <- plot_df %>%
  group_by(HomeTeam) %>%
  summarize(TotalHomeFouls = sum(HF),
            TotalHomeYellowCard = sum(HY),
            TotalHomeRedCard = sum(HR))

# Calculate total fouls when team is playing away
away_fouls <- plot_df %>%
  group_by(AwayTeam) %>%
  summarize(TotalAwayFouls = sum(AF),
            TotalAwayYellowCard = sum(AY),
            TotalAwayRedCard = sum(AR))

# Calculate total games played by each team
total_games_home <- plot_df %>%
  group_by(HomeTeam) %>%
  summarize(GamesAsHome = n())

total_games_away <- plot_df %>%
  group_by(AwayTeam) %>%
  summarize(GamesAsAway = n())

# Merge the fouls and games data
team_fouls <- merge(home_fouls, away_fouls, by.x = 'HomeTeam', by.y = 'AwayTeam')
team_games <- merge(total_games_home, total_games_away, by.x = 'HomeTeam', by.y = 'AwayTeam')
fouls_stat <- merge(team_games, team_fouls, by = "HomeTeam")

# Calculate average fouls
average_fouls <- transform(fouls_stat,
                           AverageFouls = (TotalHomeFouls + TotalAwayFouls) / (GamesAsHome + GamesAsAway),
                           AverageYellowCard = (TotalHomeYellowCard + TotalAwayYellowCard) / (GamesAsHome + GamesAsAway),
                           AverageRedCard = (TotalHomeRedCard + TotalAwayRedCard) / (GamesAsHome + GamesAsAway))

# Select relevant columns
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

average_fouls$Category <- sapply(average_fouls$HomeTeam, categorize_team)

p1 <- ggplot(average_fouls, aes(x = reorder(HomeTeam, AverageFouls), y = AverageFouls, fill = Category)) +
  geom_bar(stat = "identity") +
  scale_fill_brewer(palette = "Set3") + # Use a color palette from RColorBrewer
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Average Fouls by Teams",
       x = "Team",
       y = "Average Fouls")

p2 <- ggplot(average_fouls, aes(x = reorder(HomeTeam, AverageYellowCard), 
                                y = AverageYellowCard, fill = Category)) +
  geom_bar(stat = "identity") +
  scale_fill_brewer(palette = "Set3") + # Use a color palette from RColorBrewer
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Average Yellow Cards by Teams",
       x = "Team",
       y = "Average Yellow Cards")

p3 <- ggplot(average_fouls, aes(x = reorder(HomeTeam, AverageRedCard), 
                                y = AverageRedCard, fill = Category)) +
  geom_bar(stat = "identity") +
  scale_fill_brewer(palette = "Set3") + # Use a color palette from RColorBrewer
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Average Red Cards by Teams",
       x = "Team",
       y = "Average Red Cards")

p_combined = p1 / p2 / p3

ggsave("Team_Fouls.png", plot = p_combined, width = 10, height = 10, units = "in")
