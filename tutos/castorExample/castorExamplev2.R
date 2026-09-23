## ----------------------------------------------------
## Example of a Castor workflow using SpaDES.project
## ----------------------------------------------------

## adapted from https://github.com/bcgov/castor/blob/main/R/scenarios/comparison_stsm/base_case_harvest_flow_20230628.Rmd

## install/load necessary packages
options(repos = c(getOption("repos"), PE = "https://predictiveecology.r-universe.dev/"))
if (!require("pak")) install.packages("pak")
pak::pak(c("Require",
           "SpaDES.project"), ask = FALSE)
Require::Require("SpaDES.project", install = FALSE)

## set up the workflow paths, dependencies and modules
## as well as simulation parameters, (some) inputs and outputs
out <- setupProject(
  paths = list("projectPath" = "~/tests/castorExample",
               "inputPath" = "scenarios/comparison_stsm/inputs",
               "outputPath" = "scenarios/comparison_stsm/outputs"),
  modules = c("bcgov/dataCastor",
              "bcgov/growingStockCastor",
              "bcgov/forestryCastor",
              "bcgov/blockingCastor"),
  functions = "bcgov/castor@main/R/functions/R_Postgres.R",
  ## install and load
  require = c("dplyr", "reproducible"),
  ## install but don't load these:
  packages = c(
    "DBI",
    "DiagrammeR",
    "data.table",
    "googledrive",
    "keyring",
    "rgdal",
    "RPostgreSQL",
    "sp",
    "terra"
  ),
  sideEffects = {
    reproducible::preProcess(url = "https://drive.google.com/file/d/1-2POunzC7aFbkKK5LeBJNsFYMBBY8dNx/view?usp=sharing",
                             destinationPath = "R/scenarios/comparison_stsm",
                             fun = NA)
  },
  params = "params.R",
  times = list(start = 0, end = 20),
  outputs = {
    data.frame(objectName = c("harvestReport",
                              "growingStockReport"))
  },
  scenario = {
    data.table::data.table(name = "stsm_base_case",
                           description = paste("Priority queue = oldest first. Adjacency constraint",
                                               "= None. Includes roads (mst) and blocks (pre).",
                                               "Harvest flow = 147,300 m3/year in decade 1, 133,500",
                                               "m3/year in decade 2, 132,300 m3/year in decades 3 to",
                                               "14 and 135,400 m3/year in decades 15 to 25.",
                                               "Minimum harvest age = 80 and minimum harvest volume = 150"))
  },
  harvestFlow = {
    data.table::rbindlist(list(
      data.table::data.table(compartment = "tsa99",
                             partition = ' age > 79 AND vol > 149 ',
                             period = rep( seq (from = 1,
                                                to = 1,
                                                by = 1),
                                           1),
                             flow = 1473000,
                             partition_type = 'live'),
      data.table::data.table(compartment = "tsa99",
                             partition = ' age > 79 AND vol > 149 ',
                             period = rep( seq (from = 2,
                                                to = 2,
                                                by = 1),
                                           1),
                             flow = 1335000,
                             partition_type = 'live'),
      data.table::data.table(compartment = "tsa99",
                             partition = ' age > 79 AND vol > 149 ',
                             period = rep( seq (from = 3,
                                                to = 14,
                                                by = 1),
                                           1),
                             flow = 1323000,
                             partition_type = 'live'),
      data.table::data.table(compartment = "tsa99",
                             partition = ' age > 79 AND vol > 149 ',
                             period = rep( seq (from = 15,
                                                to = 25,
                                                by = 1),
                                           1),
                             flow = 1354000,
                             partition_type = 'live')
    ))
  },
  Restart = TRUE
)

## initialize simulation
castorInit <- do.call(SpaDES.core::simInit, out)

## inspect the `simList`
SpaDES.core::params(castorInit)
SpaDES.core::inputs(castorInit)
SpaDES.core::outputs(castorInit)
SpaDES.core::moduleDiagram(castorInit)
SpaDES.core::objectDiagram(castorInit)
SpaDES.core::times(castorInit)

## scheduled events - only init events have been scheduled by simInit
SpaDES.core::events(castorInit)

## run simulation
castorSim <- SpaDES.core::spades(castorInit)

## we now have outputs
SpaDES.core::outputs(castorSim)

## completed events -- or the full (emergent) workflow
SpaDES.core::completed(castorSim)
