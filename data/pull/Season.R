
#take data from espn bubble link
#steps: rvest, get table and clean- repeat for 2020 and 2021 - boom time series, make a couple of graphs
library(rvest)
library("dplyr")
site = read_html("https://www.espn.com/nba/standings/_/season/2020")
table = html_nodes(site, "table")
east_team = table[1] %>% html_table(fill = TRUE) 
east_rec = table[2] %>% html_table(fill = TRUE)
west_team = table[3] %>% html_table(fill = TRUE)
west_rec = table[4] %>% html_table(fill = TRUE)
east_df = merge(east_team, east_rec, by = "row.names", all.x = TRUE)

#change index val to numeric to sort by position and change column names to team and position
#add column to denote either west or east
#do this for both west and east
class(east_df$Row.names) = "Numeric"
east_df$Row.names = as.integer(east_df$Row.names)
east_df = arrange(east_df, east_df$Row.names)
colnames(east_df)[1] <- "Position"
colnames(east_df)[2] <- "Team"
east_df = east_df %>% mutate(CAT = 'E')


west_df = merge(west_team, west_rec, by = "row.names", all.x = TRUE)
class(west_df$Row.names) = "Numeric"
west_df$Row.names = as.integer(west_df$Row.names)
west_df = arrange(west_df, west_df$Row.names)
colnames(west_df)[1] <- "Position"
colnames(west_df)[2] <- "Team"
west_df = west_df %>% mutate(CAT = 'W')


#union the tables together and sort by losses ascending

df_2019 = union(east_df, west_df) %>% arrange(L) %>% mutate(YEAR = '2019')
df_2019 = df_2019 %>% mutate(ACT_TEAM = sub(".*\\b([A-Z]{3}).*", "\\1", df_2019$Team))

df_2019$ACT_TEAM[df_2019$ACT_TEAM == 'NON'] = 'NOP'
df_2019$ACT_TEAM[df_2019$ACT_TEAM == 'NYN'] = 'NYK'
df_2019$ACT_TEAM[df_2019$ACT_TEAM == 'WSH'] = 'WAS'
df_2019$ACT_TEAM[df_2019$ACT_TEAM == 'GSG'] = 'GSW'

#df_2019
#edit NON to NOP, NYN to NYK, WSH to WAS, GSG to GSW



site = read_html("https://www.espn.com/nba/standings/_/season/2021")
table = html_nodes(site, "table")
east_team = table[1] %>% html_table(fill = TRUE) 
east_rec = table[2] %>% html_table(fill = TRUE)
west_team = table[3] %>% html_table(fill = TRUE)
west_rec = table[4] %>% html_table(fill = TRUE)
east_df = merge(east_team, east_rec, by = "row.names", all.x = TRUE)

#change index val to numeric to sort by position and change column names to team and position
#add column to denote either west or east
#do this for both west and east
class(east_df$Row.names) = "Numeric"
east_df$Row.names = as.integer(east_df$Row.names)
east_df = arrange(east_df, east_df$Row.names)
colnames(east_df)[1] <- "Position"
colnames(east_df)[2] <- "Team"
east_df = east_df %>% mutate(CAT = 'E')


west_df = merge(west_team, west_rec, by = "row.names", all.x = TRUE)
class(west_df$Row.names) = "Numeric"
west_df$Row.names = as.integer(west_df$Row.names)
west_df = arrange(west_df, west_df$Row.names)
colnames(west_df)[1] <- "Position"
colnames(west_df)[2] <- "Team"
west_df = west_df %>% mutate(CAT = 'W')


#union the tables together and sort by losses ascending

df_2020 = union(east_df, west_df) %>% arrange(L) %>% mutate(YEAR = '2020')

df_2020 = df_2020 %>% mutate(ACT_TEAM = sub(".*\\b([A-Z]{3}).*", "\\1", df_2020$Team))

df_2020$ACT_TEAM[df_2020$ACT_TEAM == 'NON'] = 'NOP'
df_2020$ACT_TEAM[df_2020$ACT_TEAM == 'NYN'] = 'NYK'
df_2020$ACT_TEAM[df_2020$ACT_TEAM == 'WSH'] = 'WAS'
df_2020$ACT_TEAM[df_2020$ACT_TEAM == 'GSG'] = 'GSW'

#df_2020

site = read_html("https://www.espn.com/nba/standings/_/season/2022")
table = html_nodes(site, "table")
east_team = table[1] %>% html_table(fill = TRUE) 
east_rec = table[2] %>% html_table(fill = TRUE)
west_team = table[3] %>% html_table(fill = TRUE)
west_rec = table[4] %>% html_table(fill = TRUE)
east_df = merge(east_team, east_rec, by = "row.names", all.x = TRUE)

#change index val to numeric to sort by position and change column names to team and position
#add column to denote either west or east
#do this for both west and east
class(east_df$Row.names) = "Numeric"
east_df$Row.names = as.integer(east_df$Row.names)
east_df = arrange(east_df, east_df$Row.names)
colnames(east_df)[1] <- "Position"
colnames(east_df)[2] <- "Team"
east_df = east_df %>% mutate(CAT = 'E')


west_df = merge(west_team, west_rec, by = "row.names", all.x = TRUE)
class(west_df$Row.names) = "Numeric"
west_df$Row.names = as.integer(west_df$Row.names)
west_df = arrange(west_df, west_df$Row.names)
colnames(west_df)[1] <- "Position"
colnames(west_df)[2] <- "Team"
west_df = west_df %>% mutate(CAT = 'W')


#union the tables together and sort by losses ascending

df_2021 = union(east_df, west_df) %>% arrange(L) %>% mutate(YEAR = '2021')

df_2021 = df_2021 %>% mutate(ACT_TEAM = sub(".*\\b([A-Z]{3}).*", "\\1", df_2021$Team))

df_2021$ACT_TEAM[df_2021$ACT_TEAM == 'NON'] = 'NOP'
df_2021$ACT_TEAM[df_2021$ACT_TEAM == 'NYN'] = 'NYK'
df_2021$ACT_TEAM[df_2021$ACT_TEAM == 'WSH'] = 'WAS'
df_2021$ACT_TEAM[df_2021$ACT_TEAM == 'GSG'] = 'GSW'

#df_2021

#
df_all = union_all(df_2019, df_2020)s
df_all = union_all(df_all, df_2021)

write.csv(df_all, "Season.csv", row.names=FALSE)