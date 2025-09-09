
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

To access list of treated unit estimates

``` r
result$treated
#> $AZ
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.063325 -0.021743  0.000838  0.021600  0.069362 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.398308   0.244411 -17.996  < 2e-16 ***
#> treated_post -0.001961   0.018023  -0.109  0.91358    
#> afdcben      -0.019020   0.011489  -1.655  0.10082    
#> unemp         0.024112   0.005590   4.314 3.64e-05 ***
#> empratio      0.133500   0.276075   0.484  0.62970    
#> mon_d2        0.028559   0.008534   3.347  0.00114 ** 
#> mon_d3        0.030536   0.011022   2.770  0.00662 ** 
#> mon_d4        0.018986   0.008588   2.211  0.02923 *  
#> fproxy1       8.680011   0.249930  34.730  < 2e-16 ***
#> fproxy2      -4.979666   0.825917  -6.029 2.49e-08 ***
#> fproxy3      -8.168583   0.997150  -8.192 6.63e-13 ***
#> fproxy4      -8.683408   0.952461  -9.117 5.86e-15 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02979 on 105 degrees of freedom
#> Multiple R-squared:  0.9839, Adjusted R-squared:  0.9822 
#> F-statistic: 581.5 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $CA
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.031465 -0.007817  0.001092  0.010499  0.032054 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -3.423010   0.114275 -29.954  < 2e-16 ***
#> treated_post -0.018133   0.007246  -2.503 0.013869 *  
#> afdcben       0.013015   0.004730   2.751 0.006991 ** 
#> unemp         0.025586   0.004694   5.451 3.34e-07 ***
#> empratio      0.792662   0.187878   4.219 5.22e-05 ***
#> mon_d2        0.024288   0.004509   5.387 4.41e-07 ***
#> mon_d3        0.012028   0.006025   1.996 0.048471 *  
#> mon_d4        0.011924   0.004350   2.741 0.007203 ** 
#> fproxy1       4.302381   0.204772  21.011  < 2e-16 ***
#> fproxy2       2.776305   0.357663   7.762 5.78e-12 ***
#> fproxy3       3.084868   0.572071   5.392 4.31e-07 ***
#> fproxy4      -2.939253   0.784179  -3.748 0.000292 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01379 on 105 degrees of freedom
#> Multiple R-squared:  0.9903, Adjusted R-squared:  0.9892 
#> F-statistic: 970.5 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $CT
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.075852 -0.016796  0.003806  0.015072  0.068094 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -3.817950   0.186200 -20.505  < 2e-16 ***
#> treated_post  0.058474   0.010956   5.337 5.48e-07 ***
#> afdcben       0.012224   0.008409   1.454  0.14902    
#> unemp         0.040377   0.007994   5.051 1.86e-06 ***
#> empratio      0.993748   0.215218   4.617 1.11e-05 ***
#> mon_d2        0.026364   0.009561   2.757  0.00687 ** 
#> mon_d3        0.017718   0.012237   1.448  0.15063    
#> mon_d4        0.030011   0.009177   3.270  0.00145 ** 
#> fproxy1       7.198234   0.453208  15.883  < 2e-16 ***
#> fproxy2       2.268457   0.553900   4.095 8.31e-05 ***
#> fproxy3       1.813304   1.217699   1.489  0.13945    
#> fproxy4      -3.605816   1.638478  -2.201  0.02995 *  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02634 on 105 degrees of freedom
#> Multiple R-squared:  0.9877, Adjusted R-squared:  0.9864 
#> F-statistic: 766.2 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $DE
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.053414 -0.018765 -0.001793  0.015125  0.060194 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.794943   0.156739 -30.592  < 2e-16 ***
#> treated_post -0.037785   0.023988  -1.575 0.118221    
#> afdcben      -0.031862   0.016334  -1.951 0.053769 .  
#> unemp         0.001054   0.007980   0.132 0.895211    
#> empratio     -0.859523   0.257053  -3.344 0.001147 ** 
#> mon_d2        0.034591   0.009032   3.830 0.000219 ***
#> mon_d3        0.038871   0.008276   4.697 8.03e-06 ***
#> mon_d4        0.022728   0.009296   2.445 0.016154 *  
#> fproxy1       4.711657   0.396250  11.891  < 2e-16 ***
#> fproxy2       0.481882   0.930820   0.518 0.605760    
#> fproxy3       3.183039   1.223184   2.602 0.010599 *  
#> fproxy4      -7.860545   0.739352 -10.632  < 2e-16 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02431 on 105 degrees of freedom
#> Multiple R-squared:  0.9626, Adjusted R-squared:  0.9587 
#> F-statistic: 245.9 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $GA
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>      Min       1Q   Median       3Q      Max 
#> -0.03915 -0.01076 -0.00098  0.01119  0.05886 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.969647   0.244103 -20.359  < 2e-16 ***
#> treated_post -0.031127   0.010422  -2.987 0.003511 ** 
#> afdcben       0.106651   0.028067   3.800 0.000243 ***
#> unemp         0.002532   0.004262   0.594 0.553723    
#> empratio     -0.307634   0.274235  -1.122 0.264511    
#> mon_d2        0.032736   0.005456   6.000 2.84e-08 ***
#> mon_d3        0.036978   0.006190   5.974 3.20e-08 ***
#> mon_d4        0.006250   0.005628   1.111 0.269279    
#> fproxy1       3.429095   0.452627   7.576 1.47e-11 ***
#> fproxy2      -2.765418   0.366193  -7.552 1.65e-11 ***
#> fproxy3       1.993335   1.030551   1.934 0.055775 .  
#> fproxy4      -7.232951   0.827834  -8.737 4.12e-14 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01822 on 105 degrees of freedom
#> Multiple R-squared:  0.981,  Adjusted R-squared:  0.979 
#> F-statistic: 491.9 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $HI
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.035087 -0.010087 -0.002049  0.011908  0.040617 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.998652   0.125886 -39.708  < 2e-16 ***
#> treated_post -0.016483   0.013218  -1.247 0.215162    
#> afdcben       0.000663   0.001453   0.456 0.649188    
#> unemp         0.008367   0.004635   1.805 0.073922 .  
#> empratio     -0.930688   0.168235  -5.532 2.34e-07 ***
#> mon_d2        0.013241   0.004933   2.684 0.008453 ** 
#> mon_d3        0.021577   0.005844   3.692 0.000355 ***
#> mon_d4        0.020282   0.004606   4.404 2.57e-05 ***
#> fproxy1       5.650573   0.306484  18.437  < 2e-16 ***
#> fproxy2       5.722411   0.587246   9.744 2.30e-16 ***
#> fproxy3       1.245777   0.769471   1.619 0.108446    
#> fproxy4      -3.700094   0.661027  -5.597 1.75e-07 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01553 on 105 degrees of freedom
#> Multiple R-squared:  0.9912, Adjusted R-squared:  0.9903 
#> F-statistic:  1079 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $IA
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.075323 -0.010874  0.000305  0.011137  0.068408 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.696568   0.111259 -42.213  < 2e-16 ***
#> treated_post  0.071632   0.018494   3.873 0.000187 ***
#> afdcben       0.004599   0.010921   0.421 0.674510    
#> unemp         0.017573   0.007375   2.383 0.018983 *  
#> empratio     -0.326863   0.120969  -2.702 0.008038 ** 
#> mon_d2        0.035330   0.006654   5.310 6.18e-07 ***
#> mon_d3        0.038327   0.009699   3.952 0.000141 ***
#> mon_d4        0.017487   0.008501   2.057 0.042146 *  
#> fproxy1      -0.676043   0.241328  -2.801 0.006060 ** 
#> fproxy2      -2.810535   0.838017  -3.354 0.001110 ** 
#> fproxy3       8.041883   0.578607  13.899  < 2e-16 ***
#> fproxy4      -0.393093   0.808606  -0.486 0.627884    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.0185 on 105 degrees of freedom
#> Multiple R-squared:  0.9025, Adjusted R-squared:  0.8923 
#> F-statistic: 88.35 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $IL
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.036116 -0.009604 -0.000172  0.011802  0.034718 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.702226   0.119531 -39.339  < 2e-16 ***
#> treated_post -0.059012   0.016596  -3.556 0.000567 ***
#> afdcben      -0.008293   0.005892  -1.407 0.162270    
#> unemp         0.002363   0.002708   0.873 0.384810    
#> empratio     -1.052987   0.166259  -6.333 6.06e-09 ***
#> mon_d2        0.027827   0.005297   5.253 7.89e-07 ***
#> mon_d3        0.028035   0.006394   4.385 2.77e-05 ***
#> mon_d4        0.021551   0.005011   4.300 3.83e-05 ***
#> fproxy1       1.136612   0.127998   8.880 1.98e-14 ***
#> fproxy2       2.695721   0.560507   4.809 5.08e-06 ***
#> fproxy3       3.031895   0.836574   3.624 0.000449 ***
#> fproxy4      -2.302771   0.590624  -3.899 0.000171 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01551 on 105 degrees of freedom
#> Multiple R-squared:  0.9032, Adjusted R-squared:  0.8931 
#> F-statistic: 89.11 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $IN
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.066055 -0.024296 -0.000833  0.019558  0.074010 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.68926    0.21398 -21.914  < 2e-16 ***
#> treated_post -0.07385    0.03014  -2.451 0.015912 *  
#> afdcben       0.04805    0.02645   1.817 0.072145 .  
#> unemp         0.05286    0.01406   3.759 0.000281 ***
#> empratio      0.56028    0.32994   1.698 0.092451 .  
#> mon_d2        0.03194    0.01108   2.883 0.004775 ** 
#> mon_d3        0.04395    0.01230   3.572 0.000537 ***
#> mon_d4        0.01844    0.01182   1.560 0.121751    
#> fproxy1       4.10073    0.30332  13.519  < 2e-16 ***
#> fproxy2      -4.82829    1.28581  -3.755 0.000285 ***
#> fproxy3       5.31456    0.97703   5.440 3.51e-07 ***
#> fproxy4      -0.04507    1.70055  -0.027 0.978907    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.03258 on 105 degrees of freedom
#> Multiple R-squared:  0.9387, Adjusted R-squared:  0.9323 
#> F-statistic: 146.2 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $LA
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.049988 -0.007772  0.000275  0.006944  0.040917 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -3.952878   0.179659 -22.002  < 2e-16 ***
#> treated_post -0.046340   0.010646  -4.353 3.13e-05 ***
#> afdcben       0.003436   0.029719   0.116  0.90817    
#> unemp         0.007082   0.001823   3.884  0.00018 ***
#> empratio     -0.033984   0.081810  -0.415  0.67870    
#> mon_d2       -0.009996   0.004347  -2.299  0.02346 *  
#> mon_d3       -0.012053   0.004849  -2.486  0.01451 *  
#> mon_d4       -0.006185   0.005577  -1.109  0.26994    
#> fproxy1      -0.664093   0.261407  -2.540  0.01253 *  
#> fproxy2      -6.711926   0.244882 -27.409  < 2e-16 ***
#> fproxy3      -4.257259   0.458560  -9.284 2.48e-15 ***
#> fproxy4       4.141343   0.439328   9.427 1.19e-15 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01262 on 105 degrees of freedom
#> Multiple R-squared:  0.9802, Adjusted R-squared:  0.9782 
#> F-statistic: 473.3 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $MA
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.041563 -0.011131 -0.000337  0.009471  0.046449 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -3.920951   0.149772 -26.179  < 2e-16 ***
#> treated_post -0.047566   0.016386  -2.903  0.00451 ** 
#> afdcben      -0.011858   0.006811  -1.741  0.08464 .  
#> unemp         0.030730   0.003479   8.834 2.51e-14 ***
#> empratio      0.399996   0.245275   1.631  0.10593    
#> mon_d2        0.023802   0.004755   5.006 2.25e-06 ***
#> mon_d3        0.032903   0.006414   5.130 1.33e-06 ***
#> mon_d4        0.041331   0.004821   8.573 9.51e-14 ***
#> fproxy1       3.353613   0.191544  17.508  < 2e-16 ***
#> fproxy2      -0.653968   0.642347  -1.018  0.31097    
#> fproxy3       3.146405   0.910172   3.457  0.00079 ***
#> fproxy4      -2.177247   0.914149  -2.382  0.01903 *  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01767 on 105 degrees of freedom
#> Multiple R-squared:  0.9823, Adjusted R-squared:  0.9804 
#> F-statistic: 529.3 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $MI
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.039995 -0.013562 -0.000396  0.009951  0.061728 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.088155   0.185413 -22.049  < 2e-16 ***
#> treated_post  0.028536   0.021865   1.305 0.194726    
#> afdcben      -0.012720   0.018100  -0.703 0.483765    
#> unemp         0.012731   0.005100   2.497 0.014096 *  
#> empratio     -0.348154   0.316664  -1.099 0.274089    
#> mon_d2        0.013046   0.006304   2.069 0.040967 *  
#> mon_d3        0.006762   0.007064   0.957 0.340661    
#> mon_d4        0.008202   0.008562   0.958 0.340253    
#> fproxy1      -0.642011   0.380667  -1.687 0.094661 .  
#> fproxy2      -4.328015   1.090464  -3.969 0.000132 ***
#> fproxy3       2.652973   0.801358   3.311 0.001277 ** 
#> fproxy4       2.323768   1.226626   1.894 0.060918 .  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02038 on 105 degrees of freedom
#> Multiple R-squared:  0.934,  Adjusted R-squared:  0.927 
#> F-statistic:   135 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $MO
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.027024 -0.009768  0.000466  0.008135  0.026292 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.138758   0.127946 -32.348  < 2e-16 ***
#> treated_post -0.013070   0.009712  -1.346 0.181300    
#> afdcben       0.020769   0.007938   2.617 0.010192 *  
#> unemp         0.014045   0.002967   4.734 6.91e-06 ***
#> empratio      0.346794   0.152919   2.268 0.025387 *  
#> mon_d2        0.016992   0.004853   3.502 0.000681 ***
#> mon_d3        0.018476   0.005071   3.644 0.000420 ***
#> mon_d4        0.003618   0.004647   0.779 0.437997    
#> fproxy1       4.109846   0.074084  55.475  < 2e-16 ***
#> fproxy2      -1.995740   0.297150  -6.716 9.85e-10 ***
#> fproxy3       2.866180   0.339404   8.445 1.83e-13 ***
#> fproxy4      -3.351360   0.352880  -9.497 8.24e-16 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01281 on 105 degrees of freedom
#> Multiple R-squared:  0.9861, Adjusted R-squared:  0.9846 
#> F-statistic: 675.6 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $MT
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.040309 -0.009826  0.001112  0.008909  0.103324 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.199064   0.114506 -36.671  < 2e-16 ***
#> treated_post  0.018040   0.007466   2.416 0.017409 *  
#> afdcben       0.007613   0.004483   1.698 0.092398 .  
#> unemp         0.019037   0.004955   3.842 0.000209 ***
#> empratio      0.430577   0.170577   2.524 0.013092 *  
#> mon_d2        0.016912   0.006987   2.421 0.017213 *  
#> mon_d3       -0.007295   0.010206  -0.715 0.476324    
#> mon_d4       -0.023947   0.004960  -4.828 4.71e-06 ***
#> fproxy1       1.982871   0.160633  12.344  < 2e-16 ***
#> fproxy2      -3.072033   0.463529  -6.627 1.51e-09 ***
#> fproxy3       1.577143   0.404986   3.894 0.000173 ***
#> fproxy4       1.003124   0.846520   1.185 0.238694    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01761 on 105 degrees of freedom
#> Multiple R-squared:  0.918,  Adjusted R-squared:  0.9094 
#> F-statistic: 106.8 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $NC
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.054215 -0.013982  0.000415  0.016103  0.051638 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.353645   0.180606 -24.106  < 2e-16 ***
#> treated_post -0.038922   0.015207  -2.560  0.01190 *  
#> afdcben       0.036614   0.020294   1.804  0.07406 .  
#> unemp         0.049682   0.005460   9.099 6.43e-15 ***
#> empratio      0.471424   0.245661   1.919  0.05770 .  
#> mon_d2        0.039002   0.006110   6.383 4.79e-09 ***
#> mon_d3        0.037649   0.008725   4.315 3.62e-05 ***
#> mon_d4        0.020291   0.006948   2.920  0.00428 ** 
#> fproxy1       7.578457   0.205003  36.968  < 2e-16 ***
#> fproxy2      -3.856593   0.658640  -5.855 5.50e-08 ***
#> fproxy3      -2.079066   0.787993  -2.638  0.00960 ** 
#> fproxy4      -1.337172   1.524759  -0.877  0.38250    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02208 on 105 degrees of freedom
#> Multiple R-squared:  0.9895, Adjusted R-squared:  0.9885 
#> F-statistic: 903.8 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $ND
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.047886 -0.013630  0.000403  0.015590  0.052067 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.945822   0.155760 -31.753  < 2e-16 ***
#> treated_post  0.035968   0.013626   2.640 0.009563 ** 
#> afdcben      -0.015345   0.007885  -1.946 0.054334 .  
#> unemp         0.035281   0.005048   6.990 2.63e-10 ***
#> empratio     -0.200954   0.194942  -1.031 0.304985    
#> mon_d2        0.043997   0.012766   3.446 0.000818 ***
#> mon_d3        0.041693   0.016003   2.605 0.010509 *  
#> mon_d4        0.019736   0.009045   2.182 0.031352 *  
#> fproxy1       3.412854   0.246873  13.824  < 2e-16 ***
#> fproxy2      -5.513596   0.770168  -7.159 1.15e-10 ***
#> fproxy3      -5.783969   0.605865  -9.547 6.38e-16 ***
#> fproxy4      -1.061996   1.165049  -0.912 0.364096    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02278 on 105 degrees of freedom
#> Multiple R-squared:  0.9615, Adjusted R-squared:  0.9575 
#> F-statistic: 238.5 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $NE
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.056615 -0.013338 -0.001237  0.011744  0.049397 
#> 
#> Coefficients:
#>                Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.400e+00  1.915e-01 -22.983  < 2e-16 ***
#> treated_post -1.041e-02  1.197e-02  -0.869 0.386593    
#> afdcben      -2.695e-02  1.055e-02  -2.554 0.012078 *  
#> unemp         2.088e-02  8.360e-03   2.497 0.014062 *  
#> empratio      2.989e-01  2.379e-01   1.256 0.211773    
#> mon_d2        3.083e-02  8.129e-03   3.793 0.000249 ***
#> mon_d3        2.262e-02  8.927e-03   2.534 0.012748 *  
#> mon_d4        1.071e-05  8.260e-03   0.001 0.998968    
#> fproxy1       5.280e-01  2.608e-01   2.025 0.045429 *  
#> fproxy2      -2.769e+00  8.563e-01  -3.234 0.001633 ** 
#> fproxy3       3.053e+00  1.071e+00   2.851 0.005245 ** 
#> fproxy4      -6.556e+00  8.515e-01  -7.699 7.93e-12 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02179 on 105 degrees of freedom
#> Multiple R-squared:  0.8948, Adjusted R-squared:  0.8838 
#> F-statistic: 81.17 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $NH
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.121136 -0.021151  0.001434  0.029171  0.145136 
#> 
#> Coefficients:
#>                Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)   -4.073632   0.253916 -16.043  < 2e-16 ***
#> treated_post   0.004769   0.029211   0.163  0.87061    
#> afdcben       -0.014182   0.013902  -1.020  0.31000    
#> unemp          0.068873   0.013083   5.264 7.52e-07 ***
#> empratio       1.908820   0.312704   6.104 1.76e-08 ***
#> mon_d2         0.090562   0.012101   7.484 2.32e-11 ***
#> mon_d3         0.078550   0.014462   5.432 3.63e-07 ***
#> mon_d4         0.045298   0.016105   2.813  0.00587 ** 
#> fproxy1       13.437855   0.620649  21.651  < 2e-16 ***
#> fproxy2        2.625343   1.084456   2.421  0.01720 *  
#> fproxy3        0.138946   2.543275   0.055  0.95653    
#> fproxy4      -14.897389   3.140137  -4.744 6.63e-06 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.04641 on 105 degrees of freedom
#> Multiple R-squared:  0.9864, Adjusted R-squared:  0.985 
#> F-statistic: 694.2 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $NJ
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.080005 -0.014526 -0.000008  0.013875  0.061818 
#> 
#> Coefficients:
#>                Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.1503124  0.1976444 -20.999  < 2e-16 ***
#> treated_post -0.0195847  0.0264681  -0.740 0.460991    
#> afdcben       0.0001646  0.0079341   0.021 0.983488    
#> unemp         0.0196865  0.0112475   1.750 0.082988 .  
#> empratio      0.2451639  0.2826856   0.867 0.387773    
#> mon_d2        0.0392215  0.0096846   4.050 9.83e-05 ***
#> mon_d3        0.0354718  0.0101221   3.504 0.000674 ***
#> mon_d4        0.0222617  0.0077936   2.856 0.005166 ** 
#> fproxy1       1.6640808  0.5492663   3.030 0.003082 ** 
#> fproxy2      -0.8808730  0.5175045  -1.702 0.091685 .  
#> fproxy3       5.3532741  1.2068240   4.436 2.27e-05 ***
#> fproxy4      -6.7293405  1.7162377  -3.921 0.000158 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02548 on 105 degrees of freedom
#> Multiple R-squared:  0.8964, Adjusted R-squared:  0.8855 
#> F-statistic: 82.57 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $OH
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.034576 -0.008345 -0.000125  0.010227  0.036381 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -3.664131   0.120418 -30.428  < 2e-16 ***
#> treated_post  0.020673   0.011729   1.762 0.080903 .  
#> afdcben       0.029177   0.007751   3.764 0.000276 ***
#> unemp         0.032360   0.005043   6.417 4.10e-09 ***
#> empratio      0.693153   0.171347   4.045 0.000100 ***
#> mon_d2        0.023389   0.005454   4.289 4.00e-05 ***
#> mon_d3        0.028272   0.005764   4.905 3.42e-06 ***
#> mon_d4        0.009838   0.005161   1.906 0.059366 .  
#> fproxy1       0.815269   0.114034   7.149 1.21e-10 ***
#> fproxy2      -5.762147   0.516367 -11.159  < 2e-16 ***
#> fproxy3       4.948123   0.597165   8.286 4.11e-13 ***
#> fproxy4      -1.112906   0.868330  -1.282 0.202784    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01504 on 105 degrees of freedom
#> Multiple R-squared:  0.9561, Adjusted R-squared:  0.9515 
#> F-statistic: 208.1 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $OK
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.069195 -0.019703 -0.002388  0.016703  0.077490 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -5.196652   0.362981 -14.317  < 2e-16 ***
#> treated_post  0.007114   0.016708   0.426  0.67113    
#> afdcben       0.046038   0.016180   2.845  0.00534 ** 
#> unemp        -0.002638   0.010592  -0.249  0.80378    
#> empratio     -0.762605   0.514491  -1.482  0.14127    
#> mon_d2        0.022469   0.009996   2.248  0.02669 *  
#> mon_d3        0.024578   0.011387   2.158  0.03318 *  
#> mon_d4       -0.002512   0.011550  -0.218  0.82822    
#> fproxy1       3.924793   0.316670  12.394  < 2e-16 ***
#> fproxy2      -6.263330   0.652866  -9.594 5.01e-16 ***
#> fproxy3      -1.047027   1.094465  -0.957  0.34094    
#> fproxy4      -2.142108   0.930189  -2.303  0.02326 *  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02873 on 105 degrees of freedom
#> Multiple R-squared:  0.9533, Adjusted R-squared:  0.9484 
#> F-statistic: 194.8 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $OR
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.059334 -0.020201 -0.001406  0.016245  0.060014 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.486811   0.241682 -18.565  < 2e-16 ***
#> treated_post -0.048917   0.022553  -2.169 0.032339 *  
#> afdcben      -0.002012   0.015164  -0.133 0.894699    
#> unemp         0.004461   0.009977   0.447 0.655674    
#> empratio     -0.040695   0.434175  -0.094 0.925503    
#> mon_d2        0.019076   0.010186   1.873 0.063882 .  
#> mon_d3        0.004865   0.014508   0.335 0.738023    
#> mon_d4       -0.020499   0.011529  -1.778 0.078300 .  
#> fproxy1       2.480994   0.598766   4.144 6.94e-05 ***
#> fproxy2      -4.997580   1.381968  -3.616 0.000461 ***
#> fproxy3       4.826518   1.360316   3.548 0.000582 ***
#> fproxy4      -3.266459   1.547950  -2.110 0.037218 *  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02852 on 105 degrees of freedom
#> Multiple R-squared:  0.9049, Adjusted R-squared:  0.895 
#> F-statistic: 90.84 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $SC
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.063796 -0.016882 -0.002845  0.017647  0.141860 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.959442   0.373206 -13.289  < 2e-16 ***
#> treated_post -0.034005   0.021707  -1.567 0.120231    
#> afdcben       0.144766   0.063890   2.266 0.025512 *  
#> unemp         0.046443   0.005344   8.691 5.21e-14 ***
#> empratio      0.549757   0.255982   2.148 0.034043 *  
#> mon_d2        0.044306   0.010641   4.164 6.43e-05 ***
#> mon_d3        0.025416   0.012625   2.013 0.046648 *  
#> mon_d4        0.024964   0.008909   2.802 0.006047 ** 
#> fproxy1       0.906359   0.262270   3.456 0.000793 ***
#> fproxy2      -1.336067   0.570745  -2.341 0.021125 *  
#> fproxy3      10.643036   1.266449   8.404 2.26e-13 ***
#> fproxy4      -6.333689   0.826235  -7.666 9.37e-12 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02929 on 105 degrees of freedom
#> Multiple R-squared:  0.9222, Adjusted R-squared:  0.914 
#> F-statistic: 113.1 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $SD
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.036318 -0.008684  0.001942  0.010730  0.031203 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.712745   0.103396 -45.579  < 2e-16 ***
#> treated_post -0.027688   0.011077  -2.500 0.013979 *  
#> afdcben      -0.015157   0.004985  -3.041 0.002980 ** 
#> unemp         0.012006   0.006747   1.779 0.078058 .  
#> empratio     -0.065464   0.138705  -0.472 0.637931    
#> mon_d2        0.015869   0.008393   1.891 0.061430 .  
#> mon_d3        0.003895   0.009032   0.431 0.667160    
#> mon_d4       -0.005092   0.007040  -0.723 0.471125    
#> fproxy1      -0.605891   0.146155  -4.146 6.89e-05 ***
#> fproxy2      -3.572147   0.681095  -5.245 8.17e-07 ***
#> fproxy3      -0.550497   0.516919  -1.065 0.289339    
#> fproxy4      -2.116239   0.558775  -3.787 0.000254 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01497 on 105 degrees of freedom
#> Multiple R-squared:  0.9655, Adjusted R-squared:  0.9619 
#> F-statistic: 266.9 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $TX
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.047196 -0.015691  0.000544  0.015874  0.054473 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -3.866513   0.431861  -8.953 1.36e-14 ***
#> treated_post -0.015630   0.014400  -1.085 0.280249    
#> afdcben       0.122658   0.054497   2.251 0.026486 *  
#> unemp         0.023746   0.005104   4.652 9.62e-06 ***
#> empratio      1.680979   0.468358   3.589 0.000506 ***
#> mon_d2       -0.001162   0.007177  -0.162 0.871656    
#> mon_d3       -0.003324   0.008882  -0.374 0.709017    
#> mon_d4       -0.009713   0.009286  -1.046 0.297985    
#> fproxy1       5.660704   0.310224  18.247  < 2e-16 ***
#> fproxy2      -5.585974   0.433599 -12.883  < 2e-16 ***
#> fproxy3      -5.492665   1.223777  -4.488 1.85e-05 ***
#> fproxy4      -3.849704   1.157086  -3.327 0.001210 ** 
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02167 on 105 degrees of freedom
#> Multiple R-squared:  0.9817, Adjusted R-squared:  0.9797 
#> F-statistic: 510.9 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $UT
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.051770 -0.009582  0.001450  0.009970  0.032177 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -5.515662   0.120813 -45.655  < 2e-16 ***
#> treated_post -0.065483   0.019775  -3.311 0.001273 ** 
#> afdcben      -0.003424   0.014705  -0.233 0.816319    
#> unemp         0.035830   0.006642   5.395 4.27e-07 ***
#> empratio     -0.672416   0.182424  -3.686 0.000362 ***
#> mon_d2        0.003101   0.004791   0.647 0.518805    
#> mon_d3        0.023060   0.005960   3.869 0.000190 ***
#> mon_d4        0.027870   0.006608   4.218 5.25e-05 ***
#> fproxy1      -0.384399   0.285997  -1.344 0.181824    
#> fproxy2      -5.795835   0.785835  -7.375 3.97e-11 ***
#> fproxy3       0.336899   0.641621   0.525 0.600638    
#> fproxy4       3.365848   0.741949   4.536 1.53e-05 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01559 on 105 degrees of freedom
#> Multiple R-squared:  0.9847, Adjusted R-squared:  0.9831 
#> F-statistic:   615 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $VA
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.030168 -0.010422 -0.001796  0.010346  0.039923 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.853048   0.175583 -27.640  < 2e-16 ***
#> treated_post -0.051017   0.008515  -5.992 2.96e-08 ***
#> afdcben       0.022389   0.012337   1.815   0.0724 .  
#> unemp         0.018517   0.003800   4.873 3.92e-06 ***
#> empratio      0.024199   0.178916   0.135   0.8927    
#> mon_d2        0.030595   0.005161   5.928 3.95e-08 ***
#> mon_d3        0.027480   0.006627   4.147 6.86e-05 ***
#> mon_d4        0.007929   0.004312   1.839   0.0688 .  
#> fproxy1       2.834839   0.126572  22.397  < 2e-16 ***
#> fproxy2      -0.818651   0.428979  -1.908   0.0591 .  
#> fproxy3       6.793847   0.463954  14.643  < 2e-16 ***
#> fproxy4      -5.336242   0.914757  -5.834 6.07e-08 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01603 on 105 degrees of freedom
#> Multiple R-squared:  0.9721, Adjusted R-squared:  0.9691 
#> F-statistic: 332.2 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $VT
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.060083 -0.018320 -0.001681  0.015350  0.065133 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -5.016665   0.224943 -22.302  < 2e-16 ***
#> treated_post  0.014309   0.020436   0.700 0.485352    
#> afdcben       0.006390   0.006608   0.967 0.335782    
#> unemp         0.035469   0.010020   3.540 0.000598 ***
#> empratio     -0.838541   0.411883  -2.036 0.044281 *  
#> mon_d2        0.071767   0.008462   8.481 1.53e-13 ***
#> mon_d3        0.103809   0.010507   9.880  < 2e-16 ***
#> mon_d4        0.055310   0.007925   6.979 2.77e-10 ***
#> fproxy1       3.262856   0.452320   7.214 8.81e-11 ***
#> fproxy2      -0.101699   0.913957  -0.111 0.911612    
#> fproxy3       5.368715   1.199119   4.477 1.93e-05 ***
#> fproxy4      -5.624930   1.835743  -3.064 0.002775 ** 
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02751 on 105 degrees of freedom
#> Multiple R-squared:   0.96,  Adjusted R-squared:  0.9558 
#> F-statistic: 229.2 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $WA
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>        Min         1Q     Median         3Q        Max 
#> -0.0258732 -0.0069926  0.0007945  0.0069502  0.0239515 
#> 
#> Coefficients:
#>                Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.3990685  0.0678645 -64.821  < 2e-16 ***
#> treated_post -0.0271804  0.0084656  -3.211 0.001758 ** 
#> afdcben      -0.0005372  0.0021751  -0.247 0.805406    
#> unemp         0.0110059  0.0029803   3.693 0.000354 ***
#> empratio     -0.2571693  0.1058384  -2.430 0.016802 *  
#> mon_d2        0.0285400  0.0033942   8.409 2.21e-13 ***
#> mon_d3        0.0196549  0.0043461   4.522 1.61e-05 ***
#> mon_d4        0.0022734  0.0032004   0.710 0.479069    
#> fproxy1       1.0988974  0.0863293  12.729  < 2e-16 ***
#> fproxy2      -0.8150586  0.3122996  -2.610 0.010381 *  
#> fproxy3       1.8581534  0.4296689   4.325 3.49e-05 ***
#> fproxy4      -1.7096214  0.4596828  -3.719 0.000323 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.009843 on 105 degrees of freedom
#> Multiple R-squared:  0.9457, Adjusted R-squared:  0.9401 
#> F-statistic: 166.4 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $WV
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.038166 -0.008359 -0.000617  0.005906  0.038023 
#> 
#> Coefficients:
#>                Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.1820541  0.1358858 -30.776  < 2e-16 ***
#> treated_post  0.0166457  0.0071856   2.317  0.02247 *  
#> afdcben      -0.0096027  0.0273676  -0.351  0.72638    
#> unemp         0.0008577  0.0022697   0.378  0.70627    
#> empratio     -0.4129125  0.1252698  -3.296  0.00134 ** 
#> mon_d2        0.0121286  0.0041463   2.925  0.00422 ** 
#> mon_d3        0.0203814  0.0047396   4.300 3.83e-05 ***
#> mon_d4        0.0071186  0.0049176   1.448  0.15072    
#> fproxy1       2.2331280  0.2235382   9.990  < 2e-16 ***
#> fproxy2      -2.1173797  0.3517840  -6.019 2.61e-08 ***
#> fproxy3      -0.3094391  0.5426436  -0.570  0.56973    
#> fproxy4       0.0762629  0.5615696   0.136  0.89224    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01392 on 105 degrees of freedom
#> Multiple R-squared:  0.9432, Adjusted R-squared:  0.9373 
#> F-statistic: 158.6 on 11 and 105 DF,  p-value: < 2.2e-16
#> 
#> 
#> $WY
#> 
#> Call:
#> stats::lm(formula = y1[idx] ~ data1[[didvar]][idx] + X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.147967 -0.019123  0.001573  0.024926  0.101063 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.558865   0.293529 -15.531  < 2e-16 ***
#> treated_post -0.114296   0.028081  -4.070 9.12e-05 ***
#> afdcben      -0.009646   0.019456  -0.496 0.621060    
#> unemp        -0.030303   0.007822  -3.874 0.000187 ***
#> empratio     -0.621530   0.345033  -1.801 0.074515 .  
#> mon_d2       -0.018526   0.012957  -1.430 0.155739    
#> mon_d3       -0.061356   0.016597  -3.697 0.000349 ***
#> mon_d4       -0.074327   0.016715  -4.447 2.17e-05 ***
#> fproxy1       2.703313   0.495021   5.461 3.20e-07 ***
#> fproxy2      -4.873100   1.129703  -4.314 3.64e-05 ***
#> fproxy3       0.006871   1.166717   0.006 0.995312    
#> fproxy4      -4.886775   2.730497  -1.790 0.076384 .  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.03921 on 105 degrees of freedom
#> Multiple R-squared:  0.9116, Adjusted R-squared:  0.9024 
#> F-statistic: 98.46 on 11 and 105 DF,  p-value: < 2.2e-16
```

