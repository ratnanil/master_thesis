# cyrills_r_functions
#table_to_mean
table_to_mean = function(path){
  input = arc.select(arc.open(path))
  input_wo_first_row = input[-1,]
  input_wo_first_row <- input_wo_first_row[!is.na(input_wo_first_row$shoreline),]
  input_wo_first_row <- input_wo_first_row[!is.na(input_wo_first_row$sinuosity),]
  input_wo_first_row <- input_wo_first_row[!is.na(input_wo_first_row$total_sinuosity),]
  input_wo_first_row <- input_wo_first_row[!is.na(input_wo_first_row$width_variability),]
  input_wo_first_row[is.na(input_wo_first_row)] <- 0
  input_wo_first_row = filter(input_wo_first_row, sinuosity >= 1)
  input_wo_first_row = filter(input_wo_first_row, total_sinuosity >= 1)
  indicators = select(input_wo_first_row,'shoreline','sinuosity','total_sinuosity','number_of_nodes','width_variability')
  mean_row = colMeans(indicators)
  #list=c(mean_row,input_wo_first_row)
  return(mean_row)
}

table_to_mean_and_sd = function(path){
  input = arc.select(arc.open(path))
  input_wo_first_row = input[-1,]
  input_wo_first_row <- input_wo_first_row[!is.na(input_wo_first_row$shoreline),]
  input_wo_first_row <- input_wo_first_row[!is.na(input_wo_first_row$sinuosity),]
  input_wo_first_row <- input_wo_first_row[!is.na(input_wo_first_row$total_sinuosity),]
  input_wo_first_row <- input_wo_first_row[!is.na(input_wo_first_row$width_variability),]
  input_wo_first_row[is.na(input_wo_first_row)] <- 0
  input_wo_first_row = filter(input_wo_first_row, sinuosity >= 1)
  input_wo_first_row = filter(input_wo_first_row, total_sinuosity >= 1)
  indicators = select(input_wo_first_row,'shoreline','sinuosity','total_sinuosity','number_of_nodes','width_variability')
  mean_row = colMeans(indicators)
  shoreline = (sapply(indicators,mean,na.rm=TRUE))[1]
  sinuosity = (sapply(indicators,mean,na.rm=TRUE))[2]
  total_sinuosity = (sapply(indicators,mean,na.rm=TRUE))[3]
  number_of_nodes = (sapply(indicators,mean,na.rm=TRUE))[4]
  width_variability = (sapply(indicators,mean,na.rm=TRUE))[5]
  shoreline_sd=(sapply(indicators,sd,na.rm=TRUE))[1]
  sinuosity_sd=(sapply(indicators,sd,na.rm=TRUE))[2]
  total_sinuosity_sd=(sapply(indicators,sd,na.rm=TRUE))[3]
  number_of_nodes_sd=(sapply(indicators,sd,na.rm=TRUE))[4]
  width_variability_sd=(sapply(indicators,sd,na.rm=TRUE))[5]
  
  # mean_row$shoreline_sd = sapply(indicators$shoreline,sd,na.rm=TRUE)
  mean_sd = cbind(shoreline,sinuosity,total_sinuosity,number_of_nodes,width_variability,shoreline_sd,sinuosity_sd,total_sinuosity_sd,number_of_nodes_sd,width_variability_sd)
  #list=c(mean_row,input_wo_first_row)
  return(mean_sd)
}

