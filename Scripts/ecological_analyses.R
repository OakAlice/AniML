# Have prepared some very basic ecological analyses -----------------------

generate_ecological_plots <- function(preds, palette){
  
  # activity budgets basic
  counts <- preds %>% 
    mutate(Hour = hour(Time)) %>% 
    group_by(Hour) %>%
    dplyr::count(smoothed_class) %>%
    mutate(Proportion = n / sum(n)) %>%
    ungroup()
  
  budget <- ggplot(counts, aes(x = as.factor(Hour), y = Proportion, fill = smoothed_class)) +
    geom_col(position = "stack") +
    scale_fill_manual(values = palette) + 
    my_theme() + 
    labs(x = "Hour", y = "Proportion", fill = "Behaviour")
  
  # a day in the life
  day_data <- preds %>% dplyr::filter(as.Date(Time) == unique(as.Date(preds$Time))[1]) %>% 
    mutate(Hour = hour(Time)) %>%
    group_by(Hour) %>%
    mutate(Minutes = row_number()/30)
  
  day_in_a_life <- ggplot(day_data, aes(x = Minutes, y = Hour, fill = smoothed_class))+
    geom_tile() + 
    scale_fill_manual(values = palette) + 
    my_theme() + 
    labs(x = "Minute", y = "Hour", fill = "Behaviour")
  
  return(list(budget = budget,
              day_in_a_life = day_in_a_life))
  
}
