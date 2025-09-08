test_that("multiplication works", {
  result <- pcdid(
    lncase ~ treated + treated_post + afdcben + unemp + empratio + mon_d2 + mon_d3 + mon_d4,
    index = c("state", "trend"),
    data = welfare,
    alpha = TRUE
  )
  expect_equal(class(result), "pcdid")
})