table_to_mean_and_quantiles = function(path){
  input = arc.select(arc.open(path))
  input_wo_first_row = input[-1,]
  input_wo_first_row <- input_wo_first_row[!is.na(input_wo_first_row$shoreline),]
  input_wo_first_row <- input_wo_first_row[!is.na(input_wo_first_row$sinuosity),]
  input_wo_first_row <- input_wo_first_row[!is.na(input_wo_first_row$total_sinuosity),]
  input_wo_first_row <- input_wo_first_row[!is.na(input_wo_first_row$width_variability),]
  input_wo_first_row[is.na(input_wo_first_row)] <- 0
  input_wo_first_row = filter(input_wo_first_row, sinuosity >= 1)
  input_wo_first_row = filter(input_wo_first_row, total_sinuosity >= 1)
  indicators = select(input_wo_first_row,'shoreline','sinuosity','total_sinuosity','number_of_nodes','width_variability')
  mean_row = colMeans(indicators)
  shoreline = (sapply(indicators,mean,na.rm=TRUE))[1]
  sinuosity = (sapply(indicators,mean,na.rm=TRUE))[2]
  total_sinuosity = (sapply(indicators,mean,na.rm=TRUE))[3]
  number_of_nodes = (sapply(indicators,mean,na.rm=TRUE))[4]
  width_variability = (sapply(indicators,mean,na.rm=TRUE))[5]
  shoreline_10q=quantile(indicators$shoreline,c(0.05),na.rm = TRUE)
  shoreline_90q=quantile(indicators$shoreline,c(0.95),na.rm = TRUE)
  sinuosity_10q=quantile(indicators$sinuosity,c(0.05),na.rm = TRUE)
  sinuosity_90q=quantile(indicators$sinuosity,c(0.95),na.rm = TRUE)
  total_sinuosity_10q=quantile(indicators$total_sinuosity,c(0.05),na.rm = TRUE)
  total_sinuosity_90q=quantile(indicators$total_sinuosity,c(0.95),na.rm = TRUE)
  number_of_nodes_10q=quantile(indicators$number_of_nodes,c(0.05),na.rm = TRUE)
  number_of_nodes_90q=quantile(indicators$number_of_nodes,c(0.95),na.rm = TRUE)
  width_variability_10q=quantile(indicators$width_variability,c(0.05),na.rm = TRUE)
  width_variability_90q=quantile(indicators$width_variability,c(0.95),na.rm = TRUE)

  # mean_row$shoreline_sd = sapply(indicators$shoreline,sd,na.rm=TRUE)
  mean_sd = cbind(shoreline,sinuosity,total_sinuosity,number_of_nodes,width_variability,
                  shoreline_10q,shoreline_90q,
                  sinuosity_10q,sinuosity_90q,
                  total_sinuosity_10q,total_sinuosity_90q,
                  number_of_nodes_10q,number_of_nodes_90q,
                  width_variability_10q,width_variability_90q)
  #list=c(mean_row,input_wo_first_row)
  return(mean_sd)
}

add_whiskers = function(means_table, size,originals){
  means_table$shoreline_minus5 = with(means_table, shoreline * (1-size))
  means_table$shoreline_plus5 = with(means_table, shoreline * (1+size))
  # means_table$shoreline_minus10 = with(means_table, shoreline * (1-(2*size)))
  # means_table$shoreline_plus10 = with(means_table, shoreline * (1+(2*size)))
  means_table = within(means_table,{
    shoreline_shape= ifelse((means_table$shoreline > originals[1] * 1.05 | means_table$shoreline < originals[1] * 0.95),
                            ifelse((means_table$shoreline > (originals[1] * 1.1) | means_table$shoreline < (originals[1] * 0.9)),15,17), 8
    )})
  means_table$sinuosity_minus5 = with(means_table, sinuosity * (1-size))
  means_table$sinuosity_plus5 = with(means_table, sinuosity * (1+size))
  means_table = within(means_table,{
    sinuosity_shape= ifelse((means_table$sinuosity > originals[2] * 1.05 | means_table$sinuosity < originals[2] * 0.95),
                            ifelse((means_table$sinuosity > (originals[2] * 1.1) | means_table$sinuosity < (originals[2] * 0.9)),15,17), 8
    )})
  means_table$total_sinuosity_minus5 = with(means_table, total_sinuosity * (1-size))
  means_table$total_sinuosity_plus5 = with(means_table, total_sinuosity * (1+size))
  means_table = within(means_table,{
    total_sinuosity_shape= ifelse((means_table$total_sinuosity > originals[3] * 1.05 | means_table$total_sinuosity < originals[3] * 0.95),
                            ifelse((means_table$total_sinuosity > (originals[3] * 1.1) | means_table$total_sinuosity < (originals[3] * 0.9)),15,17), 8
    )})
  means_table$number_of_nodes_minus5 = with(means_table, number_of_nodes * (1-size))
  means_table$number_of_nodes_plus5 = with(means_table, number_of_nodes * (1+size))
  means_table = within(means_table,{
    number_of_nodes_shape= ifelse((means_table$number_of_nodes > originals[4] * 1.05 | means_table$number_of_nodes < originals[4] * 0.95),
                            ifelse((means_table$number_of_nodes > (originals[4] * 1.1) | means_table$number_of_nodes < (originals[4] * 0.9)),15,17), 8
    )})
  means_table$width_variability_minus5 = with(means_table, width_variability * (1-size))
  means_table$width_variability_plus5 = with(means_table, width_variability * (1+size))
  means_table = within(means_table,{
    width_variability_shape= ifelse((means_table$width_variability > originals[5] * 1.05 | means_table$width_variability < originals[5] * 0.95),
                            ifelse((means_table$width_variability > (originals[5] * 1.1) | means_table$width_variability < (originals[5] * 0.9)),15,17), 8
    )})
  return (means_table)
}

