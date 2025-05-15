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




# consumption as outcome
model2 <- lm(consumption ~ electricity_access + income_5k + power_summerhrs +
               poverty + females + I(females * poverty) + own_land, data = shrug_data)

summary(model2)
