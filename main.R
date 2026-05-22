# main.R
library(tidyverse)

# 1. Source the dashboard generator script we created earlier
source("R/04_dashboard.R")

# 2. Load your historical data tracking file
db_path <- "data/jobs_feed.csv"
historical_db <- read_csv(db_path, col_types = cols(.default = "c"))

# =========================================================================
# 3. YOUR SCRAPER CODE GOES HERE
# =========================================================================
message("Starting academic job scrapers...")

# [Placeholder for your scraping function]
# Let's assume your scraping script outputs a data frame called `new_scraped_jobs`
# with the exact column structure matching your CSV.
new_scraped_jobs <- tibble(
  date_scraped = character(), deadline = character(), title = character(),
  institution = character(), country = character(), portal = character(),
  discipline = character(), url = character(), salary = character(), language = character()
)

# Example sample row just to verify the system works on your first run
# Delete or comment this out once your real scraping functions are linked!
new_scraped_jobs <- new_scraped_jobs %>% 
  add_row(
    date_scraped = as.character(Sys.Date()),
    deadline = "2026-06-30",
    title = "Postdoctoral Researcher in Data Science",
    institution = "Universitetet i Oslo",
    country = "Norway",
    portal = "JobbNorge",
    discipline = "Computational Science",
    url = "https://www.uio.no",
    salary = "Check Listing",
    language = "English"
  )

# =========================================================================
# 4. Merge data, remove duplicates, and update files
# =========================================================================

# Combine old records with new findings, dropping perfect duplicates
updated_db <- bind_rows(historical_db, new_scraped_jobs) %>%
  distinct(title, institution, url, .keep_all = TRUE)

# Write the updated database back to the repository data folder
write_csv(updated_db, db_path)
message(paste("Database updated. Total tracked listings:", nrow(updated_db)))

# 5. Execute the dashboard engine to compile the new index.html
message("Compiling static HTML dashboard website...")
generate_static_dashboard(updated_db)
message("Pipeline completed successfully!")
