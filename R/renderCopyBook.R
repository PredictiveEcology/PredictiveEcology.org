## render book
#
#
# files <- system(paste0("git diff --name-only -- . "), intern=T) %>%
#   grep(pattern = ".qmd$|\\.R$", value = TRUE)
#
# if(length(files) > 0){
#   for(f in files){
#     quarto::quarto_render(f, as_job = FALSE)
#   }
# }


if (identical(unname(Sys.info()["user"]), "emcintir"))
  setwd("~/GitHub/PredictiveEcology.org/")
message("Rendering book...")
# quarto::quarto_render("training/", as_job = FALSE, use_freezer = TRUE)
quarto::quarto_render(input = "training/RSFForecast.qmd", as_job = FALSE, use_freezer = TRUE)

## render website
message("Rendering website...")
# quarto::quarto_render(as_job = FALSE, use_freezer = TRUE)
# can do one file at a time
# quarto::quarto_render(input = "bios\\professional\\jonathan.qmd", as_job = FALSE, use_freezer = TRUE)

## now copy book HTMLs to docs/ (always *after* rendering site)
message("Copying book files over to website")
bookFiles <- list.files("training/_book/", recursive = TRUE, full.names = TRUE)
bookFilesCopy <- sub("training/_book", "docs/training/_book", bookFiles)
bookFilesDirs <- dirname(bookFilesCopy)

sapply(bookFilesDirs, dir.create, recursive = TRUE, showWarnings = FALSE)
file.copy(bookFiles, bookFilesCopy, overwrite = TRUE)

## render the chapter slide decks into docs/slides (after the site render,
## so the site render's cleanup cannot orphan them). Each deck's project
## (training/slides/_quarto.yml) sends its output to docs/slides.
message("Rendering slide decks")
slideDecks <- list.files("training/slides", pattern = "-slides\\.qmd$", full.names = TRUE)
for (deck in slideDecks) quarto::quarto_render(deck, as_job = FALSE)
