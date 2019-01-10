#This script will analyse the outputs of the width_extension experiments
#
#Note to myself:
#Sense: min_width 7.5 (=minimum_width 15) had 2 rows in the total_sinuosity table instead of 1 row like all other tables.
#Value of the first row = 0.00021624, value of the second row = 3.71067052. The value of the first row had then been transferred
#indicators_table. I then manually replaced this value with the value of the second row, which is very similar of other values for total_sinuosity.
#
# import packages
library(tidyverse)
library(sp)
library(arcgisbinding)
library(grid)
library(ggplot2)
arc.check_product()
source('cyrills_r_functions.R')

rhone = arc.select(arc.open('C:\\zhaw\\masterarbeit\\data\\outputs13\\width_extension\\rhone_swissimage\\indicators_table.gdb\\indicators_table'))
saane = arc.select(arc.open('C:\\zhaw\\masterarbeit\\data\\outputs13\\width_extension\\saane_swissimage\\indicators_table.gdb\\indicators_table'))
sense = arc.select(arc.open('C:\\zhaw\\masterarbeit\\data\\outputs13\\width_extension\\sense_swissimage\\indicators_table.gdb\\indicators_table'))

rhone = select(rhone,'shoreline','sinuosity','total_sinuosity','number_of_nodes','width_variability')
saane = select(saane,'shoreline','sinuosity','total_sinuosity','number_of_nodes','width_variability')
sense = select(sense,'shoreline','sinuosity','total_sinuosity','number_of_nodes','width_variability')
buffer = c(0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,9.5,10)
minimum_width = buffer * 2
rhone = cbind(minimum_width,rhone)
saane = cbind(minimum_width,saane)
sense = cbind(minimum_width,sense)

rhone$river = 'rhone'
saane$river = 'saane'
sense$river = 'sense'

rhone <- rhone[!is.na(rhone$shoreline),]
rhone <- rhone[!is.na(rhone$sinuosity),]
rhone <- rhone[!is.na(rhone$total_sinuosity),]
rhone <- rhone[!is.na(rhone$width_variability),]
rhone[is.na(rhone)] <- 0
rhone = filter(rhone, sinuosity >= 1)
rhone = filter(rhone, total_sinuosity >= 1)

saane <- saane[!is.na(saane$shoreline),]
saane <- saane[!is.na(saane$sinuosity),]
saane <- saane[!is.na(saane$total_sinuosity),]
saane <- saane[!is.na(saane$width_variability),]
saane[is.na(saane)] <- 0
saane = filter(saane, sinuosity >= 1)
saane = filter(saane, total_sinuosity >= 1)

sense <- sense[!is.na(sense$shoreline),]
sense <- sense[!is.na(sense$sinuosity),]
sense <- sense[!is.na(sense$total_sinuosity),]
sense <- sense[!is.na(sense$width_variability),]
sense[is.na(sense)] <- 0
sense = filter(sense, sinuosity >= 1)
sense = filter(sense, total_sinuosity >= 1)

rhone_originals=c(rhone$shoreline[1],rhone$sinuosity[1],rhone$total_sinuosity[1],rhone$number_of_nodes[1],rhone$width_variability[1])
saane_originals=c(saane$shoreline[1],saane$sinuosity[1],saane$total_sinuosity[1],saane$number_of_nodes[1],saane$width_variability[1])
sense_originals=c(sense$shoreline[1],sense$sinuosity[1],sense$total_sinuosity[1],sense$number_of_nodes[1],sense$width_variability[1])

rhone_whiskers = add_whiskers(rhone,0.05,rhone_originals)
saane_whiskers = add_whiskers(saane,0.05,saane_originals)
sense_whiskers = add_whiskers(sense,0.05,sense_originals)

width_extension_whiskers = rbind(rhone_whiskers,saane_whiskers,sense_whiskers)

width_extension_whisker_plot = whiskers_plot_width(width_extension_whiskers, width_extension_whiskers$minimum_width,2)

width_extension_whisker_plot
