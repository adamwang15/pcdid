
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Principal Components Difference-in-Differences

<!-- badges: start -->

<!-- badges: end -->

The goal of pcdid is to …

## Installation

You can install the development version of pcdid from
[GitHub](https://github.com/) with:

``` r
devtools::install_github("adamwang15/pcdid")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(pcdid)

# replicates Chan, M. K., & Kwok, S. S. (2022)
result <- pcdid(
  lncase ~ treated + treated_post + afdcben + unemp + empratio + mon_d2 + mon_d3 + mon_d4,
  index = c("state", "trend"),
  data = welfare,
  alpha = TRUE
)

# mean-group estimates
result$mg
#> 
#> z test of coefficients:
#> 
#>                Estimate Std. Error  z value  Pr(>|z|)    
#> (Intercept)  -4.4556629  0.0878986 -50.6909 < 2.2e-16 ***
#> treated_post -0.0168484  0.0071048  -2.3714   0.01772 *  
#> afdcben       0.0143423  0.0075024   1.9117   0.05591 .  
#> unemp         0.0206647  0.0035431   5.8324 5.465e-09 ***
#> empratio      0.0579939  0.1285858   0.4510   0.65198    
#> mon_d2        0.0261549  0.0037348   7.0031 2.504e-12 ***
#> mon_d3        0.0238558  0.0049483   4.8210 1.429e-06 ***
#> mon_d4        0.0103690  0.0042303   2.4511   0.01424 *  
#> fproxy1       3.1685663  0.5606270   5.6518 1.588e-08 ***
#> fproxy2      -2.2785399  0.5683153  -4.0093 6.090e-05 ***
#> fproxy3       1.7287098  0.7313678   2.3637   0.01810 *  
#> fproxy4      -3.1723206  0.6918360  -4.5854 4.532e-06 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```
