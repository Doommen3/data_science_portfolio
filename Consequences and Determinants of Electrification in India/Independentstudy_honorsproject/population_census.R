library(tidyverse)
library(haven)
library(lmtest)
library(car)
library(sf)
library(pscl)
library(rmapshaper)
#load necessary datas ets 

# load population data sets for 91, 2001, and 2011 
pc11_shrid <- read_dta("/Users/devin/Independentstudy_honorsproject/data/shrug-vd11-dta/pc11_vd_clean_shrid.dta")
pc01_shrid <- read_dta("/Users/devin/Independentstudy_honorsproject/data/shrug-vd01-dta/pc01_vd_clean_shrid.dta")
pc91_shrid <- read_dta("/Users/devin/Independentstudy_honorsproject/data/shrug-vd91-dta/pc91_vd_clean_shrid.dta")

pc11_town_shrid <- read_csv("/Users/devin/Independentstudy_honorsproject/data/shrug-td11-csv/pc11_td_clean_shrid.csv")

pc11_pca <- read_dta("/Users/devin/Independentstudy_honorsproject/data/shrug-pca11-dta/pc11_pca_clean_shrid.dta")

#pc11_td <- read_dta("/Users/devin/Independentstudy_honorsproject/data/shrug-td11-dta/pc11_td_clean_shrid.dta")

#secc_pc11_subdist <- read_dta("/Users/devin/Independentstudy_honorsproject/data/shrug-secc-cons-urban-dta/secc_cons_urban_pc11subdist.dta")

pc11_subdistkey <- read_dta("/Users/devin/Independentstudy_honorsproject/data/keys/shrug-pc-keys-dta/shrid_pc11subdist_key.dta")

#viirs_key <- read_dta("/Users/devin/Independentstudy_honorsproject/data/keys/shrug-shrid-keys-dta/viirs_2023_7_5_500_ua_shrid2_key.dta")

shrid2_spatialstats <- read_dta("/Users/devin/Independentstudy_honorsproject/data/keys/shrug-shrid-keys-dta/shrid2_spatial_stats.dta")

# add names to data 
shrid_names <- read_dta("/Users/devin/Independentstudy_honorsproject/data/keys/shrug-shrid-keys-dta/shrid_loc_names.dta")

#pmgsy <- read_dta("/Users/devin/Independentstudy_honorsproject/data/shrug-pmgsy-dta/pmgsy_2015_shrid.dta")

#secc_pc11dist_urban <- read_dta("/Users/devin/Independentstudy_honorsproject/data/shrug-secc-cons-urban-dta/secc_cons_urban_pc11dist.dta")
#secc_pc11dist_rural <- read_dta("/Users/devin/Independentstudy_honorsproject/data/shrug-secc-cons-rural-dta/secc_cons_rural_pc11dist.dta")

secc_shrid_pc11_urban <- read_dta("/Users/devin/Independentstudy_honorsproject/data/shrug-secc-cons-urban-dta/secc_cons_urban_shrid.dta")
secc_shrid_pc11_rural <- read_dta("/Users/devin/Independentstudy_honorsproject/data/shrug-secc-cons-rural-dta/secc_cons_rural_shrid.dta")
#ec13shrid <- read_dta("/Users/devin/Independentstudy_honorsproject/data/shrug-ec13-dta/ec13_shrid.dta")

secc_parsed_shrid_urban <- read_dta("/Users/devin/Independentstudy_honorsproject/data/shrug-secc-parsed-urban-dta/secc_urban_shrid.dta")
secc_mord_shrid_rural <- read_dta("/Users/devin/Independentstudy_honorsproject/data/shrug-secc-mord-rural-dta/secc_rural_shrid.dta")

village_poly <- read_sf("/Users/devin/Independentstudy_honorsproject/data/shrug-pc11-village-poly-gpkg/village_modified.gpkg")
shrug_poly <- read_sf("/Users/devin/Independentstudy_honorsproject/data/shrug-shrid-poly-gpkg (2)/shrid2_open.gpkg")
subdist_poly <- read_sf("/Users/devin/Independentstudy_honorsproject/data/shrug-pc11subdist-poly-gpkg/subdistrict.gpkg")

# merge 2011 census and 2001 census 
shrug_merged <- pc11_shrid %>%
  left_join(pc01_shrid, by="shrid2")


# merge 1991 census 
shrug_merged <- shrug_merged %>%
  left_join(pc91_shrid, by="shrid2")

# add names for shrids 
shrug_merged <- shrug_merged %>%
  left_join(shrid_names, by="shrid2")


# add data for SECC economic data for urban areas
shrug_merged <- shrug_merged %>%
  left_join(secc_shrid_pc11_urban, by="shrid2")

# add data for secc for rural areas 
shrug_merged <- shrug_merged %>%
  left_join(secc_shrid_pc11_rural, by="shrid2")

# add spatial data 
shrug_merged <- shrug_merged %>%
  left_join(shrid2_spatialstats, by="shrid2")

shrug_merged <- shrug_merged %>%
  left_join(pc11_pca, by = "shrid2")

shrug_merged <- shrug_merged %>%
  left_join(secc_mord_shrid_rural, by = "shrid2")

locations <- shrug_merged %>%
  left_join(shrug_poly) %>%
  st_as_sf()


locations_subdist <- pc11_subdistkey %>%
  left_join(subdist_poly) %>%
  st_as_sf()

locations_subdist <- locations_subdist %>%
  left_join(pc11_shrid)


