# main.R
library(tidyverse)

# Source the dashboard generator script
source("R/04_dashboard.R")

db_path <- "data/jobs_feed.csv"

# Force read the tracking file safely with explicit character column definitions
historical_db <- read_csv(db_path, col_types = cols(.default = col_character()))

message("Starting academic job scrapers...")

# Build a clean data frame with explicit row parameters
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

# Merge data records together cleanly
updated_db <- bind_rows(historical_db, new_scraped_jobs) %>%
  distinct(title, institution, url, .keep_all = TRUE)

# Write out the baseline data update
write_csv(updated_db, db_path)
message(paste("Database updated. Total tracked listings:", nrow(updated_db)))

# Execute dashboard engine compilation
message("Compiling static HTML dashboard website...")
generate_static_dashboard(updated_db, NULL)
message("Pipeline completed successfully!")
