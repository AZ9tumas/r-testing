#!/usr/bin/env bash
set -e

echo "========================================="
echo " R Environment Setup"
echo "========================================="

# Verify R and Rscript are available
echo ">> Checking R installation..."
R --version | head -1
Rscript --version

# Install system dependencies that animint2 and other R packages may need
echo ">> Installing system dependencies..."
apt-get update -qq && apt-get install -y --no-install-recommends \
  libcurl4-openssl-dev \
  libssl-dev \
  libxml2-dev \
  libfontconfig1-dev \
  libharfbuzz-dev \
  libfribidi-dev \
  libfreetype6-dev \
  libpng-dev \
  libtiff5-dev \
  libjpeg-dev \
  libgit2-dev \
  > /dev/null 2>&1 || true

# Install R packages: ggplot2, animint2, data.table, and their dependencies
echo ">> Installing R packages (ggplot2, animint2, data.table)..."
Rscript -e "
  options(repos = c(CRAN = 'https://cloud.r-project.org'));

  # List of required packages
  required_pkgs <- c('ggplot2', 'animint2', 'data.table')

  # Check which are already installed
  installed <- rownames(installed.packages())
  to_install <- setdiff(required_pkgs, installed)

  if (length(to_install) > 0) {
    cat('Installing:', paste(to_install, collapse = ', '), '\n')
    install.packages(to_install)
  } else {
    cat('All required packages already installed.\n')
  }

  # Verify all packages load correctly
  cat('\n>> Verifying packages load successfully...\n')
  for (pkg in required_pkgs) {
    library(pkg, character.only = TRUE)
    cat('  ✓', pkg, packageVersion(pkg), '\n')
  }
  cat('\nR environment setup complete.\n')
"

echo "========================================="
echo " Setup finished successfully"
echo "========================================="
