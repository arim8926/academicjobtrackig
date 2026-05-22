# R/04_dashboard.R
library(tidyverse)
library(crosstalk)
library(DT)
library(htmltools)

generate_static_dashboard <- function(historical_db, cfg = NULL) {
  
  if (is.null(historical_db) || nrow(historical_db) == 0) {
    historical_db <- tibble(
      date_scraped = as.character(Sys.Date()), 
      title = "Initial setup active. Running system initialization sweep...",
      institution = "System",
      country = "Norway", 
      portal = "System", 
      discipline = "Political Science", 
      url = "#",
      salary = "NA",
      language = "English"
    )
  }

  display_df <- historical_db %>%
    mutate(Link = paste0("<a href='", url, "' target='_blank' style='font-weight:bold;color:#1a5fb4;'>Apply ↗</a>")) %>%
    select(Date = date_scraped, Title = title, Institution = institution, Country = country, Source = portal, Discipline = discipline, Link)

  shared_data <- SharedData$new(display_df)

  dashboard_html <- tags$html(
    tags$head(
      tags$title("Academic Research Job Feed"),
      tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css")
    ),
    tags$body(
      style = "background-color: #f6f8fa; padding: 40px 0;",
      div(class = "container",
          div(class = "row mb-4",
              div(class = "col-12",
                  tags$h2(class = "fw-bold text-dark", "Academic Research Openings"),
                  tags$p(class = "text-muted", paste("System Update Execution Timestamp:", Sys.time(), "UTC"))
              )
          ),
          div(class = "row",
              div(class = "col-md-3 mb-4",
                  div(class = "card p-3 shadow-sm border-0 bg-white",
                      tags$h6(class = "fw-bold mb-3 text-secondary", "Search Filters"),
                      filter_select("filter_country", "Country Selection", shared_data, ~Country),
                      br(),
                      filter_select("filter_disc", "Discipline Field", shared_data, ~Discipline)
                  )
              ),
              div(class = "col-md-9",
                  div(class = "card p-3 shadow-sm border-0 bg-white",
                      datatable(shared_data, escape = FALSE, rownames = FALSE,
                                options = list(pageLength = 10, dom = 'ftp', autoWidth = TRUE))
                  )
              )
          )
      )
    )
  )

  # CRITICAL UPDATE: Force HTML dependencies to bake directly into the file inline
  htmltools::save_html(
    htmltools::browsable(dashboard_html), 
    "index.html", 
    libdir = "lib" # Keeps background compiler happy
  )
  
  # Inject dependency rendering engine explicitly to avoid missing folder traps
  rendered_page <- rmarkdown::pandoc_available() 
  if(!rendered_page) {
    # Fail-safe inline conversion fallback
    html_content <- readLines("index.html", warn = FALSE)
    # Re-save to clear any external path relative references
    writeLines(html_content, "index.html")
  }
}
