# R/04_dashboard.R
library(tidyverse)
library(jsonlite)

generate_static_dashboard <- function(historical_db, cfg = NULL) {
  
  # Fail-safe check to verify rows exist
  if (is.null(historical_db) || nrow(historical_db) == 0) {
    historical_db <- tibble(
      date_scraped = as.character(Sys.Date()), 
      title = "Running system initialization sweep...",
      institution = "System",
      country = "Norway", 
      portal = "System", 
      discipline = "Political Science", 
      url = "#"
    )
  }

  # Format rows and columns safely
  display_df <- historical_db %>%
    mutate(Link = paste0("<a href='", url, "' target='_blank' class='btn btn-sm btn-primary fw-bold'>Apply ↗</a>")) %>%
    select(Date = date_scraped, Title = title, Institution = institution, Country = country, Source = portal, Discipline = discipline, Link)

  # Convert data frame directly into a JavaScript JSON array
  json_data <- jsonlite::toJSON(display_df, pretty = TRUE)

  # Write a completely flat, self-contained HTML page using CDN links
  html_template <- paste0('<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Academic Research Job Feed</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
    <style>
        body { background-color: #f6f8fa; padding: 40px 0; }
        .card { border-radius: 8px; }
        select { padding: 6px; width: 100%; border-radius: 4px; border: 1px solid #ccc; }
    </style>
</head>
<body>
    <div class="container">
        <div class="row mb-4">
            <div class="col-12">
                <h2 class="fw-bold text-dark">Academic Research Openings</h2>
                <p class="text-muted">System Update Timestamp (UTC): ', Sys.time(), '</p>
            </div>
        </div>
        <div class="row">
            <div class="col-md-3 mb-4">
                <div class="card p-3 shadow-sm border-0 bg-white">
                    <h6 class="fw-bold mb-2 text-secondary">Filter by Country</h6>
                    <select id="countryFilter" class="form-select mb-3">
                        <option value="">All Countries</option>
                    </select>
                    
                    <h6 class="fw-bold mb-2 text-secondary">Filter by Discipline</h6>
                    <select id="disciplineFilter" class="form-select">
                        <option value="">All Disciplines</option>
                    </select>
                </div>
            </div>
            <div class="col-md-9">
                <div class="card p-3 shadow-sm border-0 bg-white">
                    <table id="jobsTable" class="table table-striped table-hover row-border" style="width:100%">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Title</th>
                                <th>Institution</th>
                                <th>Country</th>
                                <th>Source</th>
                                <th>Discipline</th>
                                <th>Link</th>
                            </tr>
                        </thead>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>

    <script>
        // Inject data from R directly into JavaScript
        const jobsData = ', json_data, ';

        $(document).ready(function() {
            // Initialize DataTables
            const table = $("#jobsTable").DataTable({
                data: jobsData,
                columns: [
                    { data: "Date" },
                    { data: "Title" },
                    { data: "Institution" },
                    { data: "Country" },
                    { data: "Source" },
                    { data: "Discipline" },
                    { data: "Link", orderable: false }
                ],
                pageLength: 10,
                dom: "ftp"
            });

            // Dynamically populate the sidebar dropdown filters
            const countries = [...new Set(jobsData.map(item => item.Country))].sort();
            countries.forEach(c => {
                if(c) $("#countryFilter").append(`<option value="${c}">${c}</option>`);
            });

            const disciplines = [...new Set(jobsData.map(item => item.Discipline))].sort();
            disciplines.forEach(d => {
                if(d) $("#disciplineFilter").append(`<option value="${d}">${d}</option>`);
            });

            // Link dropdown behaviors to the DataTable filtering logic
            $("#countryFilter").on("change", function() {
                table.column(3).search(this.value).draw();
            });
            $("#disciplineFilter").on("change", function() {
                table.column(5).search(this.value).draw();
            });
        });
    </script>
</body>
</html>')

  # Write the flat text file directly to disk
  writeLines(html_template, "index.html")
}
