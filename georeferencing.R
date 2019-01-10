# This script will analyse the outputs of the manual_digitization experiments of my master thesis.
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
#table_to_mean_and_quantiles
#add_quantiles
#whiskers_plot
rhone_indicators = arc.select(arc.open('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\rhone\\10\\indicators_table.gdb\\indicators_table'))
rhone_indicators = rhone_indicators[1,]
rhone_indicators <- rhone_indicators[!is.na(rhone_indicators$shoreline) |!is.na(rhone_indicators$sinuosity) |!is.na(rhone_indicators$total_sinuosity) |!is.na(rhone_indicators$width_variability),]
rhone_indicators[is.na(rhone_indicators)] <- 0
rhone_indicators = select(rhone_indicators,'shoreline','sinuosity','total_sinuosity','number_of_nodes','width_variability')
rhone_originals=c(rhone_indicators$shoreline[1],rhone_indicators$sinuosity[1],rhone_indicators$total_sinuosity[1],rhone_indicators$number_of_nodes[1],rhone_indicators$width_variability[1])
rhone_originals=c(rhone_indicators$shoreline[1],rhone_indicators$sinuosity[1],rhone_indicators$total_sinuosity[1],rhone_indicators$number_of_nodes[1],rhone_indicators$width_variability[1])
rhone_indicators$shoreline_10q = mean(rhone_indicators$shoreline)
rhone_indicators$shoreline_90q = mean(rhone_indicators$shoreline)
rhone_indicators$sinuosity_10q = mean(rhone_indicators$sinuosity)
rhone_indicators$sinuosity_90q = mean(rhone_indicators$sinuosity)
rhone_indicators$total_sinuosity_10q = mean(rhone_indicators$total_sinuosity)
rhone_indicators$total_sinuosity_90q = mean(rhone_indicators$total_sinuosity)
rhone_indicators$number_of_nodes_10q = mean(rhone_indicators$number_of_nodes)
rhone_indicators$number_of_nodes_90q = mean(rhone_indicators$number_of_nodes)
rhone_indicators$width_variability_10q = mean(rhone_indicators$width_variability)
rhone_indicators$width_variability_90q = mean(rhone_indicators$width_variability)

rhone_1 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\rhone\\10\\indicators_table.gdb\\indicators_table')
rhone_1 = as.data.frame(rhone_1, value = rhone_1$rhone_1)
rhone_2 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\rhone\\20\\indicators_table.gdb\\indicators_table')
rhone_2 = as.data.frame(rhone_2, value = rhone_2$rhone_2)
rhone_3 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\rhone\\30\\indicators_table.gdb\\indicators_table')
rhone_3 = as.data.frame(rhone_3, value = rhone_3$rhone_3)
rhone_4 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\rhone\\40\\indicators_table.gdb\\indicators_table')
rhone_4 = as.data.frame(rhone_4, value = rhone_4$rhone_4)
rhone_5 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\rhone\\50\\indicators_table.gdb\\indicators_table')
rhone_5 = as.data.frame(rhone_5, value = rhone_5$rhone_5)

rhone_means = rbind(rhone_indicators, rhone_1,rhone_2,rhone_3,rhone_4,rhone_5)
rhone_means$river = 'rhone'
rhone_means_5per = add_quantiles(rhone_means,0.05, rhone_originals)
sd = c(0,1,2,3,4,5)
rhone_means_5per = cbind(sd,rhone_means_5per)
# saane_means_5per
# 
# saane_means_5per_plot = whiskers_plot(saane_means_5per,sd)
# saane_means_5per_plot

saane_indicators = arc.select(arc.open('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\saane\\10\\indicators_table.gdb\\indicators_table'))
saane_indicators = saane_indicators[1,]
saane_indicators <- saane_indicators[!is.na(saane_indicators$shoreline) |!is.na(saane_indicators$sinuosity) |!is.na(saane_indicators$total_sinuosity) |!is.na(saane_indicators$width_variability),]
saane_indicators[is.na(saane_indicators)] <- 0
saane_indicators = select(saane_indicators,'shoreline','sinuosity','total_sinuosity','number_of_nodes','width_variability')
saane_originals=c(saane_indicators$shoreline[1],saane_indicators$sinuosity[1],saane_indicators$total_sinuosity[1],saane_indicators$number_of_nodes[1],saane_indicators$width_variability[1])
saane_indicators$shoreline_10q = mean(saane_indicators$shoreline)
saane_indicators$shoreline_90q = mean(saane_indicators$shoreline)
saane_indicators$sinuosity_10q = mean(saane_indicators$sinuosity)
saane_indicators$sinuosity_90q = mean(saane_indicators$sinuosity)
saane_indicators$total_sinuosity_10q = mean(saane_indicators$total_sinuosity)
saane_indicators$total_sinuosity_90q = mean(saane_indicators$total_sinuosity)
saane_indicators$number_of_nodes_10q = mean(saane_indicators$number_of_nodes)
saane_indicators$number_of_nodes_90q = mean(saane_indicators$number_of_nodes)
saane_indicators$width_variability_10q = mean(saane_indicators$width_variability)
saane_indicators$width_variability_90q = mean(saane_indicators$width_variability)

