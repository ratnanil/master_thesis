library(tidyverse)
library(sp)
library(arcgisbinding)
library(grid)
library(ggplot2)

x <- seq(-4, 4, by = .01)

y1 <- dnorm(x, mean = 0, sd = 1)
y2 <- dnorm(x, mean = 0, sd = 2)
y3 <- dnorm(x, mean = 0, sd = 3)
y4 <- dnorm(x, mean = 0, sd = 4)
y5 <- dnorm(x, mean = 0, sd = 5)

ggplot()+
  geom_line(aes(x,y1,color='1'),size=1)+
  geom_line(aes(x,y2,color='2'),size=1)+
  geom_line(aes(x,y3,color='3'),size=1)+
  geom_line(aes(x,y4,color='4'),size=1)+
  geom_line(aes(x,y5,color='5'),size=1)+
  labs(colour = "standard deviation")+
  guides(color = guide_legend(override.aes = list(size=5)))+
  theme_classic(base_size = 12, base_family = "")+
  theme(legend.position = c(0.85,0.8),
        axis.title.y=element_blank(),axis.title.x=element_blank(),
        legend.text=element_text(size=15)
        )