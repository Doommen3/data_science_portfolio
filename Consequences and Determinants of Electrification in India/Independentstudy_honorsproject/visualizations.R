shrug_merged <- readRDS("shrug_merged.rds")

library(tidyverse)
library(sf)
library(haven)

#pc11_shrid <- read_dta("/Users/devin/Independentstudy_honorsproject/data/shrug-vd11-dta/pc11_vd_clean_shrid.dta")
pc11_shrid <- read_csv("/Users/devin/Independentstudy_honorsproject/data/shrug-vd11-csv/pc11_vd_clean_shrid.csv")

district_shrid <- st_read("/Users/devin/Independentstudy_honorsproject/data/shrug-pc11dist-poly-gpkg/district.gpkg")
#district_key <- read_dta("/Users/devin/Independentstudy_honorsproject/data/keys/shrug-pc-keys-dta/shrid_pc11dist_key.dta")
district_key <- read_csv("/Users/devin/Independentstudy_honorsproject/data/shrug-pc-keys-csv (1)/shrid_pc11dist_key.csv")
#secc_shrid_pc11_rural <- read_dta("/Users/devin/Independentstudy_honorsproject/data/shrug-secc-cons-rural-dta/secc_cons_rural_shrid.dta")
secc_shrid_pc11_rural <- read_csv("/Users/devin/Independentstudy_honorsproject/data/shrug-secc-cons-rural-csv/secc_cons_rural_shrid.csv")
village_key <- read_csv("/Users/devin/Independentstudy_honorsproject/data/shrug-pc-keys-csv (1)/pc11r_shrid_key.csv")
village_shrid <- st_read("/Users/devin/Independentstudy_honorsproject/data/shrug-shrid-poly-gpkg (2)/shrug-pc11-village-poly-gpkg/village_modified.gpkg")
sub_dist_shrid <- st_read("/Users/devin/Independentstudy_honorsproject/data/shrug-pc11subdist-poly-gpkg/subdistrict.gpkg")
subdist_key <- read_csv("/Users/devin/Independentstudy_honorsproject/data/shrug-pc-keys-csv (1)/shrid_pc11subdist_key.csv")
#select variables and rename model using 2011 pop and 2013 economic data 
village_urban_key <- read_csv("/Users/devin/Independentstudy_honorsproject/data/shrug-pc-keys-csv (1)/pc11u_shrid_key.csv")
secc_urban_shrid <- read_csv("/Users/devin/Independentstudy_honorsproject/data/shrug-secc-cons-urban-csv/secc_cons_urban_shrid.csv")


shrid_poly <- st_read("/Users/devin/Downloads/shrug-shrid-poly-gpkg (2)/shrid2_open.gpkg")

names_key <- read_csv("/Users/devin/Downloads/shrug-shrid-keys-csv (2)/shrid_loc_names.csv")
district_key <- district_key %>%
  left_join(district_shrid) 

subdist_key <- subdist_key %>%
  left_join(sub_dist_shrid)

pc11_shrid <- secc_shrid_pc11_rural %>%
  left_join(pc11_shrid) %>%
  left_join(subdist_key)


secc_shrid_pc11_rural <- secc_shrid_pc11_rural %>%
  left_join(pc11_shrid) %>%
  left_join(subdist_key)



