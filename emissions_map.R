# Create a choropleth map of US Asphalt Emissions for 2018
# This script was created by Qwen3-4b-Instruct-4bit (MLX) with 6 manual (human) edits (@brianhigh)

# Load required packages
#library(pacman)     # 1. Replaced with a *conditional* install of pacman, below. (@brianhigh)
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(dplyr, ggplot2, readxl, usmap)

# Set working directory to project root
# setwd(dirname(parent.frame()$ofile)).   # 2. Commented out as not needed and doesn't work. (@brianhigh)

# Create directories if they don't exist
dir.create("data", showWarnings = FALSE)
dir.create("plots", showWarnings = FALSE)

# Download EPA data if it doesn't exist
data_file <- "data/AP_2018_State_County_Inventory.xlsx"
if (!file.exists(data_file)) {
  cat("Downloading EPA data...\n")
  download.file("https://pasteur.epa.gov/uploads/10.23719/1531683/AP_2018_State_County_Inventory.xlsx", 
                data_file, method = "curl", mode = "wb")
} else {
  cat("EPA data already exists, skipping download.\n")
}

# Read the "Output - State" sheet
emissions_data <- readxl::read_excel(data_file, sheet = "Output - State", 
                                      col_names = TRUE, .name_repair = "unique_quiet")

# Clean and process the data
emissions_data <- emissions_data %>%
  rename(state = `State`, emissions_per_capita = `Total kg/person`) %>%
  mutate(emissions_per_capita = as.numeric(as.character(suppressWarnings(as.character(emissions_per_capita))))) %>%
  mutate(state = tolower(state))

# Remove any rows with NA emissions (to avoid issues in plotting)
emissions_data <- emissions_data %>%
  filter(!is.na(emissions_per_capita))

# Create the choropleth map
# library(usmap)          # 3. Commented out as not needed (redundant). (@brianhigh)
p <- plot_usmap(data = emissions_data, values = "emissions_per_capita") +
  scale_fill_gradient2(low = "darkgreen", mid = "yellow", high = "red",
                       midpoint = median(emissions_data$emissions_per_capita),
                       na.value = "grey90",
                       # 4. The 2 lines below were modified from `guides(...)` further below. (@brianhigh)
                       name = "Per Capita\nEmissions\n(kg/person)",
                       guide = "colourbar") +
  theme_void() +
  theme(panel.background = element_rect(fill = "white", color = NA),
        plot.background = element_rect(fill = "white", color = NA)) +
  labs(title = "Per Capita Asphalt Emissions by State (2018)",
       subtitle = "Total kilograms per person based on EPA State County Inventory data.",
       caption = "Source: EPA (2023) | DOI: 10.1039/D3EA00066D") +
  #guides(fill = guide_legend(title = "Per Capita Emissions (kg/person)")) +  # 5. See above (@brianhigh)
  #coord_map() +          # 6. Commented out as not needed and doesn't work. (@brianhigh)
  theme(legend.position = "right",
        legend.title = element_text(size = 10),
        plot.title = element_text(size = 14, face = "bold"),
        plot.subtitle = element_text(size = 10),
        plot.caption = element_text(size = 8, hjust = 0))

# Export the map
ggsave("plots/asphalt_emissions_map.png", plot = p, width = 10, height = 7, dpi = 300, bg = "white")





