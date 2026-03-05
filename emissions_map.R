# R script to visualize 2018 U.S. asphalt emissions by state

# The LLM made several errors in the original code, including
# incorrect download method, missing plot settings, and misplacement
# of the output file path. These have been corrected in this version.
# So, 10 corrections were made, commented by (and attributed to) @brianhigh.

# Load required packages
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(dplyr, ggplot2, readxl, usmap)

# Set seed for reproducibility
#set.seed(123)  # Not needed as we are using real data (@brianhigh)

# Function to download and process EPA data
process_emissions_data <- function() {
  # Define file paths
  data_url <- "https://pasteur.epa.gov/uploads/10.23719/1531683/AP_2018_State_County_Inventory.xlsx"
  data_file <- "data/AP_2018_State_County_Inventory.xlsx"
  
  # Download data with error handling
  cat("Downloading EPA 2018 asphalt emissions data...\n")
  
  # Try to download the file, create a backup if needed
  if (!file.exists(data_file)) {
    tryCatch({
      # The LLM assigned method = "wb" incorrectly, and had no "mode" (@brianhigh)
      download.file(data_url, data_file, method = "curl", mode = "wb")
      cat("Data downloaded successfully.\n")
    }, error = function(e) {
      cat("Error downloading data:", e$message, "\n")
      stop("Failed to download data. Please check the URL and internet connection.")
    })
  } else {
    cat("Data already exists. Skipping download.\n")
  }
  
  # Read the data from the 'Output - State' sheet
  if (!file.exists(data_file)) {
    stop("Data file not found. Ensure the download completed successfully.")
  }
  
  # Read the Excel file with proper column handling
  emissions_data <- readxl::read_excel(
    data_file,
    sheet = "Output - State",
    .name_repair = "unique_quiet"
  )
  
  # Rename columns and clean data
  emissions_data <- emissions_data %>%
    rename(state = `State`, emissions_per_capita = `Total kg/person`) %>%
    mutate(
      emissions_per_capita = as.numeric(as.character(emissions_per_capita)),
      state = tolower(state)
    ) %>%
    suppressWarnings() %>%
    filter(!is.na(emissions_per_capita))
  
  # Add a row for missing states (if needed)
  # For now, we'll proceed with the available data
  
  return(emissions_data)
}

# Main visualization function
create_emissions_map <- function(data) {
  # Create the choropleth map
  # library(usmap)    # Redundant as it's already loaded at the top (@brianhigh)
  
  # Create the base map with custom styling
  map <- plot_usmap(
    data = data,
    values = "emissions_per_capita"
    #midpoint = median(data$emissions_per_capita, na.rm = TRUE),  # See below (@brianhigh)
    #fill = "emissions_per_capita"
  ) +
    # The LLM did not save the rest of the plot settings to `map` object (@brianhigh)
    # Customize the plot with theme and annotations
    scale_fill_gradient2(
      low = "darkgreen",
      mid = "yellow",
      high = "red",
      midpoint = median(data$emissions_per_capita, na.rm = TRUE),
      # Added the \n for line wrap of the legend title by hand (@brianhigh)
      name = "Per Capita\nEmissions\n(kg/person)"
    ) +
    theme_void() +
    # The LLM garbled the panel and plot background settings below, so coded myself (@brianhigh)
    theme(
      panel.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA)
    ) +
    labs(
      title = "Per Capita Asphalt Emissions by State (2018)",
      subtitle = "Total kilograms per person based on EPA State County Inventory data.",
      caption = "Source: EPA (2023) | DOI: 0.1039/D3EA00066D"
    ) +
    #guides(fill = guide_legend("right")) +    # Redundant (@brianhigh)
    theme(
      plot.title = element_text(size = 12, face = "bold"),
      plot.subtitle = element_text(size = 10, face = "italic"),
      # The LLM made the caption gray too light to read ("gray"), so I darkened it ("gray20") (@brianhigh)
      plot.caption = element_text(size = 8, hjust = 0, vjust = 0, color = "gray20"),
      legend.title = element_text(size = 10)
    )
}

# Main execution
# Process the data
emissions_data <- tryCatch({
  process_emissions_data()
}, error = function(e) {
  cat("Error processing data:", e$message, "\n")
  stop("Failed to process data. Check data integrity and formatting.")
})

# Create and export the map
# This line was incorrectly placed inside the function in the original LLM output (@brianhigh)
output_file <- "plots/asphalt_emissions_map.png"
if (exists("emissions_data") && !is.null(emissions_data)) {
  map <- create_emissions_map(emissions_data)
  ggsave(
    filename = output_file,
    plot = map,
    width = 10,
    height = 7,
    dpi = 300,
    bg = "white"
  )
  cat("Map successfully exported to:", output_file, "\n")
} else {
  cat("No data to visualize. Check data processing steps.\n")
}
