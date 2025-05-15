shrug_merged <- readRDS("shrug_merged.rds")

library(tidyverse)
library(haven)
library(lmtest)
library(car)
library(sf)
library(pscl)
library(rmapshaper)
library(modelsummary)
library(stargazer)
library(whitestrap)


# select variables and rename model using 2011 pop and 2013 economic data 
shrug_data <- shrug_merged %>%
  select(
    electricity_access = pc11_vd_power_all,
    electricity_domestic = pc11_vd_power_dom,
    consumption = secc_cons_pc_rural,
    power_summerhrs = pc11_vd_power_all_sum,
    power_winterhrs = pc11_vd_power_all_win,
    own_land = land_own_share,
    electricity_domestic = pc11_vd_power_dom,
    females = pc11_vd_t_f / pc11_vd_t_p,
    literacy_rate = pc11_pca_p_lit / pc11_pca_tot_p,
    remote_10k = tdist_10, 
    income_5k = inc_5k_plus_share,
    remote_50k = tdist_50,
    poverty = secc_pov_rate_rural,
    remote_500k = tdist_500, 
    village_pop = pc11_vd_t_p, 
    village_male = pc11_vd_t_m,
    scheduled_pop = pc11_pca_p_sc)
shrug_data <- shrug_data %>% drop_na()



shrug_data <- shrug_data %>%
  mutate(across(c(poverty, power_summerhrs, consumption, females),
                list(centered = ~ . - mean(., na.rm = TRUE),
                     standardized = ~(. - mean(., nar.rm = TRUE)) / sd(., na.rm = TRUE))))


# model with electricity for all users as dependent variable for 2011 data 
model <- lm(electricity_access ~ consumption + literacy_rate + remote_50k + remote_500k
               + 
              scheduled_pop, data = shrug_data)
predictions <- predict(model, newdata = shrug_data)
shrug_data$predicted <- predictions

summary(model) 
bptest(model)

coeftest(model, vcov = hccm)

# consumption as outcome
model2 <- lm(consumption ~ electricity_access + income_5k +
               poverty + females + I(females * poverty) + own_land, data = shrug_data)

summary(model2)

vif(model2)

# electricity access as outcome 
model3 <- glm(electricity_access ~  poverty +
                log(village_pop) + remote_10k, data = shrug_data, family = "binomial")

summary(model3)

vif(model3)


model4 <- lm(consumption ~ electricity_domestic + income_5k + power_summerhrs +
               poverty + females + I(females * poverty), data = shrug_data)


summary(model4)

vif(model4)


logistic_model2 <- glm(electricity_access ~ females + consumption,
                       data=shrug_data, family = binomial(link ="logit"))


shrug_merged %>%
  group_by(subdistrict_name) %>%
  transmute(mean = mean(pc11_vd_t_hh)) %>%
  distinct()


summary(shrug_merged$pc11_vd_power_all_sum)

shrug_merged %>%
  filter(pc11_vd_power_all_sum < 5) %>%
  select(state_name) %>%
  distinct() %>%
  print(n=100)

stargazer(model2,
          type="latex",
          dep.var.labels = c("Consumption Per Capita"),
          covariate.labels = c("Electricity Access", "Income - 5k", "Poverty", "Female", "Females x Poverty", ("Constant")),
          title = "Regression Results",
          align = TRUE,
          no.space = TRUE)

white_test(model2)
bptest(model2)