To access list of control unit estimates

``` r
result$control
#> $AZ
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.064933 -0.016582 -0.000455  0.014996  0.064708 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -4.443868   0.145987 -30.440  < 2e-16 ***
#> afdcben     -0.021178   0.012509  -1.693 0.093386 .  
#> unemp       -0.017317   0.005651  -3.065 0.002764 ** 
#> empratio    -0.750109   0.209357  -3.583 0.000515 ***
#> mon_d2       0.053869   0.009023   5.970 3.19e-08 ***
#> mon_d3       0.014438   0.011050   1.307 0.194182    
#> mon_d4      -0.021670   0.009014  -2.404 0.017952 *  
#> fproxy1      7.099315   0.222315  31.934  < 2e-16 ***
#> fproxy2      4.613466   0.902559   5.112 1.42e-06 ***
#> fproxy3      3.772725   1.053864   3.580 0.000520 ***
#> fproxy4     -5.093637   0.913745  -5.574 1.91e-07 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02665 on 106 degrees of freedom
#> Multiple R-squared:  0.9798, Adjusted R-squared:  0.9779 
#> F-statistic: 514.8 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $CA
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.028795 -0.010268 -0.002092  0.009183  0.048299 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -4.475930   0.115898 -38.620  < 2e-16 ***
#> afdcben     -0.021108   0.013979  -1.510 0.134028    
#> unemp        0.005857   0.003383   1.731 0.086284 .  
#> empratio    -0.070913   0.150156  -0.472 0.637713    
#> mon_d2       0.018329   0.005407   3.390 0.000983 ***
#> mon_d3       0.017686   0.007049   2.509 0.013622 *  
#> mon_d4       0.009419   0.006580   1.431 0.155235    
#> fproxy1      0.049618   0.144859   0.343 0.732632    
#> fproxy2     -3.283111   0.736000  -4.461 2.04e-05 ***
#> fproxy3      3.819696   0.671513   5.688 1.15e-07 ***
#> fproxy4     -2.722671   0.630611  -4.318 3.56e-05 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01563 on 106 degrees of freedom
#> Multiple R-squared:  0.9412, Adjusted R-squared:  0.9357 
#> F-statistic: 169.7 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $CT
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.027369 -0.008274 -0.000895  0.007990  0.033714 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -4.547426   0.095681 -47.527  < 2e-16 ***
#> afdcben     -0.017206   0.010024  -1.717  0.08899 .  
#> unemp       -0.004798   0.003434  -1.397  0.16528    
#> empratio    -0.126487   0.149882  -0.844  0.40062    
#> mon_d2       0.001007   0.004481   0.225  0.82268    
#> mon_d3      -0.011844   0.006219  -1.904  0.05958 .  
#> mon_d4      -0.017413   0.005478  -3.179  0.00194 ** 
#> fproxy1      0.106513   0.101850   1.046  0.29804    
#> fproxy2     -4.599099   0.565420  -8.134 8.44e-13 ***
#> fproxy3     -1.159406   0.620101  -1.870  0.06428 .  
#> fproxy4     -1.792389   0.461715  -3.882  0.00018 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01261 on 106 degrees of freedom
#> Multiple R-squared:  0.9655, Adjusted R-squared:  0.9622 
#> F-statistic: 296.3 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $DE
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.047500 -0.012986 -0.001543  0.015453  0.045952 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -4.568074   0.111614 -40.927  < 2e-16 ***
#> afdcben     -0.019606   0.010736  -1.826 0.070641 .  
#> unemp       -0.009709   0.003939  -2.465 0.015320 *  
#> empratio    -0.241920   0.153756  -1.573 0.118607    
#> mon_d2       0.006595   0.006818   0.967 0.335599    
#> mon_d3      -0.008365   0.008834  -0.947 0.345847    
#> mon_d4      -0.019485   0.008202  -2.376 0.019321 *  
#> fproxy1      0.489635   0.147163   3.327 0.001207 ** 
#> fproxy2     -6.169248   0.645664  -9.555 5.64e-16 ***
#> fproxy3     -1.058732   0.681280  -1.554 0.123157    
#> fproxy4     -2.568760   0.693960  -3.702 0.000342 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.0196 on 106 degrees of freedom
#> Multiple R-squared:  0.9544, Adjusted R-squared:  0.9501 
#> F-statistic:   222 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $GA
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.093939 -0.022334  0.003737  0.022704  0.068860 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -3.243838   0.217970 -14.882  < 2e-16 ***
#> afdcben     -0.016443   0.011121  -1.479 0.142225    
#> unemp       -0.015408   0.008644  -1.783 0.077525 .  
#> empratio    -0.359793   0.310543  -1.159 0.249225    
#> mon_d2       0.025352   0.012400   2.045 0.043370 *  
#> mon_d3       0.021729   0.015680   1.386 0.168724    
#> mon_d4       0.012330   0.013998   0.881 0.380403    
#> fproxy1     11.464701   0.319421  35.892  < 2e-16 ***
#> fproxy2      9.211908   0.805075  11.442  < 2e-16 ***
#> fproxy3      0.391123   1.336940   0.293 0.770437    
#> fproxy4     -8.530073   2.287656  -3.729 0.000311 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.0344 on 106 degrees of freedom
#> Multiple R-squared:  0.9877, Adjusted R-squared:  0.9865 
#> F-statistic: 847.8 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $HI
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.096811 -0.023956 -0.001789  0.022898  0.095347 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.252705   0.403471 -10.540  < 2e-16 ***
#> afdcben      -0.061429   0.023436  -2.621  0.01005 *  
#> unemp        -0.032707   0.006144  -5.323 5.75e-07 ***
#> empratio     -0.438951   0.450621  -0.974  0.33222    
#> mon_d2        0.032043   0.013636   2.350  0.02063 *  
#> mon_d3        0.031461   0.022031   1.428  0.15623    
#> mon_d4       -0.001264   0.017179  -0.074  0.94148    
#> fproxy1      10.225585   0.448417  22.804  < 2e-16 ***
#> fproxy2       0.541882   1.068063   0.507  0.61296    
#> fproxy3       3.941835   1.466653   2.688  0.00836 ** 
#> fproxy4     -17.632208   2.252717  -7.827 3.99e-12 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.03959 on 106 degrees of freedom
#> Multiple R-squared:  0.9796, Adjusted R-squared:  0.9777 
#> F-statistic: 509.5 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $IA
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.054286 -0.014184 -0.000214  0.012398  0.061474 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -5.784597   0.116716 -49.561  < 2e-16 ***
#> afdcben      0.037916   0.009362   4.050 9.77e-05 ***
#> unemp       -0.005696   0.004082  -1.395 0.165864    
#> empratio    -0.787955   0.213070  -3.698 0.000346 ***
#> mon_d2       0.010131   0.007348   1.379 0.170870    
#> mon_d3      -0.012822   0.009595  -1.336 0.184333    
#> mon_d4      -0.030940   0.007496  -4.128 7.32e-05 ***
#> fproxy1      0.210179   0.152233   1.381 0.170294    
#> fproxy2      0.495964   0.668586   0.742 0.459843    
#> fproxy3      6.551013   0.841545   7.785 4.94e-12 ***
#> fproxy4      2.683650   0.789080   3.401 0.000948 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02152 on 106 degrees of freedom
#> Multiple R-squared:  0.8237, Adjusted R-squared:  0.8071 
#> F-statistic: 49.53 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $IL
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.047616 -0.010068 -0.001031  0.009523  0.046407 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -4.383142   0.100280 -43.709  < 2e-16 ***
#> afdcben     -0.001999   0.009488  -0.211  0.83351    
#> unemp        0.018288   0.003466   5.276 7.05e-07 ***
#> empratio     0.382107   0.147392   2.592  0.01087 *  
#> mon_d2       0.022844   0.006906   3.308  0.00128 ** 
#> mon_d3       0.026914   0.008767   3.070  0.00272 ** 
#> mon_d4       0.003322   0.007593   0.438  0.66262    
#> fproxy1      2.529343   0.231037  10.948  < 2e-16 ***
#> fproxy2     -4.027201   0.664518  -6.060 2.11e-08 ***
#> fproxy3      0.918175   0.819583   1.120  0.26512    
#> fproxy4     -1.517488   0.761899  -1.992  0.04897 *  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01757 on 106 degrees of freedom
#> Multiple R-squared:  0.9389, Adjusted R-squared:  0.9332 
#> F-statistic:   163 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $IN
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.094612 -0.018310 -0.000628  0.020828  0.069944 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.211134   0.160670 -26.210  < 2e-16 ***
#> afdcben      -0.061927   0.014384  -4.305 3.73e-05 ***
#> unemp        -0.025263   0.007859  -3.214 0.001732 ** 
#> empratio     -0.961840   0.282852  -3.401 0.000949 ***
#> mon_d2        0.030259   0.011464   2.639 0.009557 ** 
#> mon_d3        0.023784   0.012637   1.882 0.062574 .  
#> mon_d4        0.003525   0.008918   0.395 0.693447    
#> fproxy1       4.128757   0.171515  24.072  < 2e-16 ***
#> fproxy2      -0.424403   0.897979  -0.473 0.637456    
#> fproxy3      -3.751323   1.396103  -2.687 0.008373 ** 
#> fproxy4     -12.305020   1.498589  -8.211 5.70e-13 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02942 on 106 degrees of freedom
#> Multiple R-squared:  0.9467, Adjusted R-squared:  0.9417 
#> F-statistic: 188.4 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $LA
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.038441 -0.017622  0.000613  0.014275  0.064782 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -4.342755   0.142867 -30.397  < 2e-16 ***
#> afdcben     -0.005445   0.013185  -0.413  0.68048    
#> unemp       -0.005731   0.005204  -1.101  0.27334    
#> empratio    -0.211374   0.244217  -0.866  0.38871    
#> mon_d2       0.037555   0.008721   4.306 3.72e-05 ***
#> mon_d3       0.043723   0.009432   4.636 1.02e-05 ***
#> mon_d4       0.021350   0.008771   2.434  0.01660 *  
#> fproxy1      2.478167   0.200599  12.354  < 2e-16 ***
#> fproxy2     -0.380619   0.876526  -0.434  0.66500    
#> fproxy3      3.939271   1.241915   3.172  0.00198 ** 
#> fproxy4     -9.688750   1.178735  -8.220 5.46e-13 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02238 on 106 degrees of freedom
#> Multiple R-squared:  0.9214, Adjusted R-squared:  0.914 
#> F-statistic: 124.2 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $MA
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.072968 -0.027951  0.002723  0.025846  0.084041 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.529528   0.181808 -24.914  < 2e-16 ***
#> afdcben      -0.050428   0.016110  -3.130 0.002256 ** 
#> unemp        -0.011307   0.008263  -1.368 0.174060    
#> empratio     -1.030622   0.298820  -3.449 0.000809 ***
#> mon_d2        0.066624   0.012915   5.159 1.17e-06 ***
#> mon_d3        0.061055   0.015207   4.015 0.000111 ***
#> mon_d4        0.020748   0.010891   1.905 0.059479 .  
#> fproxy1       4.129179   0.241927  17.068  < 2e-16 ***
#> fproxy2       1.166931   1.039044   1.123 0.263941    
#> fproxy3      -0.503469   1.399937  -0.360 0.719834    
#> fproxy4     -11.928225   1.999469  -5.966 3.26e-08 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.03491 on 106 degrees of freedom
#> Multiple R-squared:  0.9031, Adjusted R-squared:  0.8939 
#> F-statistic: 98.77 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $MI
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.051426 -0.011020  0.000089  0.012170  0.044488 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -4.397074   0.137623 -31.950  < 2e-16 ***
#> afdcben     -0.012201   0.009586  -1.273  0.20589    
#> unemp       -0.005290   0.003878  -1.364  0.17549    
#> empratio    -0.196452   0.182244  -1.078  0.28350    
#> mon_d2       0.023443   0.005599   4.187 5.86e-05 ***
#> mon_d3       0.010886   0.008541   1.275  0.20524    
#> mon_d4      -0.012370   0.007956  -1.555  0.12300    
#> fproxy1      0.875285   0.159467   5.489 2.78e-07 ***
#> fproxy2     -1.873420   0.573015  -3.269  0.00145 ** 
#> fproxy3      1.821853   0.694364   2.624  0.00998 ** 
#> fproxy4     -4.525914   0.875181  -5.171 1.10e-06 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01768 on 106 degrees of freedom
#> Multiple R-squared:  0.8603, Adjusted R-squared:  0.8471 
#> F-statistic: 65.29 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $MO
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.039542 -0.010349  0.000891  0.011552  0.031949 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -3.905512   0.123030 -31.744   <2e-16 ***
#> afdcben     -0.007158   0.009527  -0.751   0.4541    
#> unemp       -0.004196   0.002639  -1.590   0.1149    
#> empratio    -0.196561   0.131657  -1.493   0.1384    
#> mon_d2       0.001108   0.005395   0.205   0.8377    
#> mon_d3       0.005207   0.006565   0.793   0.4295    
#> mon_d4      -0.010125   0.005442  -1.861   0.0656 .  
#> fproxy1     -2.254924   0.121800 -18.513   <2e-16 ***
#> fproxy2     -6.133986   0.484211 -12.668   <2e-16 ***
#> fproxy3      1.134271   0.513243   2.210   0.0293 *  
#> fproxy4      0.942509   0.687371   1.371   0.1732    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.0153 on 106 degrees of freedom
#> Multiple R-squared:  0.9762, Adjusted R-squared:  0.974 
#> F-statistic: 435.4 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $MT
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.096559 -0.017757  0.004714  0.022078  0.066285 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -4.640718   0.214254 -21.660  < 2e-16 ***
#> afdcben     -0.015872   0.014419  -1.101   0.2735    
#> unemp       -0.052553   0.007545  -6.965 2.87e-10 ***
#> empratio    -1.245839   0.300314  -4.148 6.77e-05 ***
#> mon_d2      -0.009421   0.011704  -0.805   0.4227    
#> mon_d3      -0.000853   0.016930  -0.050   0.9599    
#> mon_d4      -0.028560   0.013161  -2.170   0.0322 *  
#> fproxy1      5.132200   0.234807  21.857  < 2e-16 ***
#> fproxy2      4.664579   1.059816   4.401 2.57e-05 ***
#> fproxy3      9.061740   1.254517   7.223 8.09e-11 ***
#> fproxy4     -8.789241   1.634302  -5.378 4.53e-07 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.03537 on 106 degrees of freedom
#> Multiple R-squared:  0.9562, Adjusted R-squared:  0.9521 
#> F-statistic: 231.5 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $NC
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.060099 -0.018081  0.002481  0.020695  0.058548 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -4.769727   0.183612 -25.977  < 2e-16 ***
#> afdcben      0.044277   0.009964   4.444 2.18e-05 ***
#> unemp        0.003161   0.005820   0.543  0.58819    
#> empratio     0.771174   0.259586   2.971  0.00368 ** 
#> mon_d2       0.018107   0.011120   1.628  0.10642    
#> mon_d3      -0.002519   0.015349  -0.164  0.86996    
#> mon_d4      -0.010264   0.012082  -0.850  0.39750    
#> fproxy1      4.370124   0.293712  14.879  < 2e-16 ***
#> fproxy2     -4.127701   0.777295  -5.310 6.07e-07 ***
#> fproxy3      4.119431   1.267242   3.251  0.00154 ** 
#> fproxy4     -8.182319   1.379280  -5.932 3.80e-08 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02871 on 106 degrees of freedom
#> Multiple R-squared:  0.9551, Adjusted R-squared:  0.9509 
#> F-statistic: 225.6 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $ND
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.038401 -0.012414  0.001184  0.011577  0.040888 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -3.844860   0.118730 -32.383  < 2e-16 ***
#> afdcben      0.005373   0.008207   0.655  0.51409    
#> unemp        0.000603   0.003760   0.160  0.87291    
#> empratio     0.016952   0.171746   0.099  0.92156    
#> mon_d2       0.023821   0.007201   3.308  0.00128 ** 
#> mon_d3       0.027166   0.008132   3.341  0.00116 ** 
#> mon_d4       0.010206   0.006875   1.484  0.14066    
#> fproxy1      5.318083   0.185694  28.639  < 2e-16 ***
#> fproxy2      3.047199   0.579679   5.257 7.66e-07 ***
#> fproxy3      3.726481   0.825686   4.513 1.66e-05 ***
#> fproxy4     -4.010126   1.202629  -3.334  0.00118 ** 
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01777 on 106 degrees of freedom
#> Multiple R-squared:  0.9845, Adjusted R-squared:  0.983 
#> F-statistic: 673.1 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $NE
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.032257 -0.011175 -0.000122  0.009596  0.036230 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -4.127992   0.096580 -42.742  < 2e-16 ***
#> afdcben     -0.002543   0.010853  -0.234 0.815157    
#> unemp       -0.004176   0.004040  -1.034 0.303582    
#> empratio    -0.055979   0.169844  -0.330 0.742360    
#> mon_d2       0.017021   0.005190   3.280 0.001407 ** 
#> mon_d3       0.022021   0.006326   3.481 0.000727 ***
#> mon_d4       0.003231   0.005352   0.604 0.547299    
#> fproxy1      2.530680   0.116668  21.691  < 2e-16 ***
#> fproxy2      0.427391   0.651216   0.656 0.513055    
#> fproxy3      4.547076   0.765260   5.942 3.64e-08 ***
#> fproxy4     -4.820068   0.778713  -6.190 1.16e-08 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.01544 on 106 degrees of freedom
#> Multiple R-squared:  0.9556, Adjusted R-squared:  0.9514 
#> F-statistic: 228.3 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $NH
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.079523 -0.018794  0.001131  0.020148  0.061538 
#> 
#> Coefficients:
#>               Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  -4.112268   0.172167 -23.885  < 2e-16 ***
#> afdcben      -0.034970   0.012520  -2.793  0.00619 ** 
#> unemp        -0.022164   0.008107  -2.734  0.00734 ** 
#> empratio     -0.654033   0.268748  -2.434  0.01662 *  
#> mon_d2        0.032868   0.011640   2.824  0.00567 ** 
#> mon_d3        0.033135   0.014945   2.217  0.02875 *  
#> mon_d4        0.002720   0.010766   0.253  0.80101    
#> fproxy1       7.743131   0.233468  33.166  < 2e-16 ***
#> fproxy2       4.047608   0.780232   5.188 1.03e-06 ***
#> fproxy3       0.766249   1.287117   0.595  0.55290    
#> fproxy4     -12.864028   1.729973  -7.436 2.82e-11 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.03091 on 106 degrees of freedom
#> Multiple R-squared:  0.9773, Adjusted R-squared:  0.9752 
#> F-statistic: 457.4 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $NJ
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.050933 -0.013175 -0.000563  0.012073  0.059161 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -4.139494   0.134093 -30.870  < 2e-16 ***
#> afdcben     -0.043674   0.012863  -3.395 0.000966 ***
#> unemp       -0.011434   0.004768  -2.398 0.018228 *  
#> empratio    -0.480611   0.160899  -2.987 0.003500 ** 
#> mon_d2       0.009650   0.007860   1.228 0.222280    
#> mon_d3       0.017354   0.009443   1.838 0.068902 .  
#> mon_d4       0.003551   0.007668   0.463 0.644232    
#> fproxy1      6.393214   0.184616  34.630  < 2e-16 ***
#> fproxy2      0.601303   0.723274   0.831 0.407638    
#> fproxy3     -1.218286   0.649057  -1.877 0.063266 .  
#> fproxy4     -4.502108   1.133290  -3.973 0.000130 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02209 on 106 degrees of freedom
#> Multiple R-squared:  0.9805, Adjusted R-squared:  0.9787 
#> F-statistic: 532.9 on 10 and 106 DF,  p-value: < 2.2e-16
#> 
#> 
#> $OH
#> 
#> Call:
#> stats::lm(formula = y0[idx] ~ X1i + F)
#> 
#> Residuals:
#>       Min        1Q    Median        3Q       Max 
#> -0.075742 -0.017522 -0.001792  0.016082  0.084380 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -4.447923   0.180739 -24.610  < 2e-16 ***
#> afdcben      0.028530   0.019294   1.479  0.14219    
#> unemp        0.008152   0.005498   1.483  0.14111    
#> empratio    -0.128118   0.338107  -0.379  0.70550    
#> mon_d2       0.021705   0.010407   2.086  0.03941 *  
#> mon_d3       0.037212   0.010236   3.635  0.00043 ***
#> mon_d4       0.002927   0.009081   0.322  0.74784    
#> fproxy1     -4.133921   0.286671 -14.420  < 2e-16 ***
#> fproxy2     -6.116308   1.406582  -4.348 3.16e-05 ***
#> fproxy3     11.621747   1.730176   6.717 9.53e-10 ***
#> fproxy4     -0.918837   0.997103  -0.922  0.35888    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.02761 on 106 degrees of freedom
#> Multiple R-squared:  0.9613, Adjusted R-squared:  0.9576 
#> F-statistic: 263.2 on 10 and 106 DF,  p-value: < 2.2e-16
```