saane_1 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\saane\\10\\indicators_table.gdb\\indicators_table')
saane_1 = as.data.frame(saane_1, value = saane_1$saane_1)
saane_2 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\saane\\20\\indicators_table.gdb\\indicators_table')
saane_2 = as.data.frame(saane_2, value = saane_2$saane_2)
saane_3 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\saane\\30\\indicators_table.gdb\\indicators_table')
saane_3 = as.data.frame(saane_3, value = saane_3$saane_3)
saane_4 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\saane\\40\\indicators_table.gdb\\indicators_table')
saane_4 = as.data.frame(saane_4, value = saane_4$saane_4)
saane_5 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\saane\\50\\indicators_table.gdb\\indicators_table')
saane_5 = as.data.frame(saane_5, value = saane_5$saane_5)

saane_means = rbind(saane_indicators, saane_1,saane_2,saane_3,saane_4,saane_5)
saane_means$river = 'saane'
saane_means_5per = add_quantiles(saane_means,0.05, saane_originals)
sd = c(0,1,2,3,4,5)
saane_means_5per = cbind(sd,saane_means_5per)

sense_indicators = arc.select(arc.open('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\sense\\10\\indicators_table.gdb\\indicators_table'))
sense_indicators = sense_indicators[1,]
sense_indicators <- sense_indicators[!is.na(sense_indicators$shoreline) |!is.na(sense_indicators$sinuosity) |!is.na(sense_indicators$total_sinuosity) |!is.na(sense_indicators$width_variability),]
sense_indicators[is.na(sense_indicators)] <- 0
sense_indicators = select(sense_indicators,'shoreline','sinuosity','total_sinuosity','number_of_nodes','width_variability')
sense_originals=c(sense_indicators$shoreline[1],sense_indicators$sinuosity[1],sense_indicators$total_sinuosity[1],sense_indicators$number_of_nodes[1],sense_indicators$width_variability[1])
sense_indicators$shoreline_10q = mean(sense_indicators$shoreline)
sense_indicators$shoreline_90q = mean(sense_indicators$shoreline)
sense_indicators$sinuosity_10q = mean(sense_indicators$sinuosity)
sense_indicators$sinuosity_90q = mean(sense_indicators$sinuosity)
sense_indicators$total_sinuosity_10q = mean(sense_indicators$total_sinuosity)
sense_indicators$total_sinuosity_90q = mean(sense_indicators$total_sinuosity)
sense_indicators$number_of_nodes_10q = mean(sense_indicators$number_of_nodes)
sense_indicators$number_of_nodes_90q = mean(sense_indicators$number_of_nodes)
sense_indicators$width_variability_10q = mean(sense_indicators$width_variability)
sense_indicators$width_variability_90q = mean(sense_indicators$width_variability)

sense_1 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\sense\\10\\indicators_table.gdb\\indicators_table')
sense_1 = as.data.frame(sense_1, value = sense_1$sense_1)
sense_2 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\sense\\20\\indicators_table.gdb\\indicators_table')
sense_2 = as.data.frame(sense_2, value = sense_2$sense_2)
sense_3 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\sense\\30\\indicators_table.gdb\\indicators_table')
sense_3 = as.data.frame(sense_3, value = sense_3$sense_3)
sense_4 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\sense\\40\\indicators_table.gdb\\indicators_table')
sense_4 = as.data.frame(sense_4, value = sense_4$sense_4)
sense_5 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\georeferencing\\sense\\50\\indicators_table.gdb\\indicators_table')
sense_5 = as.data.frame(sense_5, value = sense_5$sense_5)

sense_means = rbind(sense_indicators, sense_1,sense_2,sense_3,sense_4,sense_5)
sense_means$river = 'sense'
sense_means_5per = add_quantiles(sense_means,0.05, sense_originals)
sd = c(0,1,2,3,4,5)
sense_means_5per = cbind(sd,sense_means_5per)

rivers_whiskers = rbind(rhone_means_5per,saane_means_5per,sense_means_5per)

georeferencing_whisker_plot = quantiles_plot(rivers_whiskers, rivers_whiskers$sd,4)

georeferencing_whisker_plot

