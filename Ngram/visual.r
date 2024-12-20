
library(readxl)
library(dplyr)
library(stringr)

library(colorspace)
library(colorBlindness)
library(rcartocolor)
library(ggrepel)
library(ggplot2)
library(tools)
library(patchwork)


# Load spreadsheet
df1 <- read_excel('all_results_10000_year_final.xlsx', sheet = 'Sheet1')

# Replace 'N-Gram' column values
df1$`N-Gram` <- str_replace_all(df1$`N-Gram`, c("financial institution" = "Financ* institution", "finance institution" = "Financ* institution",
                                                'financial system'='Financial system', 'financial risk'='Financial risk', 'financial disclosure'='Financial disclosure'))
df1$`N-Gram` <- str_replace_all(df1$`N-Gram`, c("financial sector" = "Financ* sector", "finance sector" = "Financ* sector", 'conservation finance'='Conservation finance',
                                                'sustainable finance' ='Sustainable finance','climate finance'= 'Climate finance', 'green finance'='Green finance'))
df1$`N-Gram` <- str_replace_all(df1$`N-Gram`, c("biodiversity finance" = "Biodiversity financ*", "biodiversity financing" = "Biodiversity financ*"))
df1$`N-Gram` <- str_replace_all(df1$`N-Gram`, c("conserving biodiversity" = "Conserv* biodiversity", "conserve biodiversity" = "Conserv* biodiversity"))
df1$`N-Gram` <- str_to_sentence(df1$`N-Gram`)

# Sum the 'Frequency' column grouped by 'N-gram type', 'N-Gram', and 'Subfolder'
df1 <- df1 %>%
    group_by(`N-gram type`, `N-Gram`, Subfolder) %>%
    summarise(Frequency = sum(Frequency), .groups = 'drop')  # Add .groups = 'drop'

# Create a list of N-Gram values
ngram_values <- c('Financ* institution', 'Financ* sector', 'Financial system', 'Financial risk', 'Financial disclosure')

# Create a new DataFrame for rows where 'N-Gram' is in ngram_values
finance_ <- df1[df1$`N-Gram` %in% ngram_values,]

View(finance_)

finance_$Subfolder <- as.numeric(finance_$Subfolder)

finance_$label <- NA

finance_$label[which(finance_$Subfolder == max(finance_$Subfolder))] <- finance_$`N-Gram`[which(finance_$Subfolder == max(finance_$Subfolder))] 
p <- ggplot(finance_, aes(x = Subfolder, y = Frequency, group = `N-Gram`)) +
     geom_line(color='grey')
safe_colorblind_palette <- c("#88CCEE", "#CC6677", "#DDCC77", "#117733", "#332288", "#AA4499", 
                             "#44AA99", "#999933", "#882255", "#661100", "#6699CC", "#888888")

p + geom_smooth(method = "gam", formula = y ~ s(x, k = 6),alpha = .15,aes(fill = `N-Gram`, color = `N-Gram`))+
  theme_minimal()+
  scale_fill_carto_d(palette = "ag_Sunset") + 
  scale_color_carto_d(palette = "ag_Sunset") +
  geom_label_repel(aes( 
    label = label, fill=`N-Gram`), color = 'white',size=4,nudge_x =1, na.rm = TRUE)+
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.x = element_line(),  # Keep major vertical grid lines
        panel.grid.minor.x = element_blank(),  # Remove minor vertical grid lines
        axis.title.x = element_blank(),  # Remove x-axis label
        axis.title.y = element_blank(),
        axis.text = element_text(size = 10),plot.title = element_text(hjust = 0, vjust =1, size = 12)) +  # Title in the top-left corner
  ggtitle("finance_")+
  theme(legend.position="none")

ngram_values <- c(
'Biodiversity financ*','Conservation finance', 'Sustainable finance', 'Climate finance','Green finance')
# Create a new DataFrame for rows where 'N-Gram' is in ngram_values
finance_2 <- df1[df1$`N-Gram` %in% ngram_values,]

View(finance_)

