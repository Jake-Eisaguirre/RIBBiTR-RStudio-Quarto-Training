# Retrieve frog lengths and weights from "amphibians" database, minor data cleaning

# Load required packages
if (!require(librarian)){
  install.packages("librarian")
  library(librarian)
}
librarian::shelf(here, tidyverse, DBI, RPostgres, dbplyr, kableExtra)

# Connect to database
con <- dbConnect(drv = dbDriver("Postgres"),
                dbname = Sys.getenv("dbname"),
                host = Sys.getenv("host"), 
                port = Sys.getenv("port"), 
                user = rstudioapi::askForPassword("user name"),
                password = rstudioapi::askForPassword("password")
                )

# Extract data from database
len_wt <- tbl(con, "visit") %>% 
  rename(visit_id = id) %>% 
  inner_join(tbl(con, "survey"), join_by(visit_id)) %>% 
  inner_join(tbl(con, "capture_survey"), join_by(id == survey_id)) %>% 
  select(c(site_id, visit_date, species, capture_life_stage, capture_animal_state, length, weight)) %>% 
  filter(site_id == 70550, 
    capture_life_stage %in% c("subadult", "adult"), 
    capture_animal_state != "dead", 
    !(length == 36 & weight == 34 | length == 54 & weight == 2),
    across(c(length, weight), ~ !is.na(.))) %>% 
  collect()

# Save data as csv file
write_csv(len_wt, here("Workshop_2", "data", "len_wt.csv"))

