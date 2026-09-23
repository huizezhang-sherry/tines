# Case Study: A Published GAITD Regression Analysis

``` r

library(tines)
```

This vignette walks through a real, published analysis end to end: Yee,
Frigau, and Ma (2025, *The Annals of Applied Statistics*) fit a GAITD
regression to model heaped smoking-initiation-age data. We use their
first response variable (smoking initiation age, “P1” in their paper) to
show how a schema can accompany a manuscript as reproducibility
material, and how an alternative file can encode a reviewer’s suggested
change.

## The schema

Yee et al.’s manuscript and supplementary material already state each
analytical decision and its rationale – assembling a schema from it
required no new analysis, only collecting those decisions into the
`tines` schema format. We drafted a template with
`draft_tines(type = "schema")` and filled it in by hand.

Click to read the filled schema.

``` yaml
meta:
  type: schema
nodes:
- id: complete_case_filtering
  objective: handle missing data in selected variables
  decision: apply complete-case filtering to all columns except TC30, TCquit, and SCA which have NAs by design
  rationale: TC30, TCquit, and SCA are exempted from the completeness check since they are interlaced with NAs by design (e.g., SCA being NA means the person has not yet quit, a valid state rather than missingness); every other selected column is required to be non-missing because most smoking studies adjust for age, marital status, education and race, and this analysis follows suit. 

- id: age_restriction
  objective: define the age range for analysis
  decision: restrict analysis to respondents aged less than 80 years (age < 80)
  rationale: age was right-censored at 80

- id: data_quality_correction
  objective: handle logically impossible self-reported values
  decision: set both SCA and SIA to NA where SCA - SIA < 0
  rationale: quitting age before smoking initiation age is a logical impossibility and such values cannot be trusted

- id: impute_marital_young
  objective: assign a defensible marital status for young respondents, regardless of what was recorded
  decision: recode marital status to "Never married" for everyone age < 20
  rationale: this age group is effectively certain to have never been married, so the value is set by age rather than trusting the raw survey response

- id: impute_education_young
  objective: assign a defensible education category for young respondents, regardless of what was recorded
  decision: recode education to "< 9th grade" for age < 14; "9-11th grade" for 14 <= age <= 16; "High school" for 17 <= age <= 19
  rationale: for respondents still of school age, highest-grade-completed is essentially determined by age, so the value is set by age rather than trusting the raw survey response

- id: define_ever_smokers_sample
  objective: define the analytic sample of ever-smokers
  decision: include as valid observation if both conditions are met -- 1) SIA is not missing, and 2) either SCA and TCquit are both not missing, or SCA is missing and TC30 is not missing
  rationale: SCA is missing by design for anyone who has not yet quit. the two-branch rule instead admits ex-smokers through the SCA/TCquit branch and current smokers through the TC30 branch

- id: parent_distribution_choice
  objective: select appropriate probability distribution for count response variable
  decision: adopt negative binomial distribution as the parent distribution
  rationale: the SIA distributions iboth unimodal and right-skewed, so a NBD parent is reasonable; more generally, there is evidence of overdispersion relative to a Poisson distribution.

- id: special_value_mid_risk
  objective: specify how to model inflation at ages surrounding peak teenage smoking uptake
  decision: treat ages 12, 13, 14, 19, 20, 21 as a parametrically-inflated group, with the extra probability mass there sharing the same distributional shape (mean and dispersion) as the main population 
  rationale: this mid-risk subgroup represents early and later smokers surrounding the high-risk age subgroup; these ages showed a moderate, secondary elevation in repeated training/test spikeplots of the data

- id: special_value_high_risk
  objective: specify how to model inflation at peak teenage smoking uptake ages
  decision: treat ages 15, 16, 17, 18 as a nonparametrically-inflated group, with each age given its own freely-estimated extra probability 
  rationale: this high-risk subgroup corresponds to frenetic teenage smoking uptake, the age range where the largest number of regular smokers start; these ages showed the largest, most persistent spikes across repeated training/test spikeplots of the data.

- id: alteration_operator_decision
  objective: determine whether to apply alteration operators
  decision: do not use alteration operators (A.mix and A.mlm set to NULL)
  rationale: not needed for this model specification

- id: deflation_operator_decision
  objective: determine whether to apply deflation operators
  decision: do not use deflation operators (D.mix and D.mlm set to NULL)
  rationale: not needed for this model specification

- id: truncation_decision
  objective: determine whether to specify a truncated region
  decision: do not use truncation (no truncated region specified for SIA)
  rationale: truncation not appropriate for this response variable

- id: covariate_selection
  objective: select covariates for the linear predictor of parent distribution mean
  decision: include race2, gender, marital, and educ as covariates
  rationale: most smoking studies adjust for age, marital status, education and race

- id: fit_final_model
  objective: fit the final GAITD regression model 
  decision: fit a single vglm that puts together the pieces above -- response, parent distribution, special-value structure (inflation, alteration, deflation, and truncation), and covariates. The covariates only shift the mean of the negative binomial; the dispersion and the mid-/high-risk inflation probabilities are held fixed across the sample
  rationale: only the mean is modeled with covariates; the dispersion and inflation probabilities are kept intercept-only, since extending covariate effects to them would substantially increase the number of parameters to estimate and make the results harder to interpret
```

