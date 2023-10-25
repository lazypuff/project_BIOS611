# packages
library(dplyr)
library(lubridate)
library(zoo)

setwd("~/project_611")
### read in data
start_year <- 2009
end_year <- 2020
file_names <- sapply(start_year:end_year, function(y) {
  paste0(y, "-", substring(y+1, 3, 4), ".csv")
})

##### data cleaning function
data_cleaning <- function(data1_frame) {
  selected_columns <- c("Div","Date","HomeTeam","AwayTeam","FTHG","FTAG","FTR","HTHG",
                        "HTAG","HTR","Referee","HS","AS","HST","AST","HF","AF",
                        "HC","AC","HY","AY","HR","AR","B365H","B365D","B365A")
  new_data <- data1_frame
  new_data <- new_data %>%
    select(all_of(selected_columns))
  # Convert the "Date" column to a Date object
  new_data$Date <- dmy(new_data$Date)
  # Calculate the Goal Difference(GD)
  new_data$HGD <- new_data$FTHG - new_data$FTAG
  new_data$AGD <- new_data$FTAG - new_data$FTHG
  # Separate into home and away dataframes
  home_data <- new_data
  away_data <- new_data
  
  # Rolling computations for home data
  home_data <- home_data %>%
    arrange(HomeTeam, Date) %>%  # Assuming you have a 'Date' column. If not, you need another way to order matches chronologically
    group_by(HomeTeam) %>%
    mutate(#offence
      HAG = lag(rollapply(FTHG, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      HAS = lag(rollapply(HS, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      HAST = lag(rollapply(HST, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      HAC = lag(rollapply(HC, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      #defence
      HAOG = lag(rollapply(FTAG, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      HAOS = lag(rollapply(AS, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      HAOST = lag(rollapply(AST, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      HAOC = lag(rollapply(AC, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      #foul
      HAF = lag(rollapply(HF, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      HAOF = lag(rollapply(AF, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      HAY = lag(rollapply(HY, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      HAOY = lag(rollapply(AY, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      HSR = lag(rollapply(HR, width = 3, FUN = sum, align = "right", fill = NA, partial = TRUE), default = NA),
      HSOR = lag(rollapply(AR, width = 3, FUN = sum, align = "right", fill = NA, partial = TRUE), default = NA),
      # Goal Diff
      HAGD = lag(rollapply(HGD, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA)
    ) %>%
    ungroup()
  
  home_data <- home_data %>%
    arrange(HomeTeam, Date) %>%
    group_by(HomeTeam) %>%
    mutate(
      g1h = case_when(
        lag(FTR, 1) == "H" ~ "W",
        lag(FTR, 1) == "A" ~ "L",
        lag(FTR, 1) == "D" ~ "D",
        TRUE ~ NA_character_
      ),
      g2h = case_when(
        lag(FTR, 2) == "H" ~ "W",
        lag(FTR, 2) == "A" ~ "L",
        lag(FTR, 2) == "D" ~ "D",
        TRUE ~ NA_character_
      ),
      g3h = case_when(
        lag(FTR, 3) == "H" ~ "W",
        lag(FTR, 3) == "A" ~ "L",
        lag(FTR, 3) == "D" ~ "D",
        TRUE ~ NA_character_
      )
    ) %>%
    ungroup()
  
  # Rolling computations for away data
  away_data <- away_data %>%
    arrange(AwayTeam, Date) %>%
    group_by(AwayTeam) %>%
    mutate(#offence
      AAG = lag(rollapply(FTAG, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      AAS = lag(rollapply(AS, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      AAST = lag(rollapply(AST, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      AAC = lag(rollapply(AC, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      #defence
      AAOG = lag(rollapply(FTHG, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      AAOS = lag(rollapply(HS, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      AAOST = lag(rollapply(HST, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      AAOC = lag(rollapply(HC, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      #foul
      AAF = lag(rollapply(AF, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      AAOF = lag(rollapply(HF, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      AAY = lag(rollapply(AY, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      AAOY = lag(rollapply(HY, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA),
      ASR = lag(rollapply(AR, width = 3, FUN = sum, align = "right", fill = NA, partial = TRUE), default = NA),
      ASOR = lag(rollapply(HR, width = 3, FUN = sum, align = "right", fill = NA, partial = TRUE), default = NA),
      # Goal Diff
      AAGD = lag(rollapply(AGD, width = 3, FUN = mean, align = "right", fill = NA, partial = TRUE), default = NA)
    ) %>%
    ungroup()
  
  away_data <- away_data %>%
    arrange(AwayTeam, Date) %>%
    group_by(AwayTeam) %>%
    mutate(
      g1a = case_when(
        lag(FTR, 1) == "A" ~ "W",
        lag(FTR, 1) == "H" ~ "L",
        lag(FTR, 1) == "D" ~ "D",
        TRUE ~ NA_character_
      ),
      g2a = case_when(
        lag(FTR, 2) == "A" ~ "W",
        lag(FTR, 2) == "H" ~ "L",
        lag(FTR, 2) == "D" ~ "D",
        TRUE ~ NA_character_
      ),
      g3a = case_when(
        lag(FTR, 3) == "A" ~ "W",
        lag(FTR, 3) == "H" ~ "L",
        lag(FTR, 3) == "D" ~ "D",
        TRUE ~ NA_character_
      )
    ) %>%
    ungroup()
  
  # Merge back to main data
  home_data_truan <- home_data[ ,c(1:7,29:46)]
  away_data_truan <- away_data[ ,c(1:7,24:46)]
  
  new_data_test <- inner_join(home_data_truan, away_data_truan, by = c("HomeTeam", "AwayTeam", "Date"))
  # Drop columns from the second dataset (with .y suffix)
  columns_to_drop <- grep("\\.y$", names(new_data_test), value = TRUE)
  new_data_test <- new_data_test %>% select(-all_of(columns_to_drop))
  
  # Rename columns with .x suffix (if you want to drop the suffix)
  columns_to_rename <- grep("\\.x$", names(new_data_test), value = TRUE)
  new_names <- sub("\\.x$", "", columns_to_rename)
  names(new_data_test)[names(new_data_test) %in% columns_to_rename] <- new_names
  
  # return data frame
  return(new_data_test)
}

cleaned_data_list <- lapply(file_names, function(file) {
  if (file.exists(paste0("source_data/Datasets/", file))) {
    raw_data <- read.csv(paste0("source_data/Datasets/", file))
    cleaned_data <- data_cleaning(raw_data)
    return(cleaned_data)
  } else {
    NULL
  }
})

train_cleaned_df <- bind_rows(cleaned_data_list)

epl20 <- read.csv("source_data/Datasets/2020-2021.csv")
epl21 <- read.csv("source_data/Datasets/2021-2022.csv")
epl20 <- data_cleaning(epl20)
epl21 <- data_cleaning(epl21)
test_cleaned_df <- bind_rows(epl20,epl21)

write.csv(x = train_cleaned_df,file = "source_data/train_data.csv")
write.csv(x = test_cleaned_df,file = "source_data/test_data.csv")

