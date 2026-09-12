# Makes a fake exam export, in the same shape risr/assess would give you.
# Base R only. Run with:  Rscript generate_data.R

set.seed(42)   # same fake data every time, so the demo never changes

# ---- what the exam looks like ---------------------------------------------

stations <- c("01 History Taking", "02 Cardio Exam", "03 Resp Exam",
              "04 Abdo Exam",      "05 Neuro Exam",  "06 Communication",
              "07 Prescribing",    "08 Data Interp", "09 Practical Skills",
              "10 Ethics")

candidates         <- sprintf("C%04d", 1:120)   # C0001 ... C0120
questions_per_station <- 5
marks_per_question    <- 4

# ---- one row for every candidate, station and question --------------------

exam <- expand.grid(candidate_id = candidates,
                    station      = stations,
                    question_no  = 1:questions_per_station,
                    stringsAsFactors = FALSE)

station_number   <- match(exam$station, stations)          # "07 Prescribing" -> 7
exam$question_id <- sprintf("S%02d-Q%d", station_number, exam$question_no)

# ---- decide how well each candidate does ----------------------------------

# Every candidate has a hidden ability, every question a hidden difficulty.
# Good candidates score higher; hard questions pull everyone down.

candidate_ability   <- rnorm(length(candidates), mean = 0, sd = 0.9)
names(candidate_ability) <- candidates

all_questions       <- sort(unique(exam$question_id))
question_difficulty <- rnorm(length(all_questions), mean = 0, sd = 0.5)
names(question_difficulty) <- all_questions

# Make one question much too hard, so the app's flagging has something to find.
question_difficulty["S07-Q3"] <- 2.5

# For each row: this candidate's ability, minus this question's difficulty,
# plus a bit of luck (good candidates still have off days).
ability_here    <- candidate_ability[exam$candidate_id]
difficulty_here <- question_difficulty[exam$question_id]
luck            <- rnorm(nrow(exam), mean = 0, sd = 0.6)

performance <- ability_here - difficulty_here + luck

# Turn that into a chance of earning each mark (always between 0 and 1),
# then draw an actual score out of 4.
chance_of_mark <- 1 / (1 + exp(-performance))
exam$score     <- rbinom(nrow(exam), size = marks_per_question, prob = chance_of_mark)

exam$max_score   <- marks_per_question
exam$examiner_id <- sprintf("E%02d", sample(12, nrow(exam), replace = TRUE))

# ---- save -----------------------------------------------------------------

exam <- exam[order(exam$candidate_id, exam$question_id), ]
exam <- exam[, c("candidate_id", "station", "question_id",
                 "score", "max_score", "examiner_id")]

dir.create("data", showWarnings = FALSE)
write.csv(exam, "data/results.csv", row.names = FALSE)
cat("Wrote data/results.csv:", nrow(exam), "rows\n")
