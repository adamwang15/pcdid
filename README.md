
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
#> (Intercept) -4.4479234  0.1807386 -24.6097 < 2.2e-16 ***
#> afdcben      0.0285303  0.0192942   1.4787 0.1421858    
#> unemp        0.0081524  0.0054983   1.4827 0.1411130    
#> empratio    -0.1281184  0.3381070  -0.3789 0.7054989    
#> mon_d2       0.0217046  0.0104066   2.0857 0.0394098 *  
#> mon_d3       0.0372120  0.0102360   3.6354 0.0004301 ***
#> mon_d4       0.0029270  0.0090809   0.3223 0.7478383    
#> fproxy1     -4.1339209  0.2866713 -14.4204 < 2.2e-16 ***
#> fproxy2     -6.1163076  1.4065816  -4.3483 3.162e-05 ***
#> fproxy3     11.6217469  1.7301763   6.7171 9.528e-10 ***
#> fproxy4     -0.9188375  0.9971030  -0.9215 0.3588783    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```
