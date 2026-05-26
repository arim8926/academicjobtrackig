#triggering system rebuild sweep
# main.R
library(tidyverse)
library(jsonlite)

# Source the dashboard engine
source("R/04_dashboard.R")

db_path <- "data/jobs_feed.csv"

# 1. Read existing data safely
if (file.exists(db_path)) {
  historical_db <- read_csv(db_path, col_types = cols(.default = col_character()))
} else {
  historical_db <- tibble(
    date_scraped = character(), deadline = character(), title = character(),
    institution = character(), country = character(), portal = character(),
    discipline = character(), url = character(), salary = character(), language = character()
  )
}

# =========================================================================
# 2. YOUR SCRAPER FUNCTIONS WILL INJECT NEW DATA HERE
# =========================================================================
message("Executing country web scraper routines...")

# For right now, we keep the data frame clean so it uses your CSV data directly
new_scraped_jobs <- tibble(
  date_scraped = character(), deadline = character(), title = character(),
  institution = character(), country = character(), portal = character(),
  discipline = character(), url = character(), salary = character(), language = character()
)


# =========================================================================
# 3. Merge, Deduplicate, and Render Dashboard
# =========================================================================

# Combine and ensure absolute unique rows based on URL
updated_db <- bind_rows(historical_db, new_scraped_jobs) %>%
  distinct(url, .keep_all = TRUE)

# Save back to CSV data tracker
write_csv(updated_db, db_path)
message(paste("Database sync complete. Total listings tracked:", nrow(updated_db)))

# Compile the final standalone dashboard
generate_static_dashboard(updated_db, NULL)
message("Pipeline completed successfully!")
