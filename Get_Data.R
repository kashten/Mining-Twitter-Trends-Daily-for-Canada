#The script requires the following packages to be installed.
#install.packages("RSQLite")
#install.packages("rtweet")
#install.packages ("sqldf")

#Setting Working Directory
setwd = ("/Users/kashs/Desktop/AKash_R/Get_Data.R")

#Calling Libraries
library (sqldf)
library(twitteR)
library (pacman)
library(data.table) 
library (stringr) #Replace characters/Wrangling
library (RSQLite) #DB Connection
library (rtweet)
library (dplyr)

#Installing GITHub package
p_install_gh ("bnosac/cronR")
p_load('miniUI')
p_load('shiny')
p_load('shinyFiles')

#Authenticating Twitter access using keys
api_key <- "gtTyUGXWDez6fQ5p2OsRzvpvo"
api_secret <- "fIj4BeEg8malBx5P456zzvHzPopau9ZzenYcvAZw5y0jxWP9v7"
access_token <- "1122900714689265666-ZcO2gqfLhpRqvAIUj4pPg9LNNOtUWE"
access_secret <- "z9zpG18AvaCewcUT2CxPRaThHr9Npx3FCQOEsa8Uju92Y"
setup_twitter_oauth(api_key, api_secret, access_token, access_secret)


#Canada Trends (WOEID - 2342775)
trend_canada <- getTrends (23424775)
trend_canada ["trend_date"] = as.character.Date(Sys.Date())
trend_canada$name <- str_replace(trend_canada$name, '#','' )

#Offline Raw Database
write.table(trend_canada, file = 'trend_canada_raw.csv', sep= ",", col.names = T, row.names = F, append = T)

#Reading from fetched raw csv.
db_canada <- read.csv.sql("trend_canada_raw.csv", sql = "select * from file")
canada_grouped <- db_canada %>% group_by(trend_date, name) %>% summarise(popularity =n ()) %>% arrange(desc(popularity))

#Setting up connection to SQL
con = dbConnect(SQLite())
#Creating a Database
db <- dbConnect(SQLite(), dbname="Twitter_Trends_Canada.sqlite")
#Import DF into DB
dbWriteTable(con=db, name = "Canada_DB", canada_grouped, overwrite= T, row.names = FALSE)
dbListTables(db)

#Query - Show all records from the DB where city code is 4118. 
dbGetQuery (con=db, "SELECT  name,trend_date, popularity FROM Canada_DB WHERE trend_date < '2019-05-01' LIMIT 100")
dbDisconnect(db)
