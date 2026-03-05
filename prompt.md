### **Coding Prompt**

**Goal:**
Create a reproducible R project that visualizes 2018 U.S. asphalt emissions. The script must download data from the EPA, process it, and generate a high-quality choropleth map saved to a specific directory structure.

---

### **1. Environment & Setup**

* **Package Management:** Use `pacman::p_load()` to check for, install, and load: `dplyr`, `ggplot2`, `readxl`, and `usmap`.
* **Directory Logic:** The script must programmatically check for and create two directories: `data/` and `plots/`.
* **File Handling:** Download the Excel file from the [EPA URL](https://pasteur.epa.gov/uploads/10.23719/1531683/AP_2018_State_County_Inventory.xlsx) into `data/` only if it doesn't already exist. Use `mode = "wb"` for the download.

---

### **2. Data Processing (`emissions_map.R`)**

* **Extraction:** Read the **"Output - State"** sheet. Use `readxl::read_Excel()` and the parameter `.name_repair = "unique_quiet"`.
* **Cleaning:**
* Rename columns to `state` and `emissions_per_capita` (from `Total kg/person`).
* Use `mutate()` and `as.numeric(as.character())` to convert emissions, wrapping it in `suppressWarnings()` to ignore NAs introduced by non-numeric placeholders.
* Convert `state` strings to lowercase to match standard mapping IDs.

---

### **3. Visualization Requirements**

* **Base Map:** Use `plot_usmap(data = emissions_data, values = "emissions_per_capita")`.
* **Color Theory:**
   * Apply `scale_fill_gradient2()` with a three-color gradient: **darkgreen** (low), **yellow** (mid), and **red** (high).
   * Set the `midpoint` dynamically to the **median** of the emissions data.
   * Handle `NA` values by coloring those states **grey90**.


* **Styling:**
   * **Theme:** Use `theme_void()` as a starting point, then override with `panel.background = element_rect(fill = "white", color = NA)` and `plot.background = element_rect(fill = "white", color = NA)`.
   * **Legend:** Place on the right. Format labels using `scales::comma`.


* **Annotations:**
   * **Title:** "Per Capita Asphalt Emissions by State (2018)"
   * **Subtitle:** "Total kilograms per person based on EPA State County Inventory data."
   * **Caption:** "Source: EPA (2023) | DOI: 10.1039/D3EA00066D" (Place in bottom-left).


* **Export:** Save as `plots/asphalt_emissions_map.png` using `ggsave()`. Set `width = 10`, `height = 7`, and `dpi = 300`. Ensure `bg = "white"`.

---

### **4. Documentation (`README.md`)**

Generate a Markdown file that includes:

* **Header:** Project title and a brief description of the study.
* **Visual:** Embed the generated PNG (use a relative path).
* **Citations:** * Data: *U.S. EPA 2018 State County Inventory.*
* Research: *Anthropogenic secondary organic aerosol and ozone production from asphalt-related emissions, Environ. Sci.: Atmos., 2023, 3, 1221-1230.*


* **Project Structure Tree:**

```text
.
├── data/               # Raw EPA Excel files
├── plots/              # Generated choropleth maps
├── emissions_map.R     # Main processing script
└── README.md           # Project documentation

```

---

### **5. Technical Constraints**

* **Error Handling:** Wrap the download and read functions in `tryCatch()` blocks to provide user-friendly error messages if the URL is down or the Excel format changes.
* **Code Quality:** Use pipes (`|>`) and follow Tidyverse style guidelines. Include comments explaining the "why" behind the data filtering.
