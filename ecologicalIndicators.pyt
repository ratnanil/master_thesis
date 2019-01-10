# This script creates a python toolbox to be used in ArcGIS Pro from Esri. 
# The toolbox derives different ecological indicators from river polygons, such as the shorelinelength or the sinuosity.
# The development of this Toolbox was part of my master thesis at the Zurich university of applied sciences ZHAW in 2018.

import arcpy
import os
import numpy
import random
import sys


class Toolbox(object):
    def __init__(self):
        """Define the toolbox (the name of the toolbox is the name of the
        .pyt file)."""
        self.label = "EcologicalIndicators"
        self.alias = "EcologicalIndicators"

        # List of tool classes associated with this toolbox
        self.tools = [ecologicalIndicators]


class ecologicalIndicators(object):
    def __init__(self):
        """Define the tool (tool name is the name of the class)."""
        self.label = "ecologicalIndicators"
        self.description = "This tool derives ecological indicators from a river Polygon"
        self.canRunInBackground = False

    def getParameterInfo(self):
        """Define parameter definitions"""
        param0 = arcpy.Parameter(
            name = 'Parameter0',
            displayName = 'Input river feature class',
            parameterType = 'Required',                 
            datatype = 'DEFeatureClass')
        param0.filter.list = ['Polygon']
        param0.value = r'C:\zhaw\masterarbeit\data\digitalisieren\digitized_3km_smoothed_2010.gdb\Sense_smr_3km_smoothed'
        
        param1 = arcpy.Parameter(
            name = 'Parameter1',
            displayName = 'Output Folder',
            parameterType = 'Required' ,                   
            datatype = 'DEFolder')
        param1.value = r'C:\zhaw\masterarbeit\data\outputs\indicators\sense'
        
        param2 = arcpy.Parameter(
            name = 'Parameter2',
            displayName = 'New Folder',
            parameterType = 'Required',                     
            datatype = 'GPString' ) 
        param2.value = 'toolbox'   
        
        param3 = arcpy.Parameter(
            name = 'Parameter3',
            displayName = 'Maximum river width',
            parameterType = 'Required',                     
            datatype = 'GPString' ) 
        param3.value = '250'
        
        param4 = arcpy.Parameter(
            name = 'Parameter4',
            displayName = 'Delete temporary files',
            parameterType = 'Optional',                     
            datatype = 'GPBoolean' ) 
        param4.value = True
        
        return [param0,param1,param2,param3,param4]

    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        return

    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return

    def execute(self, parameters, messages):
        """The source code of the tool."""
        river_polygon = parameters[0].valueAsText
        output_folder = parameters[1].valueAsText
        new_folder = parameters[2].valueAsText
        river_width = parameters[3].valueAsText
        del_temp = parameters[4].valueAsText 
        
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
        arcpy.Dissolve_management (river_polygon, out_gdb + '\\' + river_name, multi_part = 'SINGLE_PART')  
        #Densify to remove weird centerline ends
        arcpy.edit.Densify(out_gdb + '\\' + river_name, "DISTANCE", "1 Meters", "0.1 Meters", 10)
        #Create Centerline
        arcpy.PolygonToCenterline_topographic(out_gdb + '\\' + river_name, out_gdb + '\\' + river_name + '_centerline_no_dis')  
        #repair geometry
        arcpy.management.RepairGeometry(out_gdb + '\\' + river_name + '_centerline_no_dis', 'DELETE_NULL', 'ESRI')
        #Dissolve input
        arcpy.Dissolve_management (out_gdb + '\\' + river_name + '_centerline_no_dis', out_gdb + '\\' + river_name + '_centerline_no_dis2', multi_part = 'SINGLE_PART') 
        arcpy.edit.ExtendLine(out_gdb + '\\' + river_name + '_centerline_no_dis2', "1 Meters", "EXTENSION")
        arcpy.edit.TrimLine(out_gdb + '\\' + river_name + '_centerline_no_dis2', "1 Meters", "DELETE_SHORT")
        arcpy.Dissolve_management (out_gdb + '\\' + river_name + '_centerline_no_dis2', out_gdb + '\\' + river_name + '_centerline', multi_part = 'SINGLE_PART')         
        arcpy.management.RepairGeometry(out_gdb + '\\' + river_name + '_centerline', 'DELETE_NULL', 'ESRI')        
        arcpy.edit.TrimLine(out_gdb + '\\' + river_name + '_centerline', "16 Meters", "DELETE_SHORT")
        arcpy.edit.TrimLine(out_gdb + '\\' + river_name + '_centerline', "16 Meters", "DELETE_SHORT")
        #Create nodes        
        arcpy.analysis.Intersect(out_gdb + '\\' + river_name + '_centerline', out_gdb + '\\' + river_name + '_nodes_no_dis', "ALL", None, "POINT")
        arcpy.Dissolve_management (out_gdb + '\\' + river_name + '_nodes_no_dis', out_gdb + '\\' + river_name + '_nodes_no_dis2',multi_part = 'SINGLE_PART') 
        #Create mainline
        arcpy.analysis.Union(out_gdb + '\\' + river_name, out_gdb + '\\' + river_name + '_union', "ALL", None, "NO_GAPS")
        arcpy.Dissolve_management (out_gdb + '\\' + river_name + '_union', out_gdb + '\\' + river_name + '_union_dis',multi_part = 'SINGLE_PART')         
        arcpy.PolygonToCenterline_topographic(out_gdb + '\\' + river_name + '_union_dis', out_gdb + '\\' + river_name + '_mainline')  
        #
        arcpy.Dissolve_management (out_gdb + '\\' + river_name + '_mainline', out_gdb + '\\' + river_name + '_mainline2', multi_part = 'SINGLE_PART') 
        arcpy.analysis.Intersect(out_gdb + '\\' + river_name + '_mainline2', out_gdb + '\\' + river_name + 'nodes_main', "ALL", None, "POINT")
        arcpy.Dissolve_management (out_gdb + '\\' + river_name + 'nodes_main', out_gdb + '\\' + river_name + 'nodes_main2',multi_part = 'SINGLE_PART') 
        arcpy.analysis.Erase(out_gdb + '\\' + river_name + '_nodes_no_dis2', out_gdb + '\\' + river_name + 'nodes_main2', out_gdb + '\\' + river_name + '_nodes')        
        arcpy.edit.TrimLine(out_gdb + '\\' + river_name + '_mainline', "16 Meters", "DELETE_SHORT")  
        arcpy.edit.TrimLine(out_gdb + '\\' + river_name + '_mainline', "16 Meters", "DELETE_SHORT")         
        #Get cartesian distance
        arcpy.management.FeatureVerticesToPoints(out_gdb + '\\' + river_name + '_mainline', out_gdb + '\\' + river_name + '_mainline' + '_ends',"BOTH_ENDS")
        arcpy.PointsToLine_management(out_gdb + '\\' + river_name + '_mainline' + '_ends', out_gdb + '\\' + river_name + '_cartesian_distance') 
        #Calculate Sinuosity
        arcpy.Copy_management (out_gdb + '\\' + river_name + '_mainline', out_gdb + '\\' + river_name + '_sinuosity')        
        arcpy.management.AlterField(out_gdb + '\\' + river_name + '_mainline', 'Shape_Length', None, 'mainline_length')        
        arcpy.management.AlterField(out_gdb + '\\' + river_name + '_cartesian_distance', 'Shape_Length', None, 'cartesian_distance')
        arcpy.Copy_management (out_gdb + '\\' + river_name + '_mainline', out_gdb + '\\' + river_name + '_sinuosity')
        arcpy.JoinField_management (out_gdb + '\\' + river_name + '_sinuosity', "OBJECTID", out_gdb + '\\' + river_name + '_cartesian_distance', "OBJECTID")
        arcpy.AddField_management(out_gdb + '\\' + river_name + '_sinuosity','sinuosity','DOUBLE')
        arcpy.management.CalculateField(out_gdb + '\\' + river_name + '_sinuosity','sinuosity', '!SHAPE_Length! / 3000','PYTHON3')
        #Calculate total Sinuosity
        arcpy.Copy_management (out_gdb + '\\' + river_name + '_centerline_no_dis', out_gdb + '\\' + river_name + '_total_sinuosity')  
        arcpy.management.AlterField(out_gdb + '\\' + river_name + '_total_sinuosity', 'Shape_Length', None, 'centerline_length')        
        arcpy.JoinField_management (out_gdb + '\\' + river_name + '_total_sinuosity', "OBJECTID", out_gdb + '\\' + river_name + '_cartesian_distance', "OBJECTID")
        arcpy.AddField_management(out_gdb + '\\' + river_name + '_total_sinuosity','total_sinuosity','DOUBLE')
        #selection = river_name + '_total_sinuosity1'
        #lyr = arcpy.MakeFeatureLayer_management(out_gdb + '\\' + river_name + '_total_sinuosity1',out_gdb + '\\' + river_name + '_total_sinuosity_select', "SHAPE_Length = (SELECT MAX(SHAPE_Length) FROM selection)")
        #arcpy.CopyFeatures_management(lyr, out_gdb + '\\' + river_name + '_total_sinuosity')
        arcpy.management.CalculateField(out_gdb + '\\' + river_name + '_total_sinuosity','total_sinuosity', '!SHAPE_Length! / 3000','PYTHON3') 
        #lyr = arcpy.MakeFeatureLayer_management(out_gdb + '\\' + 'LiToPoJoin',out_gdb + '\\' + 'LiToPoJoin_select',"Join_Count = (SELECT MAX(Join_Count) FROM LiToPoJoin)")                
        #arcpy.CopyFeatures_management(lyr, out_folder + '\\' + 'random_polygon' + str(item))
        #"Join_Count = (SELECT MAX(Join_Count) FROM LiToPoJoin)"
        #Create shoreline
        arcpy.management.FeatureToLine(out_gdb + '\\' + river_name, out_gdb + '\\' + river_name + '_shoreline')
        arcpy.analysis.Statistics(out_gdb + '\\' + river_name + '_shoreline', out_gdb + '\\' + river_name + '_shoreline_stats', [['Shape_Length', 'SUM']])
        arcpy.JoinField_management (out_gdb + '\\' + river_name + '_shoreline', "OBJECTID", out_gdb + '\\' + river_name + '_shoreline_stats', "OBJECTID")
        arcpy.JoinField_management (out_gdb + '\\' + river_name + '_shoreline', "OBJECTID", out_gdb + '\\' + river_name + '_mainline', "OBJECTID")
        arcpy.AddField_management(out_gdb + '\\' + river_name + '_shoreline','shoreline','DOUBLE')   
        arcpy.management.CalculateField(out_gdb + '\\' + river_name + '_shoreline','shoreline', '!SUM_Shape_Length! / !Shape_Length_1!','PYTHON3')        
        #Create Nodes areas
        arcpy.analysis.Near(out_gdb + '\\' + river_name + '_nodes', out_gdb + '\\' + river_name + '_shoreline')
        arcpy.analysis.Buffer(out_gdb + '\\' + river_name + '_nodes', out_gdb + '\\' + river_name + '_nodes_areas', "NEAR_DIST", "FULL", "ROUND", "ALL", None, "PLANAR")
        #Generate transects    
        arcpy.cartography.SmoothLine(out_gdb + '\\' + river_name + '_mainline', out_gdb + '\\' + river_name + '_mainline_smoothed', "PAEK", "50 Meters", "FIXED_CLOSED_ENDPOINT", "NO_CHECK", None)
        arcpy.analysis.Erase(out_gdb + '\\' + river_name + '_mainline_smoothed', out_gdb + '\\' + river_name + '_nodes_areas', out_gdb + '\\' + river_name + '_mainline_erased')
        arcpy.management.GenerateTransectsAlongLines(out_gdb + '\\' + river_name + '_mainline_erased', out_gdb + '\\' + river_name + '_transects_long', "25 Meters", river_width + " Meters", "NO_END_POINTS")
        arcpy.analysis.Clip(out_gdb + '\\' + river_name + '_transects_long', out_gdb + '\\' + river_name, out_gdb + '\\' + river_name + '_transects', None)
        #Create 1 file with all indicators
        arcpy.Rename_management (out_gdb + '\\' + river_name + '_shoreline_stats', out_gdb + '\\' + river_name + '_indicators')
        arcpy.DeleteField_management (out_gdb + '\\' + river_name + '_indicators', ['FREQUENCY','SUM_Shape_Length'])
        arcpy.AddField_management(out_gdb + '\\' + river_name + '_indicators','polygon','TEXT')   
        with arcpy.da.UpdateCursor(out_gdb + '\\' + river_name + '_indicators', ['polygon']) as cursor:
            for row in cursor:
                row[0] = river_name
                cursor.updateRow(row)           
        
        arcpy.JoinField_management (out_gdb + '\\' + river_name + '_indicators', "OBJECTID", out_gdb + '\\' + river_name + '_shoreline', "OBJECTID",['shoreline'])
        arcpy.JoinField_management (out_gdb + '\\' + river_name + '_indicators', "OBJECTID", out_gdb + '\\' + river_name + '_sinuosity', "OBJECTID",['sinuosity'])
        arcpy.JoinField_management (out_gdb + '\\' + river_name + '_indicators', "OBJECTID", out_gdb + '\\' + river_name + '_total_sinuosity', "OBJECTID",['total_sinuosity'])        
        arcpy.analysis.Statistics(out_gdb + '\\' + river_name + '_nodes', out_gdb + '\\' + river_name + '_nodes_stats', [['OBJECTID', 'MAX']])
        arcpy.management.AlterField(out_gdb + '\\' + river_name + '_nodes_stats', 'MAX_OBJECTID', 'number_of_nodes', 'number_of_nodes')                
        arcpy.JoinField_management (out_gdb + '\\' + river_name + '_indicators', "OBJECTID", out_gdb + '\\' + river_name + '_nodes_stats', "OBJECTID",['number_of_nodes'])
        arcpy.analysis.Statistics(out_gdb + '\\' + river_name + '_transects', out_gdb + '\\' + river_name + '_transects_stats', [['Shape_Length', 'MEAN'], ['Shape_Length', 'STD']])        
        arcpy.AddField_management(out_gdb + '\\' + river_name + '_transects_stats','width_variability','DOUBLE')   
        arcpy.management.CalculateField(out_gdb + '\\' + river_name + '_transects_stats','width_variability', "!STD_Shape_Length! / !MEAN_Shape_Length! * 100",'PYTHON3')        
        arcpy.JoinField_management (out_gdb + '\\' + river_name + '_indicators', "OBJECTID", out_gdb + '\\' + river_name + '_transects_stats', "OBJECTID",['width_variability'])

        if del_temp:
            arcpy.env.workspace = out_gdb
            del_list = [river_name + '_centerline_no_dis', river_name + '_nodes_no_dis',river_name + '_union', river_name + '_union_dis', river_name + '_mainline' + '_ends', river_name + '_shoreline_stats', river_name + '_nodes_areas', river_name + '_mainline_erased',river_name + '_transects_long',river_name + '_nodes_stats',river_name + '_transects_stats',river_name + '_centerline_no_dis2',river_name + 'nodes_main2',river_name + '_mainline2',river_name + '_nodes_no_dis2',river_name + 'nodes_main']
            for item in del_list:
                arcpy.Delete_management(item)
        return
