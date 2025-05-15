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
library(scales)


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





str(shrug_data[, c("electricity_access", "income_5k", "power_summerhrs", 
                   "poverty", "females", "own_land")])



shrug_data$column_name <- as.numeric(shrug_data$electricity_access)
shrug_data$column_name <- as.numeric(shrug_data$electricity_domestic)
shrug_data$column_name <- as.numeric(shrug_data$electricity_agg)
shrug_data$column_name <- as.numeric(shrug_data$electricity_comm)
shrug_data$column_name <- as.numeric(shrug_data$income_5k)
shrug_data$column_name <- as.numeric(shrug_data$power_summerhrs)
shrug_data$column_name <- as.numeric(shrug_data$poverty)
shrug_data$column_name <- as.numeric(shrug_data$females)
shrug_data$column_name <- as.numeric(shrug_data$own_land)

colSums(is.na(shrug_data[, c("electricity_access", "income_5k", "power_summerhrs", 
                             "poverty", "females", "own_land")]))


subset_data <- as.data.frame(shrug_data[, c("electricity_access", "electricity_domestic", "electricity_agg",
                                            "electricity_comm",
                                            "income_5k", "power_summerhrs", "poverty", 
                                            "females", "own_land")])




stargazer(subset_data,
          type="latex",
          summary.stat = c("mean", "sd", "min", "max"),
          covariate.labels = c("Electricity Access - All","Electricity - Domestic",
                              "Electricity - Agg", "Electricity - Commercial",  "HH Income - 5k", "Summer Power (Hours)", "Poverty",
                               "Proportion Female", "Proportion Own Land"),
          title = "Summary Statistics",
          digits = 2)



ggplot(shrug_data, aes(x = power_summerhrs)) +
  geom_histogram(binwidth = 1, color = "black", fill = "blue") +
  labs(title = "Distribution of Power Availability (Hours)",
       x = "Number of Hours of Power",
       y = "Frequency") +
  theme_minimal()


electricity_table <- shrug_data %>%
  select(electricity_agg, electricity_comm, electricity_domestic) %>%
  pivot_longer(cols = starts_with("electricity"),
               names_to = "electricity_type", 
               values_to = "electricity_status")

electricity_table <- electricity_table %>%
  filter(electricity_status == 1) %>%
  count(electricity_type) %>%
  rename(count = n)

electricity_table <- electricity_table %>%
  mutate(electricity_type = case_when(
    electricity_type == "electricity_domestic" ~ "Domestic Electricity",
    electricity_type == "electricity_comm" ~ "Commercial Electricity",
    electricity_type == "electricity_agg" ~ "Aggricultural Electricity",
    TRUE ~ electricity_type
  ))

electricity_table %>%
  ggplot(aes(x=electricity_type, y = count, fill = electricity_type)) + 
  geom_bar(stat = "identity", position = "dodge") +
  scale_y_continuous(labels = comma) +
  labs(title = "Count of Areas with Electricity Type - 2011",
       x = "Electricity Type",
       y = "Count",
       fill = "Electricity Type") + 
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 90, vjust = .5, hjust = 1))
plot