Consider the `special_value_mid_risk` step: the decision is to treat
ages 12-14 and 19-21 as one inflated group with extra probability mass,
since these ages show a moderate, secondary peak in the data alongside
the more prominent peak at ages 15-18. Recording the rationale alongside
the decision is what lets a reader agree or disagree with the choice,
and explore it, as we do later in this vignette.

## Generating and validating the code

We read this into a `schema` object with
[`read_tines()`](../reference/read-write.md):

``` r

schema <- read_tines(schema_path)
```

We then used `gen_code(schema, ...)` to translate this schema into an R
script, and [`validate_script()`](../reference/validate_script.md) to
fix any errors in the code generation.

Click to read the generated R script.

``` r

library(VGAMdata)
library(VGAM)
library(dplyr)

data("smqP", package = "VGAMdata")

cols <- c('TC30', 'TCquit', 'SCA', 'educ', 'marital',
          'SIA', 'SEQN', 'age', 'gender', 'race2',
          "passiveSmoke_job", "passiveSmoke_rest",
          "passiveSmoke_bar", "passiveSmoke_car",
          "passiveSmoke_home", "passiveSmoke_other",
          "passiveSmoke_ecigarettes")
df <- smqP |> select(all_of(cols))

# Step 1: complete_case_filtering
# Apply complete-case filtering to all columns except TC30, TCquit, and SCA
cols_require_complete <- setdiff(cols, c("TC30", "TCquit", "SCA"))
df_complete <- df |>
  filter(complete.cases(pick(all_of(cols_require_complete))))

# Step 2: age_restriction
# Restrict analysis to respondents aged less than 80 years
df_age_restricted <- df_complete |> filter(age < 80)

# Step 3: data_quality_correction
# Set both SCA and SIA to NA where SCA - SIA < 0
df_age_restricted <- df_age_restricted |>
  mutate(
    SCA_corrected = if_else(!is.na(SCA) & !is.na(SIA) & (SCA - SIA < 0), NA_integer_, SCA),
    SIA_corrected = if_else(!is.na(SCA) & !is.na(SIA) & (SCA - SIA < 0), NA_integer_, SIA)
  )

# Step 4: impute_marital_young
# Recode marital status to "Never married" for everyone age < 20
df_age_restricted <- df_age_restricted |>
  mutate(
    marital_imputed = if_else(age < 20, "Never married", as.character(marital))
  )

# Step 5: impute_education_young
# Recode education based on age for young respondents
df_age_restricted <- df_age_restricted |>
  mutate(
    educ_imputed = case_when(
      age < 14 ~ "< 9th grade",
      age >= 14 & age <= 16 ~ "9-11th grade",
      age >= 17 & age <= 19 ~ "High school",
      TRUE ~ as.character(educ)
    )
  )

# Step 6: define_ever_smokers_sample
# Include if: SIA not missing AND (both SCA and TCquit not missing OR SCA missing and TC30 not missing)
df_ever_smokers <- df_age_restricted |>
  filter(
    !is.na(SIA_corrected) &
    ((!is.na(SCA_corrected) & !is.na(TCquit)) | (is.na(SCA_corrected) & !is.na(TC30)))
  )

df_ever_smokers <- droplevels(df_ever_smokers)

# Step 7: parent_distribution_choice
# Adopt negative binomial distribution as the parent distribution
parent_distribution <- negbinomial

# Step 8: special_value_mid_risk
# Ages 12, 13, 14, 19, 20, 21 as parametrically-inflated group (i.mix)
i_mix_spec <- c(12, 13, 14, 19, 20, 21)

# Step 9: special_value_high_risk
# Ages 15, 16, 17, 18 as nonparametrically-inflated group (i.mlm)
i_mlm_spec <- c(15, 16, 17, 18)

# Step 10: alteration_operator_decision
# Do not use alteration operators
a_mix_spec <- NULL
a_mlm_spec <- NULL

# Step 11: deflation_operator_decision
# Do not use deflation operators
d_mix_spec <- NULL
d_mlm_spec <- NULL

# Step 12: truncation_decision
# Do not use truncation
truncation_spec <- NULL

# Step 13: covariate_selection
# Include race2, gender, marital, and educ as covariates
covariate_formula <- SIA_corrected ~ race2 + gender + marital_imputed + educ_imputed

# Step 14: fit_final_model
# Fit a single vglm with response, parent distribution, special-value structure, and covariates
fitted_model <- vglm(
  covariate_formula,
  family = gaitdnbinomial(
    i.mix = i_mix_spec, i.mlm = i_mlm_spec,
    a.mix = a_mix_spec, a.mlm = a_mlm_spec,
    d.mix = d_mix_spec, d.mlm = d_mlm_spec,
    truncate = truncation_spec
  ),
  data = df_ever_smokers
)
```

