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
library(sandwich)

# select variables and rename model using 2011 pop and 2013 economic data 
shrug_data <- shrug_merged %>%
  select(
    electricity_access = pc11_vd_power_all,
    electricity_agg = pc11_vd_power_agr,
    electricity_comm = pc11_vd_power_com,
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
  mutate(across(c(poverty, power_summerhrs, consumption, females, own_land, income_5k, electricity_access),
                list(centered = ~ . - mean(., na.rm = TRUE),
                     standardized = ~(. - mean(., nar.rm = TRUE)) / sd(., na.rm = TRUE))))




summary(model2)



# consumption as outcome
model1 <- lm(log(consumption) ~ electricity_access + income_5k_centered +
               poverty_centered + females_centered + I(females_centered * poverty_centered) + own_land_centered, data = shrug_data)

summary(model1)


stargazer(model1,
          type="latex",
          dep.var.labels = c("Consumption Per Capita"),
          covariate.labels = c("Electricity Access", "HH Income - 5k", "Poverty",
                               "Proportion Female", "Proportion Female x Poverty", 
                               "Proportion Own Land", ("Constant")),
          title = "Regression Results",
          align = TRUE,
          no.space = TRUE)



shrug_merged %>%
  mutate(electricity_domestic = pc11_vd_power_dom,
         electricity_ag = pc11_vd_power_agr,
         electricity_comm = pc11_vd_power_com,
         electricity_all = pc11_vd_power_all)%>%
  summarize(sum_dom = sum(electricity_domestic, na.rm = TRUE),
            sum_ag = sum(electricity_ag, na.rm = TRUE),
            sum_com = sum(electricity_comm, na.rm = TRUE),
            sum_all = sum(electricity_all, na.rm = TRUE))

# consumption as outcome
model2 <- lm(log(consumption) ~ electricity_comm + income_5k_centered +
               poverty_centered + females_centered + I(females_centered * poverty_centered) + own_land_centered, data = shrug_data)

summary(model2)

stargazer(model2,
          type="latex",
          dep.var.labels = c("Consumption Per Capita"),
          covariate.labels = c("Electricity Access - Comm", "HH Income - 5k", "Poverty",
                               "Proportion Female", "Proportion Female x Poverty", 
                               "Proportion Own Land", ("Constant")),
          title = "Regression Results",
          align = TRUE,
          no.space = TRUE)


coeftest(model2, vcov. = vcovHC(model2, type = "HC1"))


# consumption as outcome
model3 <- lm(log(consumption) ~ electricity_domestic + income_5k_centered +
               poverty_centered + females_centered + I(females_centered * poverty_centered) + own_land_centered, data = shrug_data)

summary(model3)


stargazer(model3,
          type="latex",
          dep.var.labels = c("Consumption Per Capita"),
          covariate.labels = c("Electricity Access - Domestic", "HH Income - 5k", "Poverty",
                               "Proportion Female", "Proportion Female x Poverty", 
                               "Proportion Own Land", ("Constant")),
          title = "Regression Results",
          align = TRUE,
          no.space = TRUE)



model4 <- lm(log(consumption) ~ electricity_agg + income_5k_centered + power_summerhrs_centered +
               poverty_centered + females_centered + I(females_centered * poverty_centered) + own_land_centered, data = shrug_data)

summary(model4)



stargazer(model2, model3, model4,
          type="latex",
          covariate.labels = c("Commercial Sector", "Domestic", "Aggriculture",
                               "Electricity Access", "HH Income - 5k", "Summer Power (Hours)", "Poverty",
                               "Proportion Female", "Proportion Female x Poverty"),
          title = "Regression Models",
          align = TRUE,
          no.space = TRUE,
          digits =  3,
          omit.stat = c("f", "ser", "N"))


residual_data <- data.frame(
  Fitted = fitted(model2),
  Residuals = residuals(model2)
)


ggplot(residual_data, aes(x = Fitted, y = Residuals)) +
  geom_point(alpha = 0.6) +  # Scatter plot
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +  # Horizontal line
  labs(title = "Residual Plot",
       x = "Fitted Values",
       y = "Residuals") +
  theme_minimal()

