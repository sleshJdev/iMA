# IronPython imports to enable Excel interop,
import clr
clr.AddReference("Microsoft.Office.Interop.Excel")
import Microsoft.Office.Interop.Excel as Excel
from System.Runtime.InteropServices import Marshal

# import system things needed below
from System.IO import Directory, Path
from System import DateTime

# use the ANSYS function GetProjectDirectory to figure out what directory you are in
# and set that to the current directory
projDir = GetProjectDirectory()
Directory.SetCurrentDirectory(projDir)

# Open up a log file to put useful information in
logFile = open("ima.log", "w")

# Put a header in the log file
logFile.write("================================================\n")
logFile.write("Log File\n")
logFile.write("================================================\n")
logFile.write("Start time: " + DateTime.Now.ToString('yyyy-mm-dd hh:mm:ss') + "\n")
logFile.write("Proj Dir: %s\n\n" % projDir)

# Use the Excel GetActiveObject funtion to get the object for the excel session
ex = Excel.ApplicationClass()

# Make Excel visible
ex.Visible = True

# Define the active workbook and worksheet
wb = ex.Workbooks.Open(projDir + "\ima-excel.xlsm")
ws = wb.ActiveSheet

# In Excel: Grab values for the cells that we want data from (input cells)
length = ws.Range["Length"](1,1).Value2
width = ws.Range["Width"](1,1).Value2
height = ws.Range["Height"](1,1).Value2
press = ws.Range["Pressure"](1,1).Value2
upress =  ws.Range["Pressure"](1,2).Value2

# In Excel: See if the user wants to save the project after the update
#saveit = ws.Range["Save_Project"](1,1).Value2

# In Workbench: Grab the parameter objects for the input values
lenParam = Parameters.GetParameter(Name="P1")
widParam = Parameters.GetParameter(Name="P2")
hgtParam = Parameters.GetParameter(Name="P3")
prsParam = Parameters.GetParameter(Name="P5")

# In Workbench: Get the object for the deflection parameter vlue
defParam = Parameters.GetParameter(Name="P4")

#In Workbench: Set the value of the input parameters in Workbench using the values 
#   we got from Excel
lenParam.Expression = length.ToString()
widParam.Expression = width.ToString()
hgtParam.Expression = height.ToString()
prsParam.Expression = press.ToString() + " [" + upress + "]"

# Set the output values to "Calculating..." since they no longer match the input values
ws.Range["Max_Bending_Distance"](1,1).Value2 = "Calculating..."
ws.Range["Mode_1"](1,1).Value2 = "Calculating..."
ws.Range["Mode_2"](1,1).Value2 = "Calculating..."
ws.Range["Mode_3"](1,1).Value2 = "Calculating..."
ws.Range["Mode_4"](1,1).Value2 = "Calculating..."
ws.Range["Mode_5"](1,1).Value2 = "Calculating..."
ws.Range["Mode_6"](1,1).Value2 = "Calculating..."
ws.Range["Mode_7"](1,1).Value2 = "Calculating..."
ws.Range["Mode_8"](1,1).Value2 = "Calculating..."
ws.Range["Mode_9"](1,1).Value2 = "Calculating..."
ws.Range["Mode_10"](1,1).Value2 = "Calculating..."

# In Workbench: update the systems using the new parameter values
logFile.write("Updating Project\n")
Update()

# In Workbench: save the systems using the new parameter values
logFile.write("Saving Project\n")
Save()

# Assign the value of the Excel deflection cell output deflection from Workbench 
ws.Range["Max_Bending_Distance"](1,1).Value2 = defParam.Value.Value

# Now go through the value of each natural frequency in Workbench and 
#   set the corresponding cell in Excel
#    This could be made more general or at least more concise by using a do loop
#    Also note that instead of getting the objects, then the values the two steps are 
#    combined for these values
ws.Range["Mode_1"](1,1).Value2 = Parameters.GetParameter(Name="P6").Value.Value
ws.Range["Mode_2"](1,1).Value2 = Parameters.GetParameter(Name="P7").Value.Value
ws.Range["Mode_3"](1,1).Value2 = Parameters.GetParameter(Name="P8").Value.Value
ws.Range["Mode_4"](1,1).Value2 = Parameters.GetParameter(Name="P9").Value.Value
ws.Range["Mode_5"](1,1).Value2 = Parameters.GetParameter(Name="P10").Value.Value
ws.Range["Mode_6"](1,1).Value2 = Parameters.GetParameter(Name="P11").Value.Value
ws.Range["Mode_7"](1,1).Value2 = Parameters.GetParameter(Name="P12").Value.Value
ws.Range["Mode_8"](1,1).Value2 = Parameters.GetParameter(Name="P13").Value.Value
ws.Range["Mode_9"](1,1).Value2 = Parameters.GetParameter(Name="P14").Value.Value
ws.Range["Mode_10"](1,1).Value2 = Parameters.GetParameter(Name="P15").Value.Value

# Done!  Close the log file and move on 
logFile.write("End time: " + DateTime.Now.ToString('yyyy-mm-dd hh:mm:ss') + "\n")
logFile.close()