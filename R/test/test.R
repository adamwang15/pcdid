devtools::load_all(".")

result <- pcdid(
  # lncase ~ treated + treated_post + afdcben + unemp + empratio + mon_d2 + mon_d3 + mon_d4,
  lncase ~ treated + treated_post + empratio + mon_d2 + mon_d3 + mon_d4,
  index = c("state", "trend"),
  data = welfare,
  alpha = TRUE,
  fproxy = 4
)

result$alpha
result$mg
