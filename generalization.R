# This script will analyse the outputs of the generalization experiments of my master thesis.
# It begins with importing another script of mine, 'cyrills_r_functions.R', that stores the
# functions used in this script.
# This script was part of my master thesis at the Zurich university of applied sciences ZHAW in 2018.

# import packages
library(tidyverse)
library(sp)
library(arcgisbinding)
library(grid)
library(ggplot2)
arc.check_product()
source('cyrills_r_functions.R')
#functions:
#table_to_mean
#add_5percent_whiskers
#whiskers_plot
rhone_swissimage_ind_df = arc.select(arc.open('C:\\zhaw\\masterarbeit\\data\\outputs8\\generalization\\rhone_swissimage\\Rhone_swissimage.gdb\\Rhone_swissimage_indicators'))
rhone_smr_ind_df = arc.select(arc.open('C:\\zhaw\\masterarbeit\\data\\outputs8\\generalization\\rhone_smr\\Rhone_smr.gdb\\Rhone_smr_indicators'))
saane_swissimage_ind_df = arc.select(arc.open('C:\\zhaw\\masterarbeit\\data\\outputs8\\generalization\\saane_swissimage\\Saane_swissimage.gdb\\Saane_swissimage_indicators'))
saane_smr_ind_df = arc.select(arc.open('C:\\zhaw\\masterarbeit\\data\\outputs8\\generalization\\saane_smr\\Saane_smr.gdb\\Saane_smr_indicators'))
sense_swissimage_ind_df = arc.select(arc.open('C:\\zhaw\\masterarbeit\\data\\outputs8\\generalization\\sense_swissimage\\Sense_swissimage.gdb\\Sense_swissimage_indicators'))
sense_smr_ind_df = arc.select(arc.open('C:\\zhaw\\masterarbeit\\data\\outputs8\\generalization\\sense_smr\\Sense_smr.gdb\\Sense_smr_indicators'))
rhone_swissimage_ind_df[is.na(rhone_swissimage_ind_df)] <- 0
rhone_smr_ind_df[is.na(rhone_smr_ind_df)] <- 0
saane_swissimage_ind_df[is.na(saane_swissimage_ind_df)] <- 0
saane_smr_ind_df[is.na(saane_smr_ind_df)] <- 0
sense_swissimage_ind_df[is.na(sense_swissimage_ind_df)] <- 0
sense_smr_ind_df[is.na(sense_smr_ind_df)] <- 0

rhone_swissimage_originals=c(rhone_swissimage_ind_df$shoreline[1],rhone_swissimage_ind_df$sinuosity[1],rhone_swissimage_ind_df$total_sinuosity[1],rhone_swissimage_ind_df$number_of_nodes[1],rhone_swissimage_ind_df$width_variability[1])
saane_swissimage_originals=c(saane_swissimage_ind_df$shoreline[1],saane_swissimage_ind_df$sinuosity[1],saane_swissimage_ind_df$total_sinuosity[1],saane_swissimage_ind_df$number_of_nodes[1],saane_swissimage_ind_df$width_variability[1])
sense_swissimage_originals=c(sense_swissimage_ind_df$shoreline[1],sense_swissimage_ind_df$sinuosity[1],sense_swissimage_ind_df$total_sinuosity[1],sense_swissimage_ind_df$number_of_nodes[1],sense_swissimage_ind_df$width_variability[1])
rhone_smr_originals=c(rhone_smr_ind_df$shoreline[1],rhone_smr_ind_df$sinuosity[1],rhone_smr_ind_df$total_sinuosity[1],rhone_smr_ind_df$number_of_nodes[1],rhone_smr_ind_df$width_variability[1])
saane_smr_originals=c(saane_smr_ind_df$shoreline[1],saane_smr_ind_df$sinuosity[1],saane_smr_ind_df$total_sinuosity[1],saane_smr_ind_df$number_of_nodes[1],saane_smr_ind_df$width_variability[1])
sense_smr_originals=c(sense_smr_ind_df$shoreline[1],sense_smr_ind_df$sinuosity[1],sense_smr_ind_df$total_sinuosity[1],sense_smr_ind_df$number_of_nodes[1],sense_smr_ind_df$width_variability[1])

