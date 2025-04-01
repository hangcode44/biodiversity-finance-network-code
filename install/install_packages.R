packages <- c(
  "readxl",
  "dplyr",
  "stringr",
  "colorspace",
  "colorBlindness",
  "rcartocolor",
  "ggrepel",
  "ggplot2",
  "tools",
  "patchwork"
)

installed_packages <- rownames(installed.packages())

for (pkg in packages) {
  if (!pkg %in% installed_packages) {
    install.packages(pkg, dependencies = TRUE)
  }
}
