# This script will analyse the outputs of the manual_digitizing experiments of my master thesis.
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
#add_whiskers
#whiskers_plot
#table_to_mean_and_quantiles_and_sd

rhone_indicators = arc.select(arc.open('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\rhone\\5\\indicators_table.gdb\\indicators_table'))
rhone_indicators = rhone_indicators[1,]
rhone_indicators <- rhone_indicators[!is.na(rhone_indicators$shoreline) |!is.na(rhone_indicators$sinuosity) |!is.na(rhone_indicators$total_sinuosity) |!is.na(rhone_indicators$width_variability),]
rhone_indicators[is.na(rhone_indicators)] <- 0
rhone_indicators = select(rhone_indicators,'shoreline','sinuosity','total_sinuosity','number_of_nodes','width_variability')
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
# rhone_indicators$sinuosity_sd = 0
# rhone_indicators$total_sinuosity_sd = 0
# rhone_indicators$number_of_nodes_sd = 0
# rhone_indicators$width_variability_sd = 0


rhone_0_5 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\rhone\\5\\indicators_table.gdb\\indicators_table')
rhone_0_5 = as.data.frame(rhone_0_5, value = rhone_0_5$rhone_0_5)
rhone_1 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\rhone\\10\\indicators_table.gdb\\indicators_table')
rhone_1 = as.data.frame(rhone_1, value = rhone_1$rhone_1)
rhone_1_5 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\rhone\\15\\indicators_table.gdb\\indicators_table')
rhone_1_5 = as.data.frame(rhone_1_5, value = rhone_1_5$rhone_1_5)
rhone_2 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\rhone\\20\\indicators_table.gdb\\indicators_table')
rhone_2 = as.data.frame(rhone_2, value = rhone_2$rhone_2)
rhone_2_5 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\rhone\\25\\indicators_table.gdb\\indicators_table')
rhone_2_5 = as.data.frame(rhone_2_5, value = rhone_2_5$rhone_2_5)
rhone_3 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\rhone\\30\\indicators_table.gdb\\indicators_table')
rhone_3 = as.data.frame(rhone_3, value = rhone_3$rhone_3)

rhone_means = rbind(rhone_indicators, rhone_0_5,rhone_1,rhone_1_5,rhone_2,rhone_2_5,rhone_3)
rhone_means$river = 'rhone'

rhone_means_5per = add_quantiles(rhone_means,0.05,rhone_originals)

sd = c(0,0.5,1,1.5,2,2.5,3)
rhone_means_5per = cbind(sd,rhone_means_5per)


saane_indicators = arc.select(arc.open('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\saane\\5\\indicators_table.gdb\\indicators_table'))
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

saane_0_5 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\saane\\5\\indicators_table.gdb\\indicators_table')
saane_0_5 = as.data.frame(saane_0_5, value = saane_0_5$saane_0_5)
saane_1 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\saane\\10\\indicators_table.gdb\\indicators_table')
saane_1 = as.data.frame(saane_1, value = saane_1$saane_1)
saane_1_5 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\saane\\15\\indicators_table.gdb\\indicators_table')
saane_1_5 = as.data.frame(saane_1_5, value = saane_1_5$saane_1_5)
saane_2 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\saane\\20\\indicators_table.gdb\\indicators_table')
saane_2 = as.data.frame(saane_2, value = saane_2$saane_2)
saane_2_5 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\saane\\25\\indicators_table.gdb\\indicators_table')
saane_2_5 = as.data.frame(saane_2_5, value = saane_2_5$saane_2_5)
saane_3 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\saane\\30\\indicators_table.gdb\\indicators_table')
saane_3 = as.data.frame(saane_3, value = saane_3$saane_3)

saane_means = rbind(saane_indicators, saane_0_5,saane_1,saane_1_5,saane_2,saane_2_5,saane_3)
saane_means$river = 'saane'

saane_means_5per = add_quantiles(saane_means,0.05,saane_originals)

sd = c(0,0.5,1,1.5,2,2.5,3)
saane_means_5per = cbind(sd,saane_means_5per)
#   
sense_indicators = arc.select(arc.open('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\sense\\5\\indicators_table.gdb\\indicators_table'))
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

sense_0_5 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\sense\\5\\indicators_table.gdb\\indicators_table')
sense_0_5 = as.data.frame(sense_0_5, value = sense_0_5$sense_0_5)
sense_1 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\sense\\10\\indicators_table.gdb\\indicators_table')
sense_1 = as.data.frame(sense_1, value = sense_1$sense_1)
sense_1_5 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\sense\\15\\indicators_table.gdb\\indicators_table')
sense_1_5 = as.data.frame(sense_1_5, value = sense_1_5$sense_1_5)
sense_2 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\sense\\20\\indicators_table.gdb\\indicators_table')
sense_2 = as.data.frame(sense_2, value = sense_2$sense_2)
sense_2_5 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\sense\\25\\indicators_table.gdb\\indicators_table')
sense_2_5 = as.data.frame(sense_2_5, value = sense_2_5$sense_2_5)
sense_3 = table_to_mean_and_quantiles('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\sense\\30b\\indicators_table.gdb\\indicators_table')
sense_3 = as.data.frame(sense_3, value = sense_3$sense_3)

# quantile(sense_indicators$width_variability,c(0.05,0.1,0.9,0.95),na.rm = TRUE)
# tapply(sense_3$width_variability,quantile,probs=c(0.1,0.9), na.rm=TRUE
# mean(sense_indicators$width_variability)
# sense_indicators2 = arc.select(arc.open('C:\\zhaw\\masterarbeit\\data\\outputs8\\manual_digitizing\\sense\\30b\\indicators_table.gdb\\indicators_table'))
# quant1 = quantile(sense_indicators2$width_variability,c(0.05,0.1,0.9,0.95),na.rm = TRUE)
# mean(sense_indicators2$width_variability)
# quant1_5 = quant1[1]



sense_means = rbind(sense_indicators, sense_0_5,sense_1,sense_1_5,sense_2,sense_2_5,sense_3)
sense_means$river = 'sense'

sense_means_5per = add_quantiles(sense_means,0.05,sense_originals)

sd = c(0,0.5,1,1.5,2,2.5,3)
sense_means_5per = cbind(sd,sense_means_5per)

rivers_whiskers = rbind(rhone_means_5per,saane_means_5per,sense_means_5per)

man_dig_whisker_plot = quantiles_plot(rivers_whiskers, rivers_whiskers$sd,3)

man_dig_whisker_plot
