# Load necessary packages
library(circlize)
library(dplyr)

# ==============================================================================
# Basic Chord Diagram with Radial Layout
# ==============================================================================

# Create sample data matrix showing flows between categories
sample_data <- matrix(c(
  10, 20, 30, 40,
  15, 25, 35, 45,
  12, 22, 32, 42,
  18, 28, 38, 48
), nrow = 4, ncol = 4, byrow = TRUE,
  dimnames = list(
    source = c("A", "B", "C", "D"),
    target = c("W", "X", "Y", "Z")
  )
)

# Clear previous circular layout settings
circos.clear()

# Set parameters for the chord diagram
# Define colors for each sector
colors <- c("#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4")

# Initialize the circular layout
# The start.degree parameter controls where the diagram starts
circos.par(
  start.degree = 90,  # Start at the top
  gap.degree = 2,     # Gap between sectors
  track.height = 0.15 # Height of the sectors
)

# Create the chord diagram
chordDiagram(
  x = sample_data,               # The flow matrix
  grid.col = colors,             # Colors for sectors
  transparency = 0.6,            # Transparency of the chords
  directional = 1,               # Add direction indicators
  direction.type = c("diffHeight", "arrows"), # Types of direction indicators
  link.arr.type = "big.arrow",   # Arrow style
  link.sort = TRUE,              # Sort links to avoid overlapping
  link.decreasing = TRUE,        # Sort direction
  annotationTrack = "grid",      # Show grid lines
  annotationTrackHeight = c(0.03, 0.01), # Heights of annotation tracks
  preAllocateTracks = 1,         # Pre-allocate tracks for labels
  self.link = 1                  # Allow self-links
)

# Add labels to the sectors
circos.trackPlotRegion(
  track.index = 1, 
  bg.border = NA, # No border
  panel.fun = function(x, y) {
    sector.index <- get.cell.meta.data("sector.index")
    xlim <- get.cell.meta.data("xlim")
    ylim <- get.cell.meta.data("ylim")
    # Add text labels with appropriate rotation
    circos.text(
      x = mean(xlim), 
      y = ylim[2] + mm_y(5), 
      labels = sector.index, 
      facing = "clockwise", 
      niceFacing = TRUE, 
      cex = 0.8
    )
  }
)

# Add a title
title("Basic Chord Diagram with Flow Directions")

# ==============================================================================
# Enhanced Chord Diagram with Different Flow Visualization
# ==============================================================================

# Clear previous circular layout settings
circos.clear()

# Create a more complex dataset with real-world categories
# For example, patient transfers between departments
patient_transfers <- matrix(c(
  120, 30, 15, 10, 5,
  40, 90, 25, 15, 20,
  10, 35, 100, 40, 15,
  5, 15, 30, 80, 45,
  10, 5, 15, 30, 90
), nrow = 5, ncol = 5, byrow = TRUE,
  dimnames = list(
    from = c("Emergency", "ICU", "Surgery", "Medicine", "Pediatrics"),
    to = c("Emergency", "ICU", "Surgery", "Medicine", "Pediatrics")
  )
)

# Define department colors
dept_colors <- c(
  "Emergency" = "#E74C3C", 
  "ICU" = "#3498DB", 
  "Surgery" = "#2ECC71", 
  "Medicine" = "#F39C12", 
  "Pediatrics" = "#9B59B6"
)

# Set parameters for the enhanced chord diagram
circos.par(
  start.degree = 90,
  gap.degree = 3,
  track.height = 0.2
)

# Create the enhanced chord diagram with specific styling for flow visualization
chordDiagram(
  x = patient_transfers,
  grid.col = dept_colors,
  transparency = 0.5,
  directional = TRUE,
  direction.type = c("diffHeight", "arrows"),
  link.arr.type = "big.arrow",
  link.sort = TRUE,
  link.decreasing = TRUE,
  annotationTrack = c("name", "grid"),
  preAllocateTracks = list(track.height = max(strwidth(unlist(dimnames(patient_transfers)))))
)

# Add custom labels with better positioning
for(s in get.all.sector.indexes()) {
  circos.axis(h = "top", labels.cex = 0.6, sector.index = s)
}

# Add a legend
legend("right", 
       legend = names(dept_colors), 
       fill = dept_colors,
       cex = 0.7,
       bty = "n")

# Add a title
title("Patient Transfers Between Departments")

# ==============================================================================
# Interactive Chord Diagram using htmlwidgets (Optional)
# ==============================================================================

# For interactive chord diagrams, you can use the chorddiag package
# Uncomment the following lines to install and use it

# install.packages("chorddiag")
# library(chorddiag)

# # Create an interactive chord diagram
# p <- chorddiag(
#   patient_transfers,
#   groupColors = dept_colors,
#   groupnamePadding = 20,
#   margin = 90,
#   width = 800,
#   height = 800
# )
# 
# # Display the interactive diagram
# p
# 
# # Save as HTML for web display
# # htmlwidgets::saveWidget(p, "interactive_chord_diagram.html")