add_quantiles = function(means_table, size,originals){
  means_table = within(means_table,{
    shoreline_shape= ifelse((means_table$shoreline_90q > (originals[1] * 1.05))| (means_table$shoreline_10q < (originals[1] * 0.95)),
                            ifelse((means_table$shoreline_90q > (originals[1] * 1.1))| (means_table$shoreline_10q < (originals[1] * 0.9)),15,17), 8
    )})
  means_table = within(means_table,{
    sinuosity_shape= ifelse((means_table$sinuosity_90q > (originals[2] * 1.05))| (means_table$sinuosity_10q < (originals[2] * 0.95)),
                            ifelse((means_table$sinuosity_90q > (originals[2] * 1.1))| (means_table$sinuosity_10q < (originals[2] * 0.9)),15,17), 8
    )})
  means_table = within(means_table,{
      total_sinuosity_shape= ifelse((means_table$total_sinuosity_90q > (originals[3] * 1.05))| (means_table$total_sinuosity_10q < (originals[3] * 0.95)),
                              ifelse((means_table$total_sinuosity_90q > (originals[3] * 1.1))| (means_table$total_sinuosity_10q < (originals[3] * 0.9)),15,17), 8
      )})
  means_table = within(means_table,{
    number_of_nodes_shape= ifelse((means_table$number_of_nodes_90q > (originals[4] * 1.05))| (means_table$number_of_nodes_10q < (originals[4] * 0.95)),
                            ifelse((means_table$number_of_nodes_90q > (originals[4] * 1.1))| (means_table$number_of_nodes_10q < (originals[4] * 0.9)),15,17), 8
    )})
  means_table = within(means_table,{
    width_variability_shape= ifelse((means_table$width_variability_90q > (originals[5] * 1.05))| (means_table$width_variability_10q < (originals[5] * 0.95)),
                            ifelse((means_table$width_variability_90q > (originals[5] * 1.1))| (means_table$width_variability_10q < (originals[5] * 0.9)),15,17), 8
    )})
  return (means_table)
}
#create plot from whiskers table
whiskers_plot = function(whiskers_table,x_var,column){
  shoreline_plot_5 = ggplot(whiskers_table)+
    geom_point(aes(x = x_var, y = shoreline, color=river),shape = whiskers_table$shoreline_shape)+
    guides(color=FALSE)+
    labs(x=colnames(whiskers_table)[1])+
    expand_limits(y = 0)+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
        axis.title.y=element_blank()
        )
  sinuosity_plot_5 = ggplot(whiskers_table)+
    geom_point(aes(x = x_var, y = sinuosity, color=river),shape = whiskers_table$sinuosity_shape)+
    guides(color=FALSE)+
    labs(x=colnames(whiskers_table)[1])+
    expand_limits(y = 0)+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
          axis.title.y=element_blank()
    )
  total_sinuosity_plot_5 = ggplot(whiskers_table)+
    geom_point(aes(x = x_var, y = total_sinuosity, color=river),shape = whiskers_table$total_sinuosity_shape)+
    guides(color=FALSE)+
    labs(x=colnames(whiskers_table)[1])+
    expand_limits(y = 0)+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
          axis.title.y=element_blank()
    )
  
  number_of_nodes_plot_5 = ggplot(whiskers_table)+
    geom_point(aes(x = x_var, y = number_of_nodes, color=river),shape = whiskers_table$number_of_nodes_shape)+
    guides(color=FALSE)+
    labs(x=colnames(whiskers_table)[1])+
    expand_limits(y = 0)+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
          axis.title.y=element_blank()
    )
  
  width_variability_plot_5 = ggplot(whiskers_table)+
    geom_point(aes(x = x_var, y = width_variability, color=river),shape = whiskers_table$width_variability_shape)+
    guides(color=FALSE)+
    labs(x=colnames(whiskers_table)[1])+
    expand_limits(y = 0)+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
          axis.title.y=element_blank()
    )
  pushViewport(viewport(layout = grid.layout(5, 4)))
  print(shoreline_plot_5, vp = viewport(layout.pos.row = 1, layout.pos.col = column))
  print(sinuosity_plot_5, vp = viewport(layout.pos.row = 2, layout.pos.col = column))
  print(total_sinuosity_plot_5, vp = viewport(layout.pos.row = 3, layout.pos.col = column))
  print(number_of_nodes_plot_5, vp = viewport(layout.pos.row = 4, layout.pos.col = column))
  print(width_variability_plot_5, vp = viewport(layout.pos.row = 5, layout.pos.col = column))
  whisker_plot = recordPlot()
  dev.off()
  return(whisker_plot)
}

