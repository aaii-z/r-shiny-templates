# Loaded automatically from R/ before app.R runs.

PASS_MARK <- 50   # percent of a station's marks needed to pass

results    <- read.csv("data/results.csv")
stations   <- sort(unique(results$station))
candidates <- sort(unique(results$candidate_id))

# 6,000 question rows become one row per candidate per station.
station_scores <- aggregate(cbind(score, max_score) ~ candidate_id + station,
                            data = results, FUN = sum)
station_scores$percent <- 100 * station_scores$score / station_scores$max_score
station_scores$passed  <- station_scores$percent >= PASS_MARK

# Facility: the share of available marks the cohort actually earned.
question_stats <- aggregate(score ~ question_id + station, data = results, FUN = mean)
names(question_stats)[names(question_stats) == "score"] <- "mean_score"
question_stats$facility <- 100 * question_stats$mean_score / max(results$max_score)

# A question is flagged when it was more than one SD harder than the paper.
flagged_questions <- question_stats[
  question_stats$facility < mean(question_stats$facility) - sd(question_stats$facility), ]
flagged_questions <- flagged_questions[order(flagged_questions$facility), ]


# One summary row per station, for any subset of station_scores.
summarise_stations <- function(scores) {
  do.call(rbind, lapply(split(scores, scores$station), function(rows) data.frame(
    Station       = rows$station[1],
    Candidates    = nrow(rows),
    `Mean %`      = mean(rows$percent),
    `Lowest %`    = min(rows$percent),
    `Highest %`   = max(rows$percent),
    `Pass rate %` = 100 * mean(rows$passed),
    check.names   = FALSE
  )))
}
