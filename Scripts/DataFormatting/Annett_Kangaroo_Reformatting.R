# Code for Jaz's data to go here ------------------------------------------

data <- fread(file.path("Data", "Annett_Kangaroo", "raw.csv")) %>%
  mutate(Activity = dplyr::coalesce(eco_behaviour, funct_behaviour, mech_behaviour)) %>%
  dplyr::select(-c(eco_behaviour, funct_behaviour, mech_behaviour)) %>%
  rename(ID = Individual) %>%
  na.omit()

fwrite(data, file.path("Data", "Annett_Kangaroo", "Formatted_raw_data.csv"))



dat <- data %>% dplyr::filter(Activity == "Pentapedling") %>%
  mutate(row = row_number())
ggplot(dat, aes(x = row)) +
  geom_path(aes(y = X, colour = "X")) + 
  geom_path(aes(y = Y, colour = "Y")) + 
  geom_path(aes(y = Z, colour = "Z")) + 
  my_theme()
