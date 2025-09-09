#' @title Welfare caseloads data
#'
#' @description A sample data to examine the effects of welfare waiver programs on welfare caseloads in the United States.
#'
#' @usage data(welfare)
#'
#' @format A data frame
#' \describe{
#'   \item{state}{state name}
#'   \item{statenum}{state id}
#'   \item{trend}{time trend}
#'   \item{treated}{1 if the state is treated, 0 otherwise}
#'   \item{treated_post}{1 if the state is treated and time is after treatment, 0 otherwise}
#'   \item{lncase}{TODO}
#'   \item{afdcben}{TODO}
#'   \item{unemp}{unemployment rate}
#'   \item{empratio}{employment ratio}
#'   \item{mon_d2}{seasonal dummies}
#'   \item{mon_d3}{seasonal dummies}
#'   \item{mon_d4}{seasonal dummies}
#'   \item{caseload}{welfare caseload}
#'   \item{popn}{population}
#'   \item{empratio_raw}{raw employment ratio}
#'   \item{south}{1 if the state is in the south, 0 otherwise}
#'   \item{control}{1 if the state is a control unit, 0 otherwise}
#'   \item{T0}{time period before treatment}
#' }
#'
#' @references
#' Chan, M. K., & Kwok, S. S. (2022). The PCDID approach: difference-in-differences when trends are potentially unparallel and stochastic. Journal of Business & Economic Statistics, 40(3), 1216-1233.
#'
#' @source
#' Supplemental material, \url{https://doi.org/10.1080/07350015.2021.1914636}
"welfare"
