# 05 - Exam Results Dashboard

An exam dashboard built from a CSV in the shape of a risr/assess export.
Simulated data, so no system access needed.

```
app.R              wiring only - two tabs, two modules
R/data.R           loads the CSV and derives every table shown
R/mod_cohort.R     cohort tab: summary, score histogram, flagged questions
R/mod_candidate.R  candidate tab: one candidate across all ten stations
generate_data.R    makes the fake export (base R, no packages)
data/results.csv   6,000 rows: 120 candidates x 10 stations x 5 questions
```

Columns: `candidate_id`, `station`, `question_id`, `score` (0-4), `max_score`,
`examiner_id`. Pass mark is 50%.

A question is flagged when its facility sits more than one standard deviation
below the paper's average - too hard or badly worded, rather than badly
answered. `generate_data.R` spikes `S07-Q3` so there is always one to find.

```sh
Rscript -e 'shiny::runApp(".", port = 8080, launch.browser = FALSE)'
```

Use `runApp()`, not `Rscript app.R`, which would skip the `R/` folder.