shrug_data <- shrug_merged %>%
  select(
    electricity_access = pc11_vd_power_all,
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

pc11_shrid %>%
  count(pc11_vd_power_all)

summary(shrug_merged$secc_cons_pc_rural)
summary(shrug_merged$secc_cons_rural)

typeof(shrug_merged$secc_cons_pc_rural)

shrug_merged %>%
  filter(pc11_vd_t_p  < 301) %>%
  summarise(Mean = mean(secc_cons_pc_rural, na.rm = TRUE))



table_access <- shrug_data %>%
  count(electricity_access == 1) %>%
  filter(complete.cases(.))

shrug_data %>%
  filter(poverty == 0)%>%
  select(village_pop, poverty, electricity_access) 
  
shrug_merged %>%
  select(district_name) %>%
  distinct() %>%
  print(n=1000)

pc11_shrid <- pc11_shrid %>%
  left_join(names_key)


pc11_shrid <- pc11_shrid %>%
  select(shrid2, subdistrict_name, pc11_subdistrict_id, pc11_vd_power_all)

test <- pc11_shrid %>%
  group_by(subdistrict_name)
  
test <- test %>%
  select(shrid2, pc11_vd_power_all, subdistrict_name, pc11_subdistrict_id)

test <- test %>%
  distinct(mean_cons)

test <- test %>%
  left_join(sub_dist_shrid) %>%
  st_as_sf()

test %>%
  ggplot() +
  geom_sf(aes(fill = pc11_vd_power_all)) +
  coord_sf(lims_method = "geometry_bbox")



village_key <- village_key %>%
  rename("pc11_id" = pc11_village_id)

pc11_shrid <- pc11_shrid %>%
  left_join(secc_shrid_pc11_rural) %>%
  left_join(village_key)

village_test <- pc11_shrid %>%
  group_by(pc11_id) %>%
  mutate(mean_cons = mean(secc_cons_pc_rural, na.rm = TRUE)) 

village_test <- village_test %>%
  select(shrid2, pc11_vd_power_all, pc11_id)


village_shrid <- village_shrid %>%
  rename("pc11_village_id" = pc11_town_village_id)


village_test <- village_test %>%
  select(shrid2, pc11_vd_power_all, pc11_id)



village_test <- village_test %>%
  left_join(shrid_poly) %>%
  st_as_sf()

village_test <- village_test %>%
  select(shrid2, pc11_vd_power_all, pc11_id)

map <- village_test %>%
  ggplot() +
  geom_sf(aes(fill = pc11_vd_power_all)) +
  scale_fill_viridis_b()

ggsave("powermap.tiff", map)





pc11_shrid <- pc11_shrid %>%
  left_join(secc_urban_shrid, by = "shrid2")



secc_urban_shrid %>%
  summarize(sum_na = sum(is.na(secc_cons_pc_urban)))




village_urban_test <- pc11_shrid %>%
  mutate(mean_cons = secc_cons_pc_urban)


na_col <- is.na(village_urban_test$mean_cons)

sum(na_col == TRUE)

village_urban_test <- village_urban_test %>%
  select(shrid2, mean_cons, pc11_town_id)

count <- village_urban_test %>%
  summarize(non_missing = sum(!is.na(mean_cons) & !is.nan(mean_cons)))


village_urban_test <- village_urban_test %>%
  rename("pc11_id" = pc11_town_id)


village_urban_test <- village_urban_test %>%
  select(shrid2, mean_cons, pc11_id)

village_urban_test <- village_urban_test %>%
  distinct(shrid2, mean_cons, pc11_id)

village_urban_test <- village_urban_test %>%
  left_join(village_shrid) %>%
  st_as_sf()

village_urban_test <- village_urban_test %>%
  select(shrid2, mean_cons, pc11_town_id)

map_2 <- village_urban_test %>%
  ggplot() +
  geom_sf(aes(fill = mean_cons)) +
  scale_fill_viridis_b(
    direction = -1, 
    breaks = seq(0, max(village_urban_test$mean_cons,
                        na.rm = TRUE),
                 by = 10000))

ggsave("testmap_urban.tiff", map_2)

path <- pc11_shrid %>%
  filter(shrid2 == "11-32-599-05682-803304")


village_shrid %>%
  filter(pc11_town_village_id == "628334")

pc11_shrid$pc11_id








subdist_key <- subdist_key %>%
  left_join(sub_dist_shrid)


pc11_shrid <- pc11_shrid %>%
  left_join(secc_shrid_pc11_rural) %>%
  left_join(subdist_key)



pc11_shrid$total <- rowSums(pc11_shrid[, c("pc11_vd_power_dom", "pc11_vd_power_agr", "pc11_vd_power_com")])



pc11_shrid <- pc11_shrid %>%
  select(shrid2, subdistrict_name, pc11_subdistrict_id, pc11_vd_power_all, total)



pc11_shrid <- pc11_shrid %>%
  group_by(pc11_subdistrict_id) %>%
  mutate(avg_powerall = mean(total, na.rm = TRUE))


pc11_shrid <- pc11_shrid %>%
  select(shrid2, avg_powerall, subdistrict_name, pc11_subdistrict_id)

pc11_shrid <- pc11_shrid %>%
  distinct(pc11_subdistrict_id, subdistrict_name, avg_powerall)

pc11_shrid <- pc11_shrid %>%
  left_join(sub_dist_shrid) %>%
  st_as_sf()

pc11_shrid %>%
  ggplot() +
  geom_sf(aes(fill = avg_powerall)) +
  scale_fill_viridis_c()


pc11_shrid %>%
  filter(avg_powerall == 1) %>%
  ggplot() +
  geom_sf(aes(fill = avg_powerall)) 
