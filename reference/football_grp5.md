# Football red cards study: Team 5

Material from one team in the many-analysts study of racial bias in
football referee decisions (Silberzahn et al., 2018:
<https://osf.io/qix4g/>), where 29 teams analysed the same dataset
independently.

`football_grp5` is the methodology as Team 5 reported it, in prose. It
can be passed straight to [`extract_schema()`](extract_schema.md), which
is how the accompanying schema was produced.

## Usage

``` r
football_grp5
```

## Format

A character string of length 1, covering: averaging the two skin-tone
ratings into `avgrate01`; listwise deletion of cases missing skin-tone
rating, `meanIAT` or `meanExp`; disaggregation of the response so that
each row is one game and `redCards` appears as a 0/1 outcome; the
resulting choice of a binomial error distribution; and estimation of a
generalized linear mixed model with `lme4::glmer()`, including the
random-effects structure the team settled on.

## Source

Silberzahn, R., et al. (2018). Many analysts, one dataset: Making
transparent how variations in analytical choices affect results.
*Advances in Methods and Practices in Psychological Science*, 1(3),
337–356.
[doi:10.1177/2515245917747646](https://doi.org/10.1177/2515245917747646)

## See also

[`example_hdi()`](example_tines.md) for the small invented examples.