#create plot from whiskers table for width extension
whiskers_plot_width = function(whiskers_table,x_var,column){
  shoreline_plot_5 = ggplot(whiskers_table)+
    geom_point(aes(x = x_var, y = shoreline, color=river),shape = whiskers_table$shoreline_shape)+
    guides(color=FALSE)+
    labs(x='minimum width (m)')+
    expand_limits(y = 0)+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
          axis.title.y=element_blank()
    )
  sinuosity_plot_5 = ggplot(whiskers_table)+
    geom_point(aes(x = x_var, y = sinuosity, color=river),shape = whiskers_table$sinuosity_shape)+
    guides(color=FALSE)+
    labs(x='minimum width (m)')+
    expand_limits(y = 0)+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
          axis.title.y=element_blank()
    )
  total_sinuosity_plot_5 = ggplot(whiskers_table)+
    geom_point(aes(x = x_var, y = total_sinuosity, color=river),shape = whiskers_table$total_sinuosity_shape)+
    guides(color=FALSE)+
    labs(x='minimum width (m)')+
    expand_limits(y = 0)+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
          axis.title.y=element_blank()
    )
  
  number_of_nodes_plot_5 = ggplot(whiskers_table)+
    geom_point(aes(x = x_var, y = number_of_nodes, color=river),shape = whiskers_table$number_of_nodes_shape)+
    guides(color=FALSE)+
    labs(x='minimum width (m)')+
    expand_limits(y = 0)+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
          axis.title.y=element_blank()
    )
  
  width_variability_plot_5 = ggplot(whiskers_table)+
    geom_point(aes(x = x_var, y = width_variability, color=river),shape = whiskers_table$width_variability_shape)+
    guides(color=FALSE)+
    labs(x='minimum width (m)')+
    expand_limits(y = 0)+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
          axis.title.y=element_blank()
    )
  pushViewport(viewport(layout = grid.layout(5, 4)))
  print(shoreline_plot_5, vp = viewport(layout.pos.row = 1, layout.pos.col = column))
  print(sinuosity_plot_5, vp = viewport(layout.pos.row = 2, layout.pos.col = column))
  print(total_sinuosity_plot_5, vp = viewport(layout.pos.row = 3, layout.pos.col = column))
  print(number_of_nodes_plot_5, vp = viewport(layout.pos.row = 4, layout.pos.col = column))
  print(width_variability_plot_5, vp = viewport(layout.pos.row = 5, layout.pos.col = column))
  whisker_plot = recordPlot()
  dev.off()
  return(whisker_plot)
}


#create plot from whiskers table
whiskers_plot_sd = function(whiskers_table,x_var,column){
  shoreline_plot_5 = ggplot(whiskers_table)+
    geom_errorbar(aes(x = x_var, ymax = shoreline + shoreline_sd, ymin = shoreline - shoreline_sd,width=0.3,color = river))+
    geom_point(aes(x = x_var, y = shoreline, color=river),shape = whiskers_table$shoreline_shape)+
    guides(color=FALSE)+
    labs(x=colnames(whiskers_table)[1])+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
        axis.title.y=element_blank()
  )
  sinuosity_plot_5 = ggplot(whiskers_table)+
    geom_errorbar(aes(x = x_var, ymax = sinuosity + sinuosity_sd, ymin = sinuosity - sinuosity_sd,width=0.3,color = river))+
    geom_point(aes(x = x_var, y = sinuosity, color=river),shape = whiskers_table$sinuosity_shape)+
    guides(color=FALSE)+
    labs(x=colnames(whiskers_table)[1])+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
        axis.title.y=element_blank()
  )
  total_sinuosity_plot_5 = ggplot(whiskers_table)+
    geom_errorbar(aes(x = x_var, ymax = total_sinuosity + total_sinuosity_sd, ymin = total_sinuosity - total_sinuosity_sd,width=0.3,color = river))+
    geom_point(aes(x = x_var, y = total_sinuosity, color=river),shape = whiskers_table$total_sinuosity_shape)+
    guides(color=FALSE)+
    labs(x=colnames(whiskers_table)[1])+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
        axis.title.y=element_blank()
  )
  
  number_of_nodes_plot_5 = ggplot(whiskers_table)+
    geom_errorbar(aes(x = x_var, ymax = number_of_nodes + number_of_nodes_sd, ymin = number_of_nodes - number_of_nodes_sd,width=0.3,color = river))+
    geom_point(aes(x = x_var, y = number_of_nodes, color=river),shape = whiskers_table$number_of_nodes_shape)+
    guides(color=FALSE)+
    labs(x=colnames(whiskers_table)[1])+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
        axis.title.y=element_blank()
  )
  
  width_variability_plot_5 = ggplot(whiskers_table)+
    geom_errorbar(aes(x = x_var, ymax = width_variability + width_variability_sd, ymin = width_variability - width_variability_sd,width=0.3,color = river))+
    geom_point(aes(x = x_var, y = width_variability, color=river),shape = whiskers_table$width_variability_shape)+
    guides(color=FALSE)+
    labs(x=colnames(whiskers_table)[1])+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
        axis.title.y=element_blank()
  )
  pushViewport(viewport(layout = grid.layout(5, 4)))
  print(shoreline_plot_5, vp = viewport(layout.pos.row = 1, layout.pos.col = column))
  print(sinuosity_plot_5, vp = viewport(layout.pos.row = 2, layout.pos.col = column))
  print(total_sinuosity_plot_5, vp = viewport(layout.pos.row = 3, layout.pos.col = column))
  print(number_of_nodes_plot_5, vp = viewport(layout.pos.row = 4, layout.pos.col = column))
  print(width_variability_plot_5, vp = viewport(layout.pos.row = 5, layout.pos.col = column))
  whisker_plot = recordPlot()
  dev.off()
  return(whisker_plot)
}