#shrug_merged <- shrug_merged %>%
#  left_join(secc_parsed_shrid_urban, by = "shrid2")


# select variables and rename model using 2011 pop and 2013 economic data 
shrug_data <- shrug_merged %>%
  select(
    electricity_access = pc11_vd_power_all,
    consumption = secc_cons_pc_rural,
    electricity_domestic = pc11_vd_power_dom,
    females = pc11_vd_t_f / pc11_vd_t_p,
    literacy_rate = pc11_pca_p_lit / pc11_pca_tot_p,
    remote_10k = tdist_10, 
    remote_50k = tdist_50,
    remote_500k = tdist_500, 
    village_pop = pc11_vd_t_p, 
    village_male = pc11_vd_t_m,
    scheduled_pop = pc11_pca_p_sc,
  )


shrug_data %>%
  summarise(mean(electricity_access))


# model using 2001 data 
shrug_data2 <- shrug_merged %>%
  select(
    shrid = shrid2,
    power_supply = pc01_vd_power_supl,
    area = pc01_vd_area,
    total_income = pc01_vd_tot_inc,
    expenditure = pc01_vd_tot_exp,
    electricity_access = pc01_vd_power_all,
    consumption = secc_cons_pc_rural,
    #literacy_rate = pc11_pca_p_lit / pc11_pca_tot_p,
    #remote_10k = tdist_10, 
    #remote_50k = tdist_50,
    #remote_500k = tdist_500, 
    #own_land_rural = land_own_share, 
    #homeless = house_type3, 
    #ownhome = house_own1,
    #begging = inc_source_beg_share,
    village_pop = pc01_vd_t_p, 
    village_male = pc01_vd_t_m,
    #rural_poverty = secc_pov_rate_rural
    scheduled = pc01_vd_sc_p
  )

shrug_merged$tot_p

# select variables and rename model using 2011 pop and 2013 economic data 
shrug_data3 <- shrug_merged %>%
  select(
    electricity_access = pc11_vd_power_all,
    electricity_domestic = pc11_vd_power_dom,
    literacy_rate = pc11_pca_p_lit / pc11_pca_tot_p,
    remote_10k = tdist_10, 
    remote_50k = tdist_50,
    remote_500k = tdist_500, 
    village_pop = pc11_vd_t_p, 
    village_male = pc11_vd_t_m,
    scheduled_pop = pc11_pca_p_sc,
    
  )


secc_parsed_shrid_urban %>%
  filter(light_source1 < .85) %>%
  summarize(n = n())

# drop na values from the data 
shrug_data <- shrug_data %>% drop_na()
shrug_data2 <- shrug_data2 %>% drop_na()


# View summary statistics
summary(shrug_data)

# model with electricity for all users as dependent variable for 2011 data 
model <- lm(electricity_access ~ consumption + literacy_rate + remote_50k + remote_500k + 
              own_land_rural + homeless + ownhome + begging + 
              scheduled_pop + rural_poverty, data = shrug_data)



predictions <- predict(model, newdata = shrug_data)
shrug_data$predicted <- predictions

summary(model) 
bptest(model)

coeftest(model, vcov = hccm)

# model with electricity for domestic use as dependent variable for 2011 data 
model2 <- lm(electricity_domestic ~ consumption + literacy_rate + remote_10k + remote_500k + 
                        own_land_rural + homeless + ownhome + begging + village_pop + village_male, data = shrug_data)
summary(model2)



# model with electricity for all users as dependent variable for 2001 data 
model3 <- lm(electricity_access ~  village_pop + village_male + scheduled + area + total_income + expenditure + consumption, data = shrug_data2)

summary(model3)

coeftest(model3, vcov = hccm)


logistic_model <- glm(electricity_access ~ consumption + literacy_rate + remote_10k + remote_500k + 
              own_land_rural + homeless + ownhome + begging + village_pop + village_male, data = shrug_data, family = "binomial")

logistic_model2 <- glm(electricity_access ~ consumption + literacy_rate + remote_50k + remote_500k + 
              own_land_rural + homeless + ownhome + begging + 
              scheduled_pop + rural_poverty, data = shrug_data, family = binomial(link = "logit"))

logistic_model2 <- glm(electricity_access ~ females + consumption,
                       data=shrug_data, family = binomial(link ="logit"))
 

summary(logistic_model)
summary(logistic_model2)

predictions <- predict(logistic_model2, newdata = shrug_data, type = "response")
shrug_data$predicted <- predictions

ggplot(shrug_data, aes(x=I(rural_poverty * females), y=predicted)) +
  geom_point(alpha=.3) +
  geom_smooth(method="glm") +
  theme_minimal()


pR2(logistic_model)

vif(logistic_model)

shrug_merged <- shrug_merged %>%
  mutate(year = paste0("20", str_extract(shrid2, "^[^-]+")))

shrug_merged %>%
  distinct(year)

saveRDS(shrug_merged, "shrug_merged.rds") 


pc11_pca$pc11_pca_tot_p



village_key$pc11_village_id

shrug_merged <- shrug_merged %>%
  left_join(village_key)

shrug_merged %>%
  select(pc11_vd_t_p, tot_p) %>%
  mutate(difference = pc11_vd_t_p - tot_p) %>%
  summarize(min = min(difference, na.rm = TRUE),
            max = max(difference, na.rm = TRUE))



test_data <- shrug_merged %>%
  arrange(desc((pc11_vd_t_p))) 

shrug_merged %>%
  filter(pc11_vd_t_p > tot_p)