rhone_swissimage_whiskers = add_whiskers(rhone_swissimage_ind_df,0.05,rhone_swissimage_originals)
rhone_smr_whiskers = add_whiskers(rhone_smr_ind_df,0.05,rhone_swissimage_originals)
saane_swissimage_whiskers = add_whiskers(saane_swissimage_ind_df,0.05,saane_swissimage_originals)
saane_smr_whiskers = add_whiskers(saane_smr_ind_df,0.05,saane_swissimage_originals)
sense_swissimage_whiskers = add_whiskers(sense_swissimage_ind_df,0.05,sense_swissimage_originals)
sense_smr_whiskers = add_whiskers(sense_smr_ind_df,0.05,sense_swissimage_originals)

indicators = rbind(rhone_swissimage_whiskers,rhone_smr_whiskers,saane_swissimage_whiskers,saane_smr_whiskers,sense_swissimage_whiskers,sense_smr_whiskers)
# river = c('rhone','rhone','saane','saane','sense','sense')
river = c('Rhone(straight)','Rhone(straight)','Saane(meandering)','Saane(meandering)','Sense(braided)','Sense(braided)')
source = c('image','map','image','map','image','map')
indicators = cbind(indicators,river)
indicators = cbind(source,indicators)
#indicators[is.na(indicators)] <- 0
indicators_whiskers = indicators

# create legend
 # ggplot(indicators)+
 #   geom_point(aes(x = indicators$source, y = shoreline, color=river), shape = 8)+
 #     theme(legend.position = 'top')


    #            ,shape = indicators$shoreline_shape)+
    # guides(color=FALSE)+
    # labs(x=colnames(indicators)[1])+
    # theme(legend.position = 'top',
    #       axis.title.y=element_blank()
    # )
# shoreline_plot_5

#indicators_whiskers = add_whiskers(indicators,0.05)

#Create indicators_plot_5 with 5 percent whiskers

# shoreline_plot_5 = ggplot(indicators_whiskers)+
#   geom_point(aes(x = source, y = shoreline, colour = source),shape = indicators_whiskers$shoreline_shape)+
#   facet_grid(.~river,scales = 'free')+
#   #expand_limits(x = 0, y = 0)+
#   theme(legend.position = 'none',
#         axis.text.x=element_blank(),
#         axis.title.x=element_blank()
#   )
# shoreline_plot_5
# sinuosity_plot_5 = ggplot(indicators_whiskers)+
#   geom_point(aes(x = source, y = sinuosity, colour = source),shape = indicators_whiskers$sinuosity_shape)+
#   facet_grid(.~river,scales = 'free')+
#   theme(legend.position = 'none',
#         axis.text.x=element_blank(),
#         axis.title.x=element_blank()
#   )
# total_sinuosity_plot_5 = ggplot(indicators_whiskers)+
#   geom_point(aes(x = source, y = total_sinuosity, colour = source),shape = indicators_whiskers$total_sinuosity_shape)+
#   facet_grid(.~river,scales = 'free')+
#   theme(legend.position = 'none',
#         axis.text.x=element_blank(),
#         axis.title.x=element_blank()
#   )
# number_of_nodes_plot_5 = ggplot(indicators_whiskers)+
#   geom_point(aes(x = source, y = number_of_nodes, colour = source),shape = indicators_whiskers$number_of_nodes_shape)+
#   facet_grid(.~river,scales = 'free')+
#   theme(legend.position = 'none',
#         axis.text.x=element_blank(),
#         axis.title.x=element_blank()
#   )
# width_variability_plot_5 = ggplot(indicators_whiskers)+
#   geom_point(aes(x = source, y = width_variability, colour = source),shape = indicators_whiskers$width_variability_shape)+
#   facet_grid(.~river,scales = 'free')+
#   theme(legend.position = 'none',
#         axis.text.x=element_blank(),
#         axis.title.x=element_blank()
#   )
# 
# #dev.off()
# pushViewport(viewport(layout = grid.layout(5, 4)))
# print(shoreline_plot_5, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
# print(sinuosity_plot_5, vp = viewport(layout.pos.row = 2, layout.pos.col = 1))
# print(total_sinuosity_plot_5, vp = viewport(layout.pos.row = 3, layout.pos.col = 1))
# print(number_of_nodes_plot_5, vp = viewport(layout.pos.row = 4, layout.pos.col = 1))
# print(width_variability_plot_5, vp = viewport(layout.pos.row = 5, layout.pos.col = 1))
# generalization_whiskers_plot = recordPlot()
# dev.off()
# generalization_whiskers_plot

indicators$OBJECTID = NULL
generalization_plot = whiskers_plot(indicators,indicators$source,1)
generalization_plot
