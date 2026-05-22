# R/04_dashboard.R
library(tidyverse)
library(crosstalk)
library(DT)
library(htmltools)

generate_static_dashboard <- function(historical_db, cfg) {
  if (nrow(historical_db) == 0) {
    historical_db <- tibble(
      date_scraped = as.character(Sys.Date()), 
      title = "No jobs indexed yet. Check back tomorrow!",
      country = "System", 
      portal = "System", 
      discipline = "System", 
      url = "#"
    )
  }

  display_df <- historical_db %>%
    mutate(Link = paste0("<a href='", url, "' target='_blank' style='text-decoration:none;font-weight:bold;color:#1a5fb4;'>Apply ↗</a>")) %>%
    select(Date = date_scraped, Title = title, Country = country, Source = portal, Discipline = discipline, Link)

  shared_data <- SharedData$new(display_df)

  dashboard_html <- tags$html(
    tags$head(
      tags$title("Academic Research Job Feed"),
      tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css")
    ),
    tags$body(
      style = "background-color: #f6f8fa; padding-top: 40px;",
      div(class = "container",
          div(class = "row mb-4",
              div(class = "col-12",
                  tags$h2(class = "fw-bold", "Academic Research Openings"),
                  tags$p(class = "text-muted", paste("Last update execution check:", Sys.time(), "UTC"))
              )
          ),
          div(class = "row",
              div(class = "col-md-3 mb-4",
                  div(class = "card p-3 shadow-sm border-0",
                      tags$h6(class = "fw-bold mb-3 text-secondary", "Filters"),
                      filter_select("filter_country", "Country", shared_data, ~Country),
                      br(),
                      filter_select("filter_disc", "Discipline", shared_data, ~Discipline)
                  )
              ),
              div(class = "col-md-9",
                  div(class = "card p-3 shadow-sm border-0",
                      datatable(shared_data, escape = FALSE, rownames = FALSE,
                                options = list(pageLength = 15, dom = 'ftp'))
                  )
              )
          )
      )
    )
  )

  save_html(dashboard_html, "index.html")
}
