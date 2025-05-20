devtools::install_github("josedv82/bdgramR")
library(bdgramR)
library(tidyverse)
library(readxl)


# load the model of the anatomical image 
model <- bdgramr(data = data, model = "futuristic_male")

#load the data set that contains the weeks workouts 
muscle_frame <- read_xlsx("data/weekly_Exercise_data.xlsx")

# turn the data set into a data frame 
muscle_frame <- as.data.frame(muscle_frame)

# Remove the Group colum from the muscle frame data set 
muscle_frame <- muscle_frame %>%
  select(-Group)

# Create a data set that keeps only unique muscle and group pairs 
distinct_data_merge <- distinct(model, Muscle, Group)

#merge the data set with the muscle and groups, remove secondary muscle column
merge_frame_test <- muscle_frame %>%
  select(-Secondary_Muscle) %>%
  left_join(distinct_data_merge, by = "Muscle")

# Create a data frame that removes the muscle column 
muscle_frame_test_two <- muscle_frame %>%
  select(-Muscle)

# create a data frame that renames the secondary muscle column and merges with muscles and groups
# data set 
merge_frame_test_two <- muscle_frame_test_two %>%
  rename(Muscle = Secondary_Muscle) %>%
  left_join(distinct_data_merge, by = "Muscle")

# merge the combined data sets completely 
muscle_data <- merge_frame_test %>%
  union_all(merge_frame_test_two)
  
# create a data set that computes the sum of total reps 
muscle_data <- muscle_data %>%
  mutate(total_weekly_reps = sum(Total_reps))

# turn the total reps column into a numeric value 
muscle_frame$Total_reps <- as.numeric(muscle_frame$Total_reps)

# make a data frame that computes weekly reps and calculates percent used 
#group by muscle 
muscle_data <- muscle_data %>%
  mutate(total_weekly_reps = sum(Total_reps, na.rm = TRUE),
         Percent_used = Total_reps/total_weekly_reps) %>%
  group_by(Muscle) %>%
  mutate(group_percent = sum(Percent_used))

# creat a data frame that joins muscle and data data sets 
data <- model %>%
  left_join(muscle_data)
         


# create a plot that uses the id column as an identifier, the body parts are filled by 
# the group_percent column 
muscle_plot <- data %>%
  ggplot(aes(x,y, group = Id)) +
  geom_bdgramr(color = "cyan", aes(fill = group_percent)) +
  scale_fill_gradient(low = "lightcyan", high = "darkcyan") +
  ggtitle("EVO Workout Volume")

# print the plot 
muscle_plot