We can confirm the faithfulness of the schema and the generated script
by running the script and checking that it reproduces the estimation
reported in the paper (Table 2 in Yee et al., 2025). The script produces
a fitted model object, which we can summarize and display as a table:

| term | Estimate | Std. Error | z value | Pr(\>\|z\|) |
|:---|---:|---:|---:|:---|
| (Intercept):1 | 2.819 | 0.043 | 65.106 | \< 0.001 |
| (Intercept):2 | 2.579 | 0.065 | 39.602 | \< 0.001 |
| (Intercept):3 | -0.702 | 0.086 | -8.194 | \< 0.001 |
| (Intercept):4 | -1.784 | 0.095 | -18.829 | \< 0.001 |
| (Intercept):5 | -1.381 | 0.080 | -17.328 | \< 0.001 |
| (Intercept):6 | -1.680 | 0.092 | -18.348 | \< 0.001 |
| (Intercept):7 | -1.103 | 0.072 | -15.365 | \< 0.001 |
| race2Others | 0.180 | 0.020 | 8.988 | \< 0.001 |
| genderMale | -0.057 | 0.020 | -2.906 | 0.00366 |
| marital_imputedNever married | 0.019 | 0.025 | 0.744 | 0.45664 |
| marital_imputedWidowed/Divorced/Separated | 0.082 | 0.023 | 3.505 | \< 0.001 |
| educ_imputed\>= College graduate | 0.199 | 0.045 | 4.376 | \< 0.001 |
| educ_imputed9-11th grade | -0.010 | 0.044 | -0.226 | 0.82128 |
| educ_imputedCollege degree | 0.127 | 0.041 | 3.102 | 0.00192 |
| educ_imputedHigh school | 0.087 | 0.041 | 2.116 | 0.03434 |

## Exploring a reviewer’s alternative

Yee et al.’s supplementary material also reports an investigation raised
by a reviewer: instead of pooling ages 12-14 and 19-21 into one inflated
group, treat 19-21 as a separate “alteration” group instead, since that
older subgroup shows a qualitatively different, declining pattern of
uptake – and correspondingly drop to an intercept-only model, matching
how the authors computed AIC for this comparison. That is one
coordinated change spanning three steps, so it belongs in a
`branch: single` alternative file. Again, you can draft a template with
[`draft_alternatives()`](../reference/template.md) and fill it in by
hand.

Click to view the alternative YAML file.

``` yaml
meta:
  type: alternatives
  branch: single
nodes:
  - overrides: special_value_mid_risk
    alternatives:
      - id: ap1921-special-value
        decision: "treat ages 12, 13, 14 only as a parametrically-inflated group, with the extra probability mass there sharing the same distributional shape (mean and dispersion) as the main population; ages 19, 20, 21 are no longer pooled into this group (see the alteration operator decision instead)"
        rationale: "ages 19-21 mark less frenetic, declining smoking uptake as respondents age out of the high-risk window, a qualitatively different pattern from the early uptake at ages 12-14, so they are moved out of this pooled inflated group"
  - overrides: alteration_operator_decision
    alternatives:
      - id: ap1921-alteration
        decision: "use ages 19, 20, 21 as an alteration group (A.mix) instead of leaving alteration operators unused"
        rationale: "ages 19-21 mark less frenetic, declining smoking uptake as respondents age out of the high-risk window, a qualitatively different pattern from the early uptake at ages 12-14, so they are represented as an alteration rather than folded into the same inflated group"
  - overrides: covariate_selection
    alternatives:
      - id: ap1921-covariates
        decision: "do not include any covariates (intercept-only model)"
        rationale: "this comparison is about which special-value structure fits better, so covariates are left out to compare the two structures on equal footing, the same way the special-value structure was first established on an intercept-only model before covariates were added"
```

``` r

alts <- read_alternatives(alt_path)
```

[`expand_tines()`](../reference/expand.md) combines the schema and the
alternative file into a two-branch multiverse: the original analysis,
and the reviewer’s suggested refit.

``` r

mv <- expand_tines(schema, alts)
mv
#> A multiverse with 2 schemas:
#>   original: (14 steps)
#>   ap1921-special-value+ap1921-alteration+ap1921-covariates: (14 steps)
```

We then used [`gen_code()`](../reference/gen_code.md) again on the refit
branch to generate an updated script (again requiring an LLM, so not
re-run here), and [`validate_script()`](../reference/validate_script.md)
confirmed it reproduces the AIC of 19,340.4 that Yee et al. report for
this comparison.

A reader who questions a choice does not need to wait for the authors to
report that comparison: they can describe their alternative in natural
language in an alternative file, and let an LLM generate and validate
the corresponding code, to see directly how the result changes.

## References

Yee, T. W., Frigau, L., & Ma, C. (2025). Heaping and seeping, GAITD
regression and doubly constrained reduced-rank vector generalized linear
models in smoking studies. *The Annals of Applied Statistics*, 19(4),
3045-3070.
