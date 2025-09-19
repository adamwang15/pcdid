
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Principal Components Difference-in-Differences

<!-- badges: start -->

<!-- badges: end -->

pcdid implements factor-augmented difference-in-differences (DID)
estimation. It is useful in situations where the user suspects that
trends may be unparallel and/or stochastic among control and treated
units. The data structure is similar to that in a DID setup.

The estimation method is regression-based and can be considered as an
extension of conventional DID regressions. pcdid also implements a
parallel trend alpha test (based on an interactive effects structure)
and a recursive procedure that determines the number of factors
automatically.

For further details, please see Chan and Kwok (2022) who developed the
pcdid approach and the alpha test.

## Installation

You can install the released version of pcdid from CRAN with:

``` r
install.packages("pcdid")
```

You can install the development version of pcdid from
[GitHub](https://github.com/) with:

``` r
devtools::install_github("adamwang15/pcdid")
```

## Example

This is a basic example which replicates Chan and Kwok (2022)

``` r
library(pcdid)

result <- pcdid(
  lncase ~ treated + treated_post + afdcben + unemp + empratio + mon_d2 + mon_d3 + mon_d4,
  index = c("state", "trend"),
  data = welfare,
  alpha = TRUE
)
```

To access the mean-group estimates

``` r
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

To access the alpha test result

``` r
result$alpha
#> 
#> z test of coefficients:
#> 
#>       Estimate Std. Error z value  Pr(>|z|)    
#> alpha  0.99183    0.13754  7.2111 5.552e-13 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

To access an individual treated unit estimate

``` r
result$treated$WY$coefficients
#> 
#> t test of coefficients:
#> 
#>                Estimate Std. Error  t value  Pr(>|t|)    
#> (Intercept)  -4.5588646  0.2935291 -15.5312 < 2.2e-16 ***
#> treated_post -0.1142959  0.0280812  -4.0702 9.121e-05 ***
#> afdcben      -0.0096464  0.0194555  -0.4958 0.6210599    
#> unemp        -0.0303034  0.0078223  -3.8740 0.0001866 ***
#> empratio     -0.6215301  0.3450325  -1.8014 0.0745152 .  
#> mon_d2       -0.0185256  0.0129566  -1.4298 0.1557394    
#> mon_d3       -0.0613559  0.0165974  -3.6967 0.0003492 ***
#> mon_d4       -0.0743271  0.0167155  -4.4466 2.174e-05 ***
#> fproxy1       2.7033131  0.4950210   5.4610 3.195e-07 ***
#> fproxy2      -4.8730998  1.1297026  -4.3136 3.640e-05 ***
#> fproxy3       0.0068711  1.1667167   0.0059 0.9953122    
#> fproxy4      -4.8867753  2.7304968  -1.7897 0.0763845 .  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

To access an individual control unit estimate

``` r
result$control$OH$coefficients
#> 
#> t test of coefficients:
#> 
#>               Estimate Std. Error  t value  Pr(>|t|)    
#> (Intercept) -4.1981999  0.1119283 -37.5079 < 2.2e-16 ***
#> afdcben      0.0333233  0.0051964   6.4127 4.068e-09 ***
#> unemp        0.0482666  0.0055919   8.6315 6.645e-14 ***
#> empratio     0.5510229  0.1854242   2.9717  0.003665 ** 
#> mon_d2       0.0275807  0.0054598   5.0516 1.836e-06 ***
#> mon_d3       0.0553877  0.0071581   7.7377 6.249e-12 ***
#> mon_d4       0.0357344  0.0061858   5.7769 7.701e-08 ***
#> fproxy1     -4.5719351  0.1996360 -22.9014 < 2.2e-16 ***
#> fproxy2     -8.1910637  0.8168225 -10.0280 < 2.2e-16 ***
#> fproxy3     10.9875132  0.7484328  14.6807 < 2.2e-16 ***
#> fproxy4     -1.0994630  0.8806680  -1.2484  0.214620    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```
