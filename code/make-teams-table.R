title: "Make Teams Table"
description: "Prepare the data to be computed"
input: 'nba2018.csv'
output: 'efficiency-summary.txt', 'teams-summary.txt', 'nba2018-teams.csv'

library(tidyverse)

#use read_csv to load the data into R
data <- read_csv('~/Desktop/stat133/workout/workout1/data/nba2018.csv')

#turn R values from experience into 0, and then convert column to integers
data$experience[data$experience == "R"] <- 0
data$experience <- as.integer(data$experience)

#turn salary into salary by millions
data$salary <- data$salary / 1000000

#turn position into a column factor with 5 levels, then rename the factors to more descriptive names
data$position <- factor(data$position, c('C', 'PF', 'PG', 'SF', 'SG'))
levels(data$position)[1] <- "center"
levels(data$position)[2] <- "power_fwd"
levels(data$position)[3] <- "point_guard"
levels(data$position)[4] <- "small_fwd"
levels(data$position)[5] <- "shoot_guard"

#use mutate to add missed_fg, missed_ft, rebounds, and efficiency
data <- mutate(data, missed_fg = field_goals_atts - field_goals, missed_ft = points1_atts - points1, rebounds = off_rebounds + def_rebounds)
data <- mutate(data, efficiency = (points + rebounds + assists + steals + blocks - missed_fg - missed_ft - turnovers) / games)

#use sink() to send R output of summary() of efficiency to effieciency-summary.txt within the output folder
sink('../output/efficiency-summary.txt')
summary(data$efficiency)
sink()


#Creating nba2018-teams.csv

#create teams data frame with columns equal to the sums of statistics for whole teams
teams <- data.frame(
	team = as.data.frame(summarise(group_by(data, team), experience = sum(experience)))[1],
	experience = as.data.frame(summarise(group_by(data, team), experience = sum(experience)))[2],
	salary = as.data.frame(summarise(group_by(data, team), salary = round(sum(salary), digits = 2)))[2],
	points3 = as.data.frame(summarise(group_by(data, team), points3 = sum(points3)))[2],
	points2 = as.data.frame(summarise(group_by(data, team), points2 = sum(points2)))[2],
	points1 = as.data.frame(summarise(group_by(data, team), points1 = sum(points1)))[2],
	points = as.data.frame(summarise(group_by(data, team), points = sum(points)))[2],
	off_rebounds = as.data.frame(summarise(group_by(data, team), off_rebounds = sum(off_rebounds)))[2],
	def_rebounds = as.data.frame(summarise(group_by(data, team), def_rebounds = sum(def_rebounds)))[2],
	assists = as.data.frame(summarise(group_by(data, team), assists = sum(assists)))[2],
	steals = as.data.frame(summarise(group_by(data, team), steals = sum(steals)))[2],
	blocks = as.data.frame(summarise(group_by(data, team), blocks = sum(blocks)))[2],
	turnovers = as.data.frame(summarise(group_by(data, team), turnovers = sum(turnovers)))[2],
	fouls = as.data.frame(summarise(group_by(data, team), fouls = sum(fouls)))[2],
	efficiency = as.data.frame(summarise(group_by(data, team), efficiency = sum(efficiency)))[2],
	row.names = NULL, 
    check.rows = FALSE,
    check.names = TRUE, 
    fix.empty.names = TRUE,
    stringsAsFactors = default.stringsAsFactors()
)

#use sink function to send R output of teams summary
sink('../output/teams-summary.txt')
summary(teams)
sink()

#export teams data to nba2018-teams.csv in data folder
write_csv(teams, '../data/nba2018-teams.csv')
