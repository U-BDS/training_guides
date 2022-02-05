# ggplot2 example being run in Docker container
# Amazon top 50 books from 2009-2019:
# Data from https://www.kaggle.com/sootersaalu/amazon-top-50-bestselling-books-2009-2019

library(ggplot2)

data_plot <- read.csv("./data_plots/bestsellers_with_categories.csv")

data_plot_selected <- data_plot[c("Year", "Genre")]

data_plot_selected <- data.frame(table(data_plot_selected))

ggplot(data_plot_selected, aes(x=Year, y=Freq, group=Genre)) +
  geom_point(size=3, aes(colour=Genre)) + 
  theme_bw(base_size = 16) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        axis.text.x = element_text(colour="black", size = 18, angle = 45, vjust = 0.5),
        axis.text.y = element_text(colour="black", size = 18),
        axis.line = element_line(size=0.5, colour = "black"),
        axis.title = element_text(size=22)) +
  geom_line(aes(colour=Genre))

# to load the following data, you will need to first mount the directory
# which contains the data file since we did not include it in the Dockerfile

# data_plot2 <- read.csv("./data_mount/netflix_titles.csv")
# View(data_plot2)
