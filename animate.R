library(dplyr)
library(gganimate)
library(tidyr)

setwd("C:/Users/583413/Documents/barchart race")
data = read.csv("budgets.csv")


data = data%>%gather(Year, Budget, X1962:X2018) #goes from wide to long

data$Budget<- as.numeric(gsub(",", "",data$Budget)) #converts to numeric
data$Year= gsub("X", "", data$Year) #removes the X

ranked_data = data%>%
  group_by(Year)%>%
  mutate(rank = min_rank(-Budget)*1, #for each year, rank the department by the budget (the - makes it desc)
         Value_lbl = paste0(" ", Department, ": ", format(Budget, big.mark = ",", scientific = F)))%>%
  filter(rank <= 10)%>%
  ungroup()%>%
  filter(Year != "TQ") #clean out artifact from gov data

#creating the anim object (which is a combo of ggplot and gganimate)
anim <- ggplot(ranked_data, aes( #remeber that the x and y axis will be flipped
                                x = rank, #the rank is what creates the order for the bars. there should be 10 per year/frame
                                y = Department,#the bars should be organized around department
                                label = Department,
                                group = Department,
                                fill = Department.Type
                                ) #groups determine OBJECT PERMENANCE for gganimate. 
                                                    #this is very important to ensure that the same bar does not transition in and out 
               ) +
  geom_tile(
    aes(
        y = Budget/2, #unclear as to why but the y value MUST be the height variable/2
        height = Budget,
        width = 0.9,
        fill = Department.Type # determine the color of the bars
      ), 
    alpha = 0.8, show.legend = TRUE)+
  geom_text(aes( 
                y = Budget, #the labels need to be mapped to the budget bar 
                label = Value_lbl, #the label variable 
                #color = ifelse(Budget > 600000, "#ffffff", "#000000"),
                hjust = ifelse(Budget > 600000, 1, 0) # if the budget is large, we want the text to be in the bar instead of outside the bar
                ) #end of aes
            ) + #end of geom_text
  coord_flip(clip = "off", expand = FALSE) +
  scale_y_continuous(labels = scales::comma) +
  scale_fill_manual(name = 'Department Categories', values = c("#607D8B", "#FFC300", "#DAF7A6",
                                                               "#C5E1A5", "#FF5733", "#C70039"),
                    guide = guide_legend(
                      direction = "horizontal",
                      title.position = "top"
                    ))+
  scale_x_reverse() +
  theme_minimal()+ # removes a lot of plot elements
  theme(
    plot.title = element_text(color = "#01807e", face = "bold", hjust = 0, size = 30),
    axis.ticks.y = element_blank(), #removes axis ticks
    axis.text.y = element_blank(), #removes axis ticks
    panel.grid.major = element_blank(), #removes grid lines
    panel.grid.minor = element_blank(), #removes grid lines
    legend.position = "bottom",
    legend.justification = "left"
  )+
  labs(title = "{closest_state}",#shows the closest state (year) for that frame
       subtitle = "Governmnet Outlays by Department and Year",
       y = "",
       x = "",
       caption = "Source: whitehouse.gov | Dollar amount in millions")+
  
  #this part provides the actual animation
  transition_states(Year, #what variable is going to be the frames
                    transition_length = 4, #relative length of transition frames
                    state_length = 1, #relative length of state frames
                    wrap = TRUE) + #should the gif go back to the start at the end
  ease_aes("cubic-in-out") #how do new elements transition in

#now that we have the anim object, we need to render it
animate(anim, 
        nframes = 500, #more frames for make it smoother but longer to render
        fps = 15 #how many frames are shown per second
        )


