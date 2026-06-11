## -----------------------
## PRE-RENDER SCRIPT
## -----------------------

## installs packages necessary to render book, and alleviates installation
## steps from qmds (when theya re not part of example code)
repos <- c("predictiveecology.r-universe.dev", getOption("repos"))
tempDir <- tempdir()
pkgPath <- file.path(tempDir, file.path("packages", Require:::versionMajorMinor()))
if (tryCatch(packageVersion("SpaDES.project") < "0.1.1.9009", error = function(x) TRUE))
  install.packages(c("Require", "SpaDES.project"), repos = repos, lib = pkgPath)

# install.packages(c("remotes"), repos = repos)
# remotes::install_github("PredictiveEcology/SpaDES.project@development")

library(SpaDES.project)
currDir <- getwd()
print("Running installpkgs.R")
out <- setupProject(
  options = list("repos" = unique(repos)),
  paths = list(projectPath = tempDir,
               packagePath = pkgPath),
  modules = "PredictiveEcology/Biomass_core@main",
  # Restart = TRUE,
  setLinuxBinaryRepo = FALSE
)

setwd(currDir)
