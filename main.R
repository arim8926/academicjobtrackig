# main.R
library(tidyverse)
library(jsonlite)

# Source the dashboard engine
source("R/04_dashboard.R")

db_path <- "data/jobs_feed.csv"
historical_db <- read_csv(db_path, col_types = cols(.default = col_character()))

message("Processing scraped listings...")

# Build a clean mock row structure
new_scraped_jobs <- tibble(
  date_scraped = as.character(Sys.Date()),
  deadline = "2026-06-30",
  title = "Postdoctoral Researcher in Political Science",
  institution = "Universitetet i Oslo",
  country = "Norway",
  portal = "JobbNorge",
  discipline = "Political Science",
  url = "https://www.uio.no",
  salary = "Check Listing",
  language = "English"
)

# Merge records cleanly
updated_db <- bind_rows(historical_db, new_scraped_jobs) %>%
  distinct(title, institution, url, .keep_all = TRUE)

# Save to your database tracker
write_csv(updated_db, db_path)

# Execute flat web builder
generate_static_dashboard(updated_db, NULL)
message("Pipeline completed successfully!")
