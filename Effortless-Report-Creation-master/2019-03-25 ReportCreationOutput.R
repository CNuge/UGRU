##############################
## Effortless report generation: Different output options
##
## Karl Cottenie
##
## 2019-04-01
##
##############################

library(rmarkdown)
library(prettydoc)

# Startup ends here

## Comment codes ------
# Coding explanations (#, often after the code, but not exclusively)
# Code organization (## XXXXX -----)
# Justification for a section of code ## XXX
# Dead end analyses because it did not work, or not pursuing this line of inquiry (but leave it in as a trace of it, to potentially solve this issue, or avoid making the same mistake in the future # (>_<) 
# Solutions/results/interpretations (#==> XXX)
# Reference to manuscript pieces, figures, results, tables, ... # (*_*)
# TODO items #TODO
# names for data frames (dfName), for lists (lsName), for vectors (vcName) (Thanks Jacqueline May)

# Code adapted from 
# https://jozefhajnala.gitlab.io/r/r913-spin-with-style/

## _ Default option to create multiple different output reports -----

## __ Produce a default html output with rmarkdown::render -----
rmarkdown::render(
  "2019-03-25 ReportCreationExample.R",
  output_file = "./output/ex_01_render_default.html"
)

## __ Produce a minimal html output with rmarkdown::render for comparison -----
rmarkdown::render(
  "2019-03-25 ReportCreationExample.R",
  output_format =  rmarkdown::html_document(
    theme = NULL, mathjax = NULL, highlight = NULL
  ),
  output_file = "./output/ex_02_render_minimalish.html"
)

## __ Produce html output with custom css, with external dependency ----
rmarkdown::render(
  "2019-03-25 ReportCreationExample.R",
  output_format =  rmarkdown::html_document(
    theme = NULL, mathjax = NULL, highlight = NULL,
    css = "./css/rmarkdown_spin_css_air.css"
  ),
  output_file = "./output/ex_03_render_air_css.html"
)
#==> This is again getting complicated

## __ other html_document themes -----
# see help file for full list of available themes
rmarkdown::render(
  "2019-03-25 ReportCreationExample.R",
  output_format =  rmarkdown::html_document(
    theme = "journal", mathjax = NULL, highlight = NULL
  ),
  output_file = "./output/ex_04_render_journal.html"
)

rmarkdown::render(
  "2019-03-25 ReportCreationExample.R",
  output_format =  rmarkdown::html_document(
    theme = "yeti", mathjax = NULL, highlight = NULL
  ),
  output_file = "./output/ex_05_render_yeti.html"
)

## _ Lightweight  option for html files with library prettydoc -----
# check help file for all available themes
rmarkdown::render(
  "2019-03-25 ReportCreationExample.R",
  output_format =  prettydoc::html_pretty(
    theme = "cayman"
  ),
  output_file = "./output/ex_07_render_cayman.html"
)

## _ Final piece of the puzzle: a snippet to almost automate it ----

snippet cayman
  rmarkdown::render(
  "${1:file.R}",
  output_format =  prettydoc::html_pretty(
    theme = "cayman"
  ),
  output_file = "./output/${1:file}.html"
  )
  
## Notes
# copy the above code to the snippets section in global options
# make sure that each line after the snippet line starts with a tab
# I use cayman as default theme, but you can change that based on code above
# also by default same name for html as the script file name
# but you can change that of course too.

# usage: type "cayman" in console, snippet will appear, type file name, enter