quantiles_plot = function(whiskers_table,x_var,column){
  shoreline_plot_5 = ggplot(whiskers_table)+
    geom_errorbar(aes(x = x_var, ymax = shoreline_90q, ymin = shoreline_10q,width=0.3,color = river))+
    geom_point(aes(x = x_var, y = shoreline, color=river),shape = whiskers_table$shoreline_shape)+
    guides(color=FALSE)+
    labs(x=colnames(whiskers_table)[1])+
    expand_limits(y = 0)+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
          axis.title.y=element_blank()
    )
  sinuosity_plot_5 = ggplot(whiskers_table)+
    geom_errorbar(aes(x = x_var, ymax = sinuosity_90q, ymin = sinuosity_10q,width=0.3,color = river))+
    geom_point(aes(x = x_var, y = sinuosity, color=river),shape = whiskers_table$sinuosity_shape)+
    guides(color=FALSE)+
    labs(x=colnames(whiskers_table)[1])+
    expand_limits(y = 0)+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
          axis.title.y=element_blank()
    )
  total_sinuosity_plot_5 = ggplot(whiskers_table)+
    geom_errorbar(aes(x = x_var, ymax = total_sinuosity_90q, ymin = total_sinuosity_10q,width=0.3,color = river))+
    geom_point(aes(x = x_var, y = total_sinuosity, color=river),shape = whiskers_table$total_sinuosity_shape)+
    guides(color=FALSE)+
    labs(x=colnames(whiskers_table)[1])+
    expand_limits(y = 0)+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
          axis.title.y=element_blank()
    )
  
  number_of_nodes_plot_5 = ggplot(whiskers_table)+
    geom_errorbar(aes(x = x_var, ymax = number_of_nodes_90q, ymin = number_of_nodes_10q,width=0.3,color = river))+
    geom_point(aes(x = x_var, y = number_of_nodes, color=river),shape = whiskers_table$number_of_nodes_shape)+
    guides(color=FALSE)+
    labs(x=colnames(whiskers_table)[1])+
    expand_limits(y = 0)+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
          axis.title.y=element_blank()
    )
  
  width_variability_plot_5 = ggplot(whiskers_table)+
    geom_errorbar(aes(x = x_var, ymax = width_variability_90q, ymin = width_variability_10q,width=0.3,color = river))+
    geom_point(aes(x = x_var, y = width_variability, color=river),shape = whiskers_table$width_variability_shape)+
    guides(color=FALSE)+
    labs(x=colnames(whiskers_table)[1])+
    expand_limits(y = 0)+
    theme_classic(base_size = 12, base_family = "")+
    theme(legend.position = 'none',
          axis.title.y=element_blank()
    )
  pushViewport(viewport(layout = grid.layout(5, 4)))
  print(shoreline_plot_5, vp = viewport(layout.pos.row = 1, layout.pos.col = column))
  print(sinuosity_plot_5, vp = viewport(layout.pos.row = 2, layout.pos.col = column))
  print(total_sinuosity_plot_5, vp = viewport(layout.pos.row = 3, layout.pos.col = column))
  print(number_of_nodes_plot_5, vp = viewport(layout.pos.row = 4, layout.pos.col = column))
  print(width_variability_plot_5, vp = viewport(layout.pos.row = 5, layout.pos.col = column))
  whisker_plot = recordPlot()
  dev.off()
  return(whisker_plot)
}