finance_$Subfolder <- as.numeric(finance_$Subfolder)

finance_$label <- NA

finance_$label[which(finance_$Subfolder == max(finance_$Subfolder))] <- finance_$`N-Gram`[which(finance_$Subfolder == max(finance_$Subfolder))] 


library(patchwork)
max_y_value <- NA  # Set your desired maximum y-axis value
text_repel = 5.5
axis_text = 14
title_size = 20
vjust = 1
nudge_x= 1
color_code= hcl.colors(6,"Rocket")

# Your code for the first plot
ngram_values_1 <- c('Financ* institution', 'Financ* sector', 'Financial system', 'Financial risk', 'Financial disclosure')
finance_1 <- df1[df1$`N-Gram` %in% ngram_values_1,]
finance_1$Subfolder <- as.numeric(finance_1$Subfolder)

finance_1 <- finance_1 %>%
  group_by(`N-Gram`) %>%
  do({
    model <- gam(Frequency ~ s(Subfolder, k = 3), data = .)
    predictions <- predict(model, newdata = data.frame(Subfolder = max(.$Subfolder)))
    data.frame(., Predicted = predictions)
  }) %>%
  ungroup()

# Add labels to the last point in each group
finance_1 <- finance_1 %>%
  group_by(`N-Gram`) %>%
  mutate(label = if_else(Subfolder == max(Subfolder), as.character(`N-Gram`), NA_character_)) %>%
  ungroup()

finance_1 <- arrange(finance_1, desc(Predicted))

n_gram_levels <- finance_1 %>%
  distinct(`N-Gram`) %>%
  pull(`N-Gram`)

# Step 2: Set N-Gram as an ordered factor
finance_1$`N-Gram` <- factor(finance_1$`N-Gram`, levels = n_gram_levels)

plot1 <- ggplot(finance_1, aes(x = Subfolder, y = Frequency, group = `N-Gram`)) +
  geom_line(color = 'grey') +
  geom_smooth(method = "gam", formula = y ~ s(x, k = 3), alpha = .15, aes(fill = `N-Gram`, color = `N-Gram`)) +
  theme_minimal() +
  scale_color_manual(values=color_code)+
  scale_fill_manual(values=color_code)+
  geom_text_repel(aes(label = label, y=Predicted, color = `N-Gram`), size = text_repel, fontface = "bold", vjust=1, nudge_x = nudge_x,direction = "y", hjust = "left",
                  segment.size = 0.2,
                  segment.color = "#00000030") +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.x = element_line(),  # Keep major vertical grid lines
        panel.grid.minor.x = element_blank(),  # Remove minor vertical grid lines
        panel.border = element_rect(linetype = "solid", fill = NA),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text = element_text(size = axis_text),
        plot.title = element_text(hjust = 0, vjust =vjust, size = title_size)) +
  ggtitle("finance_") +
  theme(legend.position = "none")+
  coord_cartesian(ylim = c(0, max_y_value))+
  scale_x_continuous(breaks = seq(2000, 2022, 5), limits = c(2000, 2035)) +
  guides(colour = FALSE, lty = FALSE) 
print(plot1)

# Your code for the second plot
ngram_values_2 <- c('Biodiversity financ*', 'Conservation finance', 'Sustainable finance', 'Climate finance', 'Green finance')
finance_2 <- df1[df1$`N-Gram` %in% ngram_values_2,]
finance_2$Subfolder <- as.numeric(finance_2$Subfolder)
finance_2 <- finance_2 %>%
  group_by(`N-Gram`) %>%
  do({
    model <- gam(Frequency ~ s(Subfolder, k = 3), data = .)
    predictions <- predict(model, newdata = data.frame(Subfolder = max(.$Subfolder)))
    data.frame(., Predicted = predictions)
  }) %>%
  ungroup()

# Add labels to the last point in each group
finance_2 <- finance_2 %>%
  group_by(`N-Gram`) %>%
  mutate(label = if_else(Subfolder == max(Subfolder), as.character(`N-Gram`), NA_character_)) %>%
  ungroup()

