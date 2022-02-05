FROM rocker/rstudio:3.6.3

RUN mkdir /home/rstudio/data_plots

# location for mounting
RUN mkdir /home/rstudio/data_mount

COPY ./ggplot2_example.R /home/rstudio/data_plots

# here we add data in when we write the image as opposed to mounting
COPY ./data_for_dockerfile /home/rstudio/data_plots

RUN R -e 'install.packages("ggplot2")'
