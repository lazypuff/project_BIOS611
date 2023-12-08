# packages
library(dplyr)
library(ggplot2)
library(patchwork)
library(RColorBrewer)

train_cleaned_df <- read.csv("source_data/train_data.csv")
train_cleaned_df <- train_cleaned_df[,-1]
test_cleaned_df <- read.csv("source_data/test_data.csv")
test_cleaned_df <- test_cleaned_df[,-1]
plot_df <- rbind(train_cleaned_df,test_cleaned_df)


big_6 <- c("Arsenal", "Chelsea", "Liverpool", "Man City", "Man United", "Tottenham")
big_6_df <- plot_df %>% filter(HomeTeam %in% big_6 & AwayTeam %in% big_6)

loss_rate_matrix <- matrix(0, nrow = length(big_6), ncol = length(big_6),
                           dimnames = list(big_6, big_6))

# Calculate loss rate for each pair of teams
for (team_i in big_6) {
  for (team_j in big_6) {
    if (team_i != team_j) {
      total_games <- nrow(rbind(filter(big_6_df, HomeTeam == team_i & AwayTeam == team_j),
                                filter(big_6_df, HomeTeam == team_j & AwayTeam == team_i)))
      losses <- nrow(rbind(filter(big_6_df, HomeTeam == team_i & AwayTeam == team_j & FTR == 'A'),
                           filter(big_6_df, HomeTeam == team_j & AwayTeam == team_i & FTR == 'H')))
      loss_rate <- ifelse(total_games > 0, losses / total_games, 0)
      
      # Fill the matrix
      loss_rate_matrix[team_i, team_j] <- loss_rate
    }
  }
}

win_rate_matrix <- matrix(0, nrow = length(big_6), ncol = length(big_6),
                           dimnames = list(big_6, big_6))

# Calculate win rate for each pair of teams
for (team_i in big_6) {
  for (team_j in big_6) {
    if (team_i != team_j) {
      total_games <- nrow(rbind(filter(big_6_df, HomeTeam == team_i & AwayTeam == team_j),
                                filter(big_6_df, HomeTeam == team_j & AwayTeam == team_i)))
      wins <- nrow(rbind(filter(big_6_df, HomeTeam == team_i & AwayTeam == team_j & FTR == 'H'),
                           filter(big_6_df, HomeTeam == team_j & AwayTeam == team_i & FTR == 'A')))
      win_rate <- ifelse(total_games > 0, wins / total_games, 0)
      
      # Fill the matrix
      win_rate_matrix[team_i, team_j] <- win_rate
    }
  }
}

draw_rate_matrix <- matrix(0, nrow = length(big_6), ncol = length(big_6),
                          dimnames = list(big_6, big_6))

# Calculate draw rate for each pair of teams
for (team_i in big_6) {
  for (team_j in big_6) {
    if (team_i != team_j) {
      total_games <- nrow(rbind(filter(big_6_df, HomeTeam == team_i & AwayTeam == team_j),
                                filter(big_6_df, HomeTeam == team_j & AwayTeam == team_i)))
      draws <- nrow(rbind(filter(big_6_df, HomeTeam == team_i & AwayTeam == team_j & FTR == 'D'),
                         filter(big_6_df, HomeTeam == team_j & AwayTeam == team_i & FTR == 'D')))
      draw_rate <- ifelse(total_games > 0, draws / total_games, 0)
      
      # Fill the matrix
      draw_rate_matrix[team_i, team_j] <- draw_rate
    }
  }
}

# check code, good, all equal 1
# win_rate_matrix + loss_rate_matrix + draw_rate_matrix

## points taken between big 6, the columns represent opponents.
avg_points_mat <- win_rate_matrix*3 + draw_rate_matrix

# Convert the matrix to a long format for use with ggplot
avg_points_long <- reshape2::melt(avg_points_mat)
colnames(avg_points_long) <- c("Team", "Opponent", "Points")
avg_points_long <- avg_points_long %>% filter(Points != 0)

# Create the heatmap
heatmap <- ggplot(avg_points_long, aes(x = Team, y = Opponent, fill = Points)) +
  geom_tile() +
  scale_fill_gradient(low = "blue", high = "red") + # Adjust colors as needed
  labs(title = "Average Points Take from Opponent Heatmap", 
       x = "Team", y = "Opponent", fill = "Avg Points") +
  theme_minimal()

ggsave("avg_points_heatmap_big6.png", heatmap, width = 10, height = 6, units = "in")
