# This script creates a python toolbox to be used in ArcGIS Pro from Esri. 
# When ecological indicators are derived from river polygons that where extracted from maps, different error sources exist.
# This toolbox simulates several of these error sources. 
# The toolbox 'ecologicalIndicators' that derives ecological indicators from river polygons is then imported, to derive
# ecological indicators from the now erroneous polygons.
# The development of this Toolbox was part of my master thesis at the Zurich university of applied sciences ZHAW in 2018.

import arcpy


class Toolbox(object):
    def __init__(self):
        """Define the toolbox (the name of the toolbox is the name of the
        .pyt file)."""
        self.label = "errorSimulations"
        self.alias = "errorSimulations"

        # List of tool classes associated with this toolbox
        self.tools = [manual_digitizing,georeferencing,width_extension]


class manual_digitizing(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "Manual Digitizing"
        self.description = "This tool simulates errors that arise when rivers are digitized manually"
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""
        param0 = arcpy.Parameter(
            name = 'Parameter0',
            displayName = 'Input river feature class',
            parameterType = 'Required',                 
            datatype = 'DEFeatureClass')
        param0.filter.list = ['Polygon']
        param0.value = r'C:\zhaw\masterarbeit\data\digitalisieren\digitized_3km_smoothed_2010.gdb\Saane_smr_3km_smoothed'
        
        param1 = arcpy.Parameter(
            name = 'Parameter1',
            displayName = 'Output Folder',
            parameterType = 'Required' ,                   
            datatype = 'DEFolder')
        param1.value = r'C:\zhaw\masterarbeit\data\outputs\indicators\saane'
        
        param2 = arcpy.Parameter(
            name = 'Parameter2',
            displayName = 'New Folder',
            parameterType = 'Required',                     
            datatype = 'GPString' ) 
        param2.value = 'saane_smr'
        
        param3 = arcpy.Parameter(
            name = 'Parameter3',
            displayName = 'Number of iterations',
            parameterType = 'Required',
            datatype = 'GPLong' )
        
        param4 = arcpy.Parameter(
            name = 'Parameter4',
            displayName = 'Standard deviation',
            parameterType = 'Required',
            datatype = 'GPDouble' )  
        param4.value = 1
        
        param5 = arcpy.Parameter(
            name = 'Parameter5',
            displayName = 'Probability that a point will be moved in %',
            parameterType = 'Required',
            datatype = 'GPLong' )
        param5.filter.type = 'Range'
        param5.filter.list = [1,100]        
        param5.value = 100
        
        param6 = arcpy.Parameter(
            name = 'Parameter6',
            displayName = 'Execute ecologicalIndicators',
            parameterType = 'Optional',
            enabled = True,
            datatype = 'GPBoolean')
        param6.value = False        
        
        param7 = arcpy.Parameter(
            name = 'Parameter7',
            displayName = 'Delete temporary files',
            parameterType = 'Optional',     
            datatype = 'GPBoolean') 
        param7.value = True
        
        param8 = arcpy.Parameter(
            name = 'Parameter8',
            displayName = 'Maximum river width',                   
            datatype = 'GPLong' ,
            parameterType = 'Optional',
            direction="Input") 
        param8.value = 250
        
        return [param0,param1,param2,param3,param4,param5,param6,param7, param8]

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        if(parameters[6].value == True):
            parameters[7].value = True
        if(parameters[7].value == False):
            parameters[6].value = False   
                
        return

    #def updateMessages(self, parameters):
        #"""Modify the messages created by internal validation for each tool
        #parameter.  This method is called after internal validation."""
        #return

    def execute(self, parameters, messages):
        """The source code of the tool."""
        river_polygon = parameters[0].valueAsText
        output_folder = parameters[1].valueAsText
        new_folder = parameters[2].valueAsText
        numb_it = parameters[3].value
        sd = parameters[4].value
        move_prop = parameters[5].value
        ecologicalIndicators = parameters[6].valueAsText         
        del_temp = parameters[7].valueAsText 
        river_width = parameters[8].value
        new_folder = str(int(sd * 10))
        
        import os
        import numpy
        import random
        import sys
        
        arcpy.CreateFolder_management (output_folder,new_folder)
        out_folder = output_folder + '\\' + new_folder        
        arcpy.env.workspace = out_folder
        arcpy.env.overwriteOutput = True
        river_name = os.path.basename(river_polygon)
        name_gdb = river_name + '.gdb'
        out_gdb = out_folder + '\\' + name_gdb  
        #Delete geodatabase, if already present. Allows to overwrite geodatabase
        if arcpy.Exists(out_gdb):
            arcpy.Delete_management(out_gdb)  
        #Create a geodatabase to store the outputs
        arcpy.CreateFileGDB_management(out_folder, name_gdb) 
        #Dissolve input
        arcpy.Dissolve_management (river_polygon, out_gdb + '\\' + river_name)                 
        for item in range(1,numb_it + 1,1):
            arcpy.env.workspace = out_folder
            # simplify
            arcpy.cartography.SimplifyPolygon(out_gdb + '\\' + river_name, out_gdb + '\\' + river_name + '_simply', "POINT_REMOVE", "1 Meters", "0 SquareMeters", "RESOLVE_ERRORS", "NO_KEEP", None)
            #Create lines from polygon
            arcpy.FeatureToLine_management(out_gdb + '\\' + river_name + '_simply', out_folder + '\\FeToLi')
            #Add Field
            arcpy.AddField_management(out_folder + '\\' + 'FeToLi.shp','LineID','SHORT')
            arcpy.CalculateField_management(out_folder + '\\' + 'FeToLi.shp','LineID','!FID!','PYTHON')
            # Create Points from Feature vertices
            arcpy.FeatureVerticesToPoints_management(out_folder + '\\' + 'FeToLi.shp', out_folder + '\\' + 'FeVeToPo.shp')
            # Add XY coordinates
            arcpy.AddXY_management (out_folder + '\\' + 'FeVeToPo.shp')
            # Add random values to X and Y coordinate
            mean = 0
            update_rowsXY = arcpy.da.UpdateCursor(out_folder + '\\' + 'FeVeToPo.shp', ['POINT_X','POINT_Y'])
            for row in update_rowsXY:
                if random.randint(0,100) <= move_prop:
                    row = row + numpy.random.normal(mean,float(sd),1)
                    update_rowsXY.updateRow(row)            
            #Create table
            arcpy.TableToTable_conversion(out_folder + '\\' + 'FeVeToPo.shp', out_folder, 'manual_digitalization.csv')
            # Make points from table
            lyr = str(arcpy.MakeXYEventLayer_management(out_folder + '\\' + 'manual_digitalization.csv', 'POINT_X', 'POINT_Y', 'xy_layer',21781).getOutput(0))
            arcpy.CopyFeatures_management(lyr, out_folder + '\\' + 'copyPoints')
            #Add Field
            arcpy.AddField_management(out_folder + '\\' + 'copyPoints.shp','PointID','SHORT')
            arcpy.CalculateField_management(out_folder + '\\' + 'copyPoints.shp','PointID','!FID!','PYTHON')
            # Make lines from points
            arcpy.PointsToLine_management(out_folder + '\\' + 'copyPoints.shp', out_folder + '\\' + 'PoToLi','LineID','PointID','CLOSE')
            #Make polygon from lines
            arcpy.FeatureToPolygon_management(out_folder + '\\' + 'PoToLi.shp',out_folder + '\\' + 'LiToPo')
            #Select for polygon that has the highest boundary touching score, since this is expected not to be an island but the actual river
            arcpy.CopyFeatures_management(out_folder + '\\' + 'LiToPo.shp', out_folder + '\\' + 'LiToPo2')
            arcpy.analysis.SpatialJoin(out_folder + '\\' + 'LiToPo.shp', out_folder + '\\' + 'LiToPo2.shp', out_gdb + '\\' + 'LiToPoJoin',"JOIN_ONE_TO_ONE","KEEP_ALL","",  "BOUNDARY_TOUCHES")
            count_rows = arcpy.GetCount_management(out_gdb + '\\' + 'LiToPoJoin')        
            #If there is just 1 island, both the island and the river have the same boundery touching score. In this case the larger polygon will be selected            
            if count_rows == 1:
                lyr = arcpy.MakeFeatureLayer_management(out_gdb + '\\' + 'LiToPoJoin',out_gdb + '\\' + 'LiToPoJoin_select',"Shape_Area = (SELECT MAX(Shape_Area) FROM LiToPoJoin)")             
            #If there are more than 1 island, the polygon with the highest boundary touching score will be selected
            else:
                lyr = arcpy.MakeFeatureLayer_management(out_gdb + '\\' + 'LiToPoJoin',out_gdb + '\\' + 'LiToPoJoin_select',"Join_Count = (SELECT MAX(Join_Count) FROM LiToPoJoin)")                
            arcpy.CopyFeatures_management(lyr, out_folder + '\\' + 'random_polygon' + str(item))
            arcpy.topographic.PolygonToCenterline(out_gdb + '\\' + river_name, out_gdb + '\\' + 'centerline_original')
            arcpy.analysis.Buffer(out_gdb + '\\' + 'centerline_original', out_folder + '\\' + 'centerline_buffer', "1 Meters", "FULL", "FLAT", "ALL", None, "PLANAR")
            arcpy.Merge_management([out_folder + '\\' + 'random_polygon' + str(item) + '.shp', out_folder + '\\' + 'centerline_buffer.shp'], out_folder + '\\' + 'centerline_buffer_merge')
            arcpy.management.Dissolve(out_folder + '\\' + 'centerline_buffer_merge.shp', out_folder + '\\' + 'random_polygon_dis' + str(item), None, None, "MULTI_PART", "DISSOLVE_LINES")
            arcpy.management.EliminatePolygonPart(out_folder + '\\' + 'random_polygon_dis' + str(item) + '.shp', out_gdb + '\\' + 'random_polygon' + str(item), "AREA", "300 SquareMeters", 0, "CONTAINED_ONLY")
            if del_temp:
                list_shape = arcpy.ListFeatureClasses()
                for i in list_shape:
                    arcpy.Delete_management (i)    
                arcpy.Delete_management ('manual_digitalization.csv.xml')
                arcpy.Delete_management ('manual_digitalization.csv')                
                arcpy.env.workspace = out_gdb
                arcpy.Delete_management ('LiToPoJoin')
                arcpy.Delete_management ('centerline_original')                
                arcpy.Delete_management (river_name + '_simply')
                
        if ecologicalIndicators:
            arcpy.ImportToolbox('\\ecologicalIndicators.pyt')
            arcpy.env.workspace = out_folder 
            arcpy.CreateFileGDB_management(out_folder, 'indicators_table.gdb')
            arcpy.CreateTable_management (out_folder + '\\indicators_table.gdb', 'indicators_table')
            arcpy.AddField_management (out_folder +'\\indicators_table.gdb\\indicators_table', 'polygon', 'TEXT')            
            arcpy.AddField_management (out_folder +'\\indicators_table.gdb\\indicators_table', 'shoreline', 'DOUBLE')
            arcpy.AddField_management (out_folder +'\\indicators_table.gdb\\indicators_table', 'sinuosity', 'DOUBLE')
            arcpy.AddField_management (out_folder +'\\indicators_table.gdb\\indicators_table', 'total_sinuosity', 'DOUBLE')
            arcpy.AddField_management (out_folder +'\\indicators_table.gdb\\indicators_table', 'number_of_nodes', 'DOUBLE')
            arcpy.AddField_management (out_folder +'\\indicators_table.gdb\\indicators_table', 'width_variability', 'DOUBLE')            
            arcpy.env.workspace = out_gdb 
            list_random_polygons = arcpy.ListFeatureClasses()
            for item in list_random_polygons:
                arcpy.ecologicalIndicators_EcologicalIndicators(item, out_folder, new_folder + '_outputs', river_width, True)
                arcpy.management.Append(out_folder + '\\' + new_folder + '_outputs' + '\\' + item + '.gdb\\' + item + '_indicators', out_folder + '\\' + 'indicators_table.gdb\\indicators_table', "NO_TEST")
                
        return

class georeferencing(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "Georeferencing"
        self.description = "This tool simulates errors that arise when maps are georeferenced"
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""
        param0 = arcpy.Parameter(
            name = 'Parameter0',
            displayName = 'Input river feature class',
            parameterType = 'Required',                 
            datatype = 'DEFeatureClass')
        param0.filter.list = ['Polygon']
        param0.value = r'C:\zhaw\masterarbeit\data\digitalisieren\digitized_3km_smoothed_2010.gdb\Saane_smr_3km_smoothed'
        
        param1 = arcpy.Parameter(
            name = 'Parameter1',
            displayName = 'Output Folder',
            parameterType = 'Required' ,                   
            datatype = 'DEFolder')
        param1.value = r'C:\zhaw\masterarbeit\data\outputs\indicators\saane'
        
        param2 = arcpy.Parameter(
            name = 'Parameter2',
            displayName = 'New Folder',
            parameterType = 'Required',                     
            datatype = 'GPString' ) 
        param2.value = 'toolbox2'
        
        param3 = arcpy.Parameter(
            name = 'Parameter3',
            displayName = 'Number of iterations',
            parameterType = 'Required',
            datatype = 'GPLong' )
        param3.value = 1
        
        param4 = arcpy.Parameter(
            name = 'Parameter4',
            displayName = 'Mean',
            parameterType = 'Required',
            datatype = 'GPDouble' )  
        param4.value = 0   
        
        param5 = arcpy.Parameter(
            name = 'Parameter5',
            displayName = 'Standard deviation',
            parameterType = 'Required',
            datatype = 'GPDouble' )  
        param5.value = 1   
        
        param6 = arcpy.Parameter(
            name = 'Parameter6',
            displayName = 'Cellsize',
            parameterType = 'Required',
            datatype = 'GPDouble' )  
        param6.value = 0.1  
        
        param7 = arcpy.Parameter(
            name = 'Parameter7',
            displayName = 'Execute ecologicalIndicators',
            parameterType = 'Optional',
            enabled = True,
            datatype = 'GPBoolean')
        param7.value = False      
        
        param8 = arcpy.Parameter(
            name = 'Parameter8',
            displayName = 'Delete temporary files',
            parameterType = 'Optional',     
            datatype = 'GPBoolean')     
        
        
        param9 = arcpy.Parameter(
            name = 'Parameter9',
            displayName = 'Maximum river width',
            parameterType = 'Optional',                     
            datatype = 'GPLong' ) 
        param9.value = 250      
        
        return [param0,param1,param2,param3,param4,param5,param6,param7,param8, param9]
    
           
    
    #def isLicensed(self):
        #"""Set whether tool is licensed to execute."""
        #return True

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        if(parameters[7].value == True):
            parameters[8].value = True
          
        return

    #def updateMessages(self, parameters):
        #"""Modify the messages created by internal validation for each tool
        #parameter.  This method is called after internal validation."""
        #return    
        
    def execute(self, parameters, messages):
        """The source code of the tool.""" 
        river_polygon = parameters[0].valueAsText
        output_folder = parameters[1].valueAsText
        new_folder = parameters[2].valueAsText
        numb_it = parameters[3].valueAsText
        mean = parameters[4].valueAsText
        sd = parameters[5].value
        Cellsize = parameters[6].valueAsText
        ecologicalIndicators = parameters[7].valueAsText         
        del_temp = parameters[8].valueAsText 
        river_width = parameters[9].valueAsText
        new_folder = str(int(sd * 10))
        
        
        import os
        import numpy
        import random
        
        arcpy.CreateFolder_management (output_folder,new_folder)
        out_folder = output_folder + '\\' + new_folder        
        arcpy.env.workspace = out_folder
        arcpy.env.overwriteOutput = True
        river_name = os.path.basename(river_polygon)        
        name_gdb = river_name + '.gdb'
        out_gdb = out_folder + '\\' + name_gdb  
        #Delete geodatabase, if already present. Allows to overwrite geodatabase
        if arcpy.Exists(out_gdb):
            arcpy.Delete_management(out_gdb)  
        #Create a geodatabase to store the outputs
        arcpy.CreateFileGDB_management(out_folder, name_gdb) 
        #Dissolve input
        arcpy.Dissolve_management (river_polygon, out_gdb + '\\' + river_name)        
        #      
        #Unify river_polygon with minimum_bounding_geometry and convert to raster
        arcpy.env.workspace = out_folder        
        arcpy.MinimumBoundingGeometry_management(out_gdb + '\\' + river_name,out_folder + '\\' + 'min_bound', 'ENVELOPE')
        arcpy.Union_analysis ([out_gdb + '\\' + river_name,out_folder + '\\' + 'min_bound.shp'], out_folder + '\\' + 'river_min_bound_union')
        arcpy.conversion.PolygonToRaster(out_folder + '\\' + 'river_min_bound_union.shp', 'FID', out_gdb + '\\' + 'union_raster',cellsize = Cellsize)
        #get source_control_points
        arcpy.Buffer_analysis (out_folder + '\\' + 'min_bound.shp', out_gdb + '\\' + 'min_bound_buffer', -100)
        #start iteration here
        for item in range(1,int(numb_it) + 1,1):
            arcpy.env.workspace = out_folder            
            arcpy.FeatureVerticesToPoints_management(out_gdb + '\\' + 'min_bound_buffer', out_folder + '\\' + 'source_control_points_all')
            lyr = arcpy.MakeFeatureLayer_management(out_folder + '\\' + 'source_control_points_all.shp',out_folder + '\\' + 'source_control_points',"FID IN (0,1,2,3)")        
            arcpy.CopyFeatures_management(lyr, out_folder + '\\' + 'source_control_points')   
            arcpy.AddXY_management (out_folder + '\\' + 'source_control_points.shp')
            #Merge fields X and Y
            arcpy.AddField_management(out_folder + '\\' + 'source_control_points.shp','source','TEXT')
            arcpy.CalculateField_management(out_folder + '\\' + 'source_control_points.shp','source', "str(!POINT_X!) + ' ' + str(!POINT_Y!)",'PYTHON')
            #Make list of source points
            list_source = []
            update_rowsSource = arcpy.da.UpdateCursor(out_folder + '\\' + 'source_control_points.shp', ['source'])
            for row in update_rowsSource:
                list_source = list_source + row
            #Get target_control_points
            update_rowsX = arcpy.da.UpdateCursor(out_folder + '\\' + 'source_control_points.shp', ['POINT_X'])
            for row in update_rowsX:
                if random.randint(0,100) <= 50:
                    row = row + numpy.random.normal(int(mean),float(sd),1)
                    update_rowsX.updateRow(row)
                else:
                    row = row - numpy.random.normal(int(mean),float(sd),1)
                    update_rowsX.updateRow(row)        
            update_rowsY = arcpy.da.UpdateCursor(out_folder + '\\' + 'source_control_points.shp', ['POINT_Y'])
            for row in update_rowsY:
                if random.randint(0,100) <= 50:
                    row = row + numpy.random.normal(int(mean),float(sd),1)
                    update_rowsY.updateRow(row)
                else:
                    row = row - numpy.random.normal(int(mean),float(sd),1)
                    update_rowsY.updateRow(row)    
            #Merge new fields X and Y
            arcpy.AddField_management(out_folder + '\\' + 'source_control_points.shp','target','TEXT')
            arcpy.CalculateField_management(out_folder + '\\' + 'source_control_points.shp','target', "str(!POINT_X!) + ' ' + str(!POINT_Y!)",'PYTHON')
            #Make list of target points
            list_target = []
            update_rowsTarget = arcpy.da.UpdateCursor(out_folder + '\\' + 'source_control_points.shp', ['target'])
            for row in update_rowsTarget:
                list_target = list_target + row
            #Warp
            arcpy.Warp_management(out_gdb + '\\' + 'union_raster',list_source,list_target, out_folder + '\\' + 'transformed_raster.tif', transformation_type = 'PROJECTIVE')
            #Make river_polygon from transformed_raster
            arcpy.conversion.RasterToPolygon(out_folder + '\\' + 'transformed_raster.tif', out_folder + '\\' + 'transformed_polygon_all')
            arcpy.management.AddGeometryAttributes(out_folder + '\\' + 'transformed_polygon_all.shp', 'AREA_GEODESIC')
            lyr = arcpy.MakeFeatureLayer_management(out_folder + '\\' + 'transformed_polygon_all.shp',out_gdb + '\\' + 'transformed_polygon_lyr',"gridcode = 1")        
            arcpy.CopyFeatures_management(lyr, out_gdb + '\\' + 'transformed_polygon_grid')
            lyr = arcpy.MakeFeatureLayer_management(out_gdb + '\\' + 'transformed_polygon_grid',out_gdb + '\\' + 'transformed_pol_grid_lyr',"AREA_GEO = (SELECT MAX(AREA_GEO) FROM transformed_polygon_grid)")        
            arcpy.CopyFeatures_management(lyr, out_gdb + '\\' + 'transformed_polygon'  + str(item))    
            arcpy.management.RepairGeometry(out_gdb + '\\' + 'transformed_polygon'  + str(item), "DELETE_NULL", "ESRI")
            #delete temporary files
            if del_temp:
                arcpy.env.workspace = out_folder
                list_shape = arcpy.ListFeatureClasses()
                for i in list_shape:
                    arcpy.Delete_management (i)
                list_raster = arcpy.ListRasters ()
                for i in list_raster:
                    arcpy.Delete_management (i)
                arcpy.env.workspace = out_gdb
                arcpy.Delete_management ('transformed_polygon_grid') 
                
        if ecologicalIndicators:
            arcpy.env.workspace = out_folder             
            arcpy.ImportToolbox('\\ecologicalIndicators.pyt')
            arcpy.CreateFileGDB_management(out_folder, 'indicators_table.gdb')
            arcpy.CreateTable_management (out_folder + '\\indicators_table.gdb', 'indicators_table')
            arcpy.AddField_management ('indicators_table.gdb\\indicators_table', 'polygon', 'TEXT')            
            arcpy.AddField_management ('indicators_table.gdb\\indicators_table', 'shoreline', 'DOUBLE')
            arcpy.AddField_management ('indicators_table.gdb\\indicators_table', 'sinuosity', 'DOUBLE')
            arcpy.AddField_management ('indicators_table.gdb\\indicators_table', 'total_sinuosity', 'DOUBLE')
            arcpy.AddField_management ('indicators_table.gdb\\indicators_table', 'number_of_nodes', 'DOUBLE')
            arcpy.AddField_management ('indicators_table.gdb\\indicators_table', 'width_variability', 'DOUBLE')            
            arcpy.env.workspace = out_gdb 
            arcpy.Delete_management('min_bound_buffer')            
            list_random_polygons = arcpy.ListFeatureClasses()
            for item in list_random_polygons:
                arcpy.ecologicalIndicators_EcologicalIndicators(item, out_folder, new_folder + '_outputs', river_width, True)
                arcpy.management.Append(out_folder + '\\' + new_folder + '_outputs' + '\\' + item + '.gdb\\' + item + '_indicators', out_folder + '\\' + 'indicators_table.gdb\\indicators_table', "NO_TEST")
                
                
        return
    
class width_extension(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "Width extension"
        self.description = "This tool simulates errors that arise when rivers are represented to wide."
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""
        param0 = arcpy.Parameter(
            name = 'Parameter0',
            displayName = 'Input river feature class',
            parameterType = 'Required',                 
            datatype = 'DEFeatureClass')
        param0.filter.list = ['Polygon']
        param0.value = r'C:\zhaw\masterarbeit\data\digitalisieren\digitized_3km_smoothed_2010.gdb\Saane_smr_3km_smoothed'
        
        
        param1 = arcpy.Parameter(
            name = 'Parameter1',
            displayName = 'Output Folder',
            parameterType = 'Required' ,                   
            datatype = 'DEFolder')
        param1.value = r'C:\zhaw\masterarbeit\data\outputs\indicators\saane'
        
        param2 = arcpy.Parameter(
            name = 'Parameter2',
            displayName = 'New Folder',
            parameterType = 'Required',                     
            datatype = 'GPString' ) 
        param2.value = 'toolbox'
        
        param3 = arcpy.Parameter(
            name = 'Parameter3',
            displayName = 'Buffer distance',
            parameterType = 'Required',
            multiValue = True,
            datatype = 'GPDouble' )
        param3.filter.type = 'Range'
        param3.filter.list = [0.0000000000000000000000000000001,10000]         
        param3.values = [0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,9.5,10]
        
        param4 = arcpy.Parameter(
            name = 'Parameter4',
            displayName = 'Execute ecologicalIndicators',
            parameterType = 'Optional',
            enabled = True,
            datatype = 'GPBoolean')
        param4.value = False      
        
        param5 = arcpy.Parameter(
            name = 'Parameter5',
            displayName = 'Delete temporary files',
            parameterType = 'Optional',     
            datatype = 'GPBoolean') 
        
        param6 = arcpy.Parameter(
            name = 'Parameter6',
            displayName = 'Maximum river width',
            parameterType = 'Optional',                     
            datatype = 'GPLong' ) 
        param6.value = 250             
        
        
        return [param0,param1,param2,param3,param4,param5, param6]
            
        
    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        if(parameters[4].value == True):
            parameters[5].value = True
        if(parameters[5].value == False):
            parameters[4].value= False     
        return        
    
    def execute(self, parameters, messages):
        """The source code of the tool.""" 
        river_polygon = parameters[0].valueAsText
        output_folder = parameters[1].valueAsText
        new_folder = parameters[2].valueAsText
        buffer_distance = parameters[3].values
        ecologicalIndicators = parameters[4].valueAsText                 
        del_temp = parameters[5].valueAsText 
        river_width = parameters[6].value
        
        import arcpy
        import os
        import random
        import numpy
        import sys
        arcpy.CheckOutExtension ('Spatial')
        arcpy.CheckOutExtension ('foundation')
        import arcpy.sa        
        
        arcpy.CreateFolder_management (output_folder,new_folder)
        out_folder = output_folder + '\\' + new_folder        
        arcpy.env.workspace = out_folder
        arcpy.env.overwriteOutput = True
        river_name = os.path.basename(river_polygon)                
        name_gdb = river_name + '.gdb'
        out_gdb = out_folder + '\\' + name_gdb    
        #Create a geodatabase to store the outputs
        arcpy.CreateFileGDB_management(out_folder, name_gdb) 
        #Dissolve input
        arcpy.Dissolve_management (river_polygon, out_gdb + '\\' + river_name) 
        #Densify to remove weird centerline ends
        arcpy.edit.Densify(out_gdb + '\\' + river_name, "DISTANCE", "0.1 Meters", "0.1 Meters", 10)        
        #Create centerline
        arcpy.topographic.PolygonToCenterline(out_gdb + '\\' + river_name, out_gdb + '\\' + 'centerline_rough1')
        arcpy.cartography.SmoothLine(out_gdb + '\\' + 'centerline_rough1', out_gdb + '\\' + 'centerline', "PAEK", "50 Meters", "FIXED_CLOSED_ENDPOINT", "NO_CHECK", None)
        #arcpy.cartography.SmoothLine(out_gdb + '\\' + 'centerline_rough2', out_gdb + '\\' + 'centerline', "PAEK", "1 Meters", "FIXED_CLOSED_ENDPOINT", "NO_CHECK", None)        
        
        for item in buffer_distance:
            if item == 0:
                continue            
            #buffer
            arcpy.Buffer_analysis (out_gdb + '\\' + 'centerline', out_folder + '\\' + 'buff' + (str(item).replace('.','_')), item,line_end_type = 'FLAT',dissolve_option = 'ALL')
            #merge
            arcpy.Merge_management([out_gdb + '\\' + river_name, out_folder + '\\' + 'buff' + (str(item).replace('.','_')) + '.shp'], out_folder + '\\' + 'merge' + (str(item).replace('.','_')))
            #dissolve
            arcpy.Dissolve_management (out_folder + '\\' + 'merge' + (str(item).replace('.','_')) + '.shp', out_gdb + '\\' + 'min_width' + (str(item).replace('.','_')))
            #delete temp files
            arcpy.env.workspace = out_folder            
            if del_temp:
                arcpy.Delete_management (out_gdb + '\\' + 'centerline_rough1') 
                #arcpy.Delete_management (out_gdb + '\\' + 'centerline_rough2')                 
                list_shape = arcpy.ListFeatureClasses()
                for item in list_shape:
                    arcpy.Delete_management (item) 
                    
        if ecologicalIndicators:
            arcpy.ImportToolbox('\\ecologicalIndicators.pyt')
            arcpy.env.workspace = out_folder 
            arcpy.CreateFileGDB_management(out_folder, 'indicators_table.gdb')
            arcpy.CreateTable_management (out_folder + '\\indicators_table.gdb', 'indicators_table')
            arcpy.AddField_management ('indicators_table.gdb\\indicators_table', 'polygon', 'TEXT')            
            arcpy.AddField_management ('indicators_table.gdb\\indicators_table', 'shoreline', 'DOUBLE')
            arcpy.AddField_management ('indicators_table.gdb\\indicators_table', 'sinuosity', 'DOUBLE')
            arcpy.AddField_management ('indicators_table.gdb\\indicators_table', 'total_sinuosity', 'DOUBLE')
            arcpy.AddField_management ('indicators_table.gdb\\indicators_table', 'number_of_nodes', 'DOUBLE')
            arcpy.AddField_management ('indicators_table.gdb\\indicators_table', 'width_variability', 'DOUBLE')            
            arcpy.env.workspace = out_gdb 
            arcpy.Delete_management('centerline')                        
            list_random_polygons = arcpy.ListFeatureClasses()
            for item in list_random_polygons:
                arcpy.ecologicalIndicators_EcologicalIndicators(item, out_folder, new_folder + '_outputs', river_width, True)
                arcpy.management.Append(out_folder + '\\' + new_folder + '_outputs' + '\\' + item + '.gdb\\' + item + '_indicators', out_folder + '\\' + 'indicators_table.gdb\\indicators_table', "NO_TEST")
        
        return