finance_2 <- arrange(finance_2, desc(Predicted))

n_gram_levels <- finance_2 %>%
  distinct(`N-Gram`) %>%
  pull(`N-Gram`)

# Step 2: Set N-Gram as an ordered factor
finance_2$`N-Gram` <- factor(finance_2$`N-Gram`, levels = n_gram_levels)

plot2 <- ggplot(finance_2, aes(x = Subfolder, y = Frequency, group = `N-Gram`)) +
  geom_line(color = 'grey') +
  geom_smooth(method = "gam", formula = y ~ s(x, k = 3), alpha = .15, aes(fill = `N-Gram`, color = `N-Gram`)) +
  theme_minimal() +
  scale_color_manual(values=color_code)+
  scale_fill_manual(values=color_code)+
  geom_text_repel(aes(label = label, y=Predicted, color = `N-Gram`), size = text_repel, fontface = "bold", vjust=1, nudge_x = nudge_x,direction = "y", hjust = "left",
                  segment.size = 0.2,
                  segment.color = "#00000030") +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.x = element_line(),  # Keep major vertical grid lines
        panel.grid.minor.x = element_blank(),  # Remove minor vertical grid lines
        panel.border = element_rect(linetype = "solid", fill = NA),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text = element_text(size = axis_text),
        plot.title = element_text(hjust = 0, vjust =vjust, size = title_size)) +
  ggtitle("_finance") +
  theme(legend.position = "none")+
  coord_cartesian(ylim = c(0, max_y_value))+
  scale_x_continuous(breaks = seq(2000, 2022, 5), limits = c(2000, 2035)) +
  guides(colour = FALSE, lty = FALSE) 
print(plot2)

ngram_values_3 <- c('Biodiversity conservation',
'Biodiversity loss',
'Biodiversity financ*',
'Biodiversity offset',
'Biodiversity risk')
finance_2 <- df1[df1$`N-Gram` %in% ngram_values_3,]
finance_2$Subfolder <- as.numeric(finance_2$Subfolder)

finance_2 <- finance_2 %>%
  group_by(`N-Gram`) %>%
  do({
    model <- gam(Frequency ~ s(Subfolder, k = 3), data = .)
    predictions <- predict(model, newdata = data.frame(Subfolder = max(.$Subfolder)))
    data.frame(., Predicted = predictions)
  }) %>%
  ungroup()

# Add labels to the last point in each group
finance_2 <- finance_2 %>%
  group_by(`N-Gram`) %>%
  mutate(label = if_else(Subfolder == max(Subfolder), as.character(`N-Gram`), NA_character_)) %>%
  ungroup()

finance_2 <- arrange(finance_2, desc(Predicted))

n_gram_levels <- finance_2 %>%
  distinct(`N-Gram`) %>%
  pull(`N-Gram`)

# Step 2: Set N-Gram as an ordered factor
finance_2$`N-Gram` <- factor(finance_2$`N-Gram`, levels = n_gram_levels)

plot3 <- ggplot(finance_2, aes(x = Subfolder, y = Frequency, group = `N-Gram`)) +
  geom_line(color = 'grey') +
  geom_smooth(method = "gam", formula = y ~ s(x, k = 3), alpha = .15, aes(fill = `N-Gram`, color = `N-Gram`)) +
  theme_minimal() +
  scale_color_manual(values=color_code)+
  scale_fill_manual(values=color_code)+
  geom_text_repel(aes(label = label, y=Predicted, color = `N-Gram`), fontface = "bold", size = text_repel, vjust=vjust, nudge_x = nudge_x,direction = "y", hjust = "left",
                  segment.size = 0.2,
                  segment.color = "#00000030") +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.x = element_line(),  # Keep major vertical grid lines
        panel.grid.minor.x = element_blank(),  # Remove minor vertical grid lines
        panel.border = element_rect(linetype = "solid", fill = NA),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text = element_text(size = axis_text),
        plot.title = element_text(hjust = 0, vjust =vjust, size = title_size)) +
  ggtitle("biodiversity_") +
  theme(legend.position = "none")+
  coord_cartesian(ylim = c(0, max_y_value))+
  scale_x_continuous(breaks = seq(2000, 2022, 5), limits = c(2000, 2035)) +
  guides(colour = FALSE, lty = FALSE) 
print(plot3)

ngram_values_4 <-
c('Nature related', 'Nature based', 'Nature positive', 'Nature loss', 'Nature conservancy')
finance_2 <- df1[df1$`N-Gram` %in% ngram_values_4,]
finance_2$Subfolder <- as.numeric(finance_2$Subfolder)

finance_2 <- finance_2 %>%
  group_by(`N-Gram`) %>%
  do({
    model <- gam(Frequency ~ s(Subfolder, k = 3), data = .)
    predictions <- predict(model, newdata = data.frame(Subfolder = max(.$Subfolder)))
    data.frame(., Predicted = predictions)
  }) %>%
  ungroup()

# Add labels to the last point in each group
finance_2 <- finance_2 %>%
  group_by(`N-Gram`) %>%
  mutate(label = if_else(Subfolder == max(Subfolder), as.character(`N-Gram`), NA_character_)) %>%
  ungroup()

finance_2 <- arrange(finance_2, desc(Predicted))

n_gram_levels <- finance_2 %>%
  distinct(`N-Gram`) %>%
  pull(`N-Gram`)

# Step 2: Set N-Gram as an ordered factor
finance_2$`N-Gram` <- factor(finance_2$`N-Gram`, levels = n_gram_levels)

plot4 <- ggplot(finance_2, aes(x = Subfolder, y = Frequency, group = `N-Gram`)) +
  geom_line(color = 'grey') +
  geom_smooth(method = "gam", formula = y ~ s(x, k = 3), alpha = .15, aes(fill = `N-Gram`, color = `N-Gram`)) +
  theme_minimal() +
  scale_color_manual(values=color_code)+
  scale_fill_manual(values=color_code)+
  geom_text_repel(aes(label = label, y=Predicted, color = `N-Gram`), fontface = "bold", size = text_repel, vjust=1, nudge_x = nudge_x,direction = "y", hjust = "left",
                  segment.size = 0.2,
                  segment.color = "#00000030") +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.x = element_line(),  # Keep major vertical grid lines
        panel.grid.minor.x = element_blank(),  # Remove minor vertical grid lines
        panel.border = element_rect(linetype = "solid", fill = NA),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text = element_text(size = axis_text),
        plot.title = element_text(hjust = 0, vjust =vjust, size = title_size)) +
  ggtitle("nature_") +
  theme(legend.position = "none")+
  coord_cartesian(ylim = c(0, max_y_value))+
  scale_x_continuous(breaks = seq(2000, 2022, 5), limits = c(2000, 2035)) +
  guides(colour = FALSE, lty = FALSE) 
print(plot4)

ngram_values_5 <-
  c('Impact biodiversity',
      'Mainstreaming biodiversity',
      'Use biodiversity',
      'Value biodiversity',
      'Conserv* biodiversity')
finance_2 <- df1[df1$`N-Gram` %in% ngram_values_5,]
finance_2$Subfolder <- as.numeric(finance_2$Subfolder)

finance_2 <- finance_2 %>%
  group_by(`N-Gram`) %>%
  do({
    model <- gam(Frequency ~ s(Subfolder, k = 3), data = .)
    predictions <- predict(model, newdata = data.frame(Subfolder = max(.$Subfolder)))
    data.frame(., Predicted = predictions)
  }) %>%
  ungroup()

# Add labels to the last point in each group
finance_2 <- finance_2 %>%
  group_by(`N-Gram`) %>%
  mutate(label = if_else(Subfolder == max(Subfolder), as.character(`N-Gram`), NA_character_)) %>%
  ungroup()

finance_2 <- arrange(finance_2, desc(Predicted))

n_gram_levels <- finance_2 %>%
  distinct(`N-Gram`) %>%
  pull(`N-Gram`)

# Step 2: Set N-Gram as an ordered factor
finance_2$`N-Gram` <- factor(finance_2$`N-Gram`, levels = n_gram_levels)

plot5 <- ggplot(finance_2, aes(x = Subfolder, y = Frequency, group = `N-Gram`)) +
  geom_line(color = 'grey') +
  geom_smooth(method = "gam", formula = y ~ s(x, k = 3), alpha = .15, aes(fill = `N-Gram`, color = `N-Gram`)) +
  theme_minimal() +
  scale_color_manual(values=color_code)+
  scale_fill_manual(values=color_code)+
  geom_text_repel(aes(label = label, y=Predicted, color = `N-Gram`), fontface = "bold", size = text_repel, vjust=1.2, nudge_x = nudge_x,direction = "y", hjust = "left",
                  segment.size = 0.2,
                  segment.color = "#00000030") +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.x = element_line(),  # Keep major vertical grid lines
        panel.grid.minor.x = element_blank(),  # Remove minor vertical grid lines
        panel.border = element_rect(linetype = "solid", fill = NA),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text = element_text(size = axis_text),
        plot.title = element_text(hjust = 0, vjust =vjust, size = title_size)) +
  ggtitle("_biodiversity") +
  theme(legend.position = "none")+
  coord_cartesian(ylim = c(0, max_y_value))+
  scale_x_continuous(breaks = seq(2000, 2022, 5), limits = c(2000, 2035)) +
  guides(colour = FALSE, lty = FALSE) 
print(plot5)

ngram_values_6 <-
  c(  'Impact nature',
      'Value nature',
      'Taskforce nature',
      'New nature',
      'Debt nature')
finance_2 <- df1[df1$`N-Gram` %in% ngram_values_6,]
finance_2$Subfolder <- as.numeric(finance_2$Subfolder)

finance_2 <- finance_2 %>%
  group_by(`N-Gram`) %>%
  do({
    model <- gam(Frequency ~ s(Subfolder, k = 3), data = .)
    predictions <- predict(model, newdata = data.frame(Subfolder = max(.$Subfolder)))
    data.frame(., Predicted = predictions)
  }) %>%
  ungroup()

# Add labels to the last point in each group
finance_2 <- finance_2 %>%
  group_by(`N-Gram`) %>%
  mutate(label = if_else(Subfolder == max(Subfolder), as.character(`N-Gram`), NA_character_)) %>%
  ungroup()

finance_2 <- arrange(finance_2, desc(Predicted))

n_gram_levels <- finance_2 %>%
  distinct(`N-Gram`) %>%
  pull(`N-Gram`)

# Step 2: Set N-Gram as an ordered factor
finance_2$`N-Gram` <- factor(finance_2$`N-Gram`, levels = n_gram_levels)

plot6 <- ggplot(finance_2, aes(x = Subfolder, y = Frequency, group = `N-Gram`)) +
  geom_line(color = 'grey') +
  geom_smooth(method = "gam", formula = y ~ s(x, k = 3), alpha = .15, aes(fill = `N-Gram`, color = `N-Gram`)) +
  theme_minimal() +
  scale_color_manual(values=color_code)+
  scale_fill_manual(values=color_code)+
  geom_text_repel(aes(label = label, y=Predicted, color = `N-Gram`), fontface = "bold", size = text_repel, vjust=1, nudge_x = nudge_x,direction = "y", hjust = "left",
                  segment.size = 0.2,
                  segment.color = "#00000030") +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.x = element_line(),  # Keep major vertical grid lines
        panel.grid.minor.x = element_blank(),  # Remove minor vertical grid lines
        panel.border = element_rect(linetype = "solid", fill = NA),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text = element_text(size = axis_text),
        plot.title = element_text(hjust = 0, vjust =vjust, size = title_size)) +
  ggtitle("_nature") +
  theme(legend.position = "none")+
  coord_cartesian(ylim = c(0, max_y_value))+
  scale_x_continuous(breaks = seq(2000, 2022, 5), limits = c(2000, 2035)) +
  guides(colour = FALSE, lty = FALSE) 

print(plot6)

