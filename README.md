# R Shiny templates

Five Shiny apps, smallest first. Each adds one idea to the one before it.

1. **[01 Hello Reactive](01-hello-reactive)** - two sliders and a histogram, no data files.
2. **[02 CSV Explorer](02-csv-explorer)** - loads a CSV once and filters it from the sidebar.
3. **[03 Upload & Report](03-upload-report)** - the user uploads a CSV and downloads a summary.
4. **[04 Dashboard](04-dashboard)** - tabs, value boxes, and a plot click that selects a chick.
5. **[05 Exam Results](05-exam-results)** - an exam dashboard split into `R/` files and modules.

Run any of them:

```sh
cd 01-hello-reactive
Rscript -e 'shiny::runApp(".", port = 8080, launch.browser = FALSE)'
```

Needs `shiny`, plus `bslib` for 04. Everything else is base R.
