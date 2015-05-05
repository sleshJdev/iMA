# IronPython imports to enable Excel interop,
import clr
clr.AddReference("Microsoft.Office.Interop.Excel")
import Microsoft.Office.Interop.Excel as Excel
from System.Runtime.InteropServices import Marshal

# import system things needed below
import System
from System.IO import *
from System import DateTime
from System import TimeSpan

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

# define wait time for avoid 2 update event
WAIT_TIME = TimeSpan.FromSeconds(5).Ticks
start = 0

# Initialize listener	
def watchListener(sender, args):
	global start
	global logFile
	
	if(start == 0):
		start = DateTime.Now.Ticks
	elif (DateTime.Now.Ticks - start < WAIT_TIME):
		start = 0
		return	
		
	reader = StreamReader(args.FullPath)
	command = reader.ReadLine().Trim().ToLower()
	reader.Close()
	print "command: ", command
	if (command == "close"):		 
		logFile.write("close ", args.Name)
		print "cancel watch of directory"
		sender.EnableRaisingEvents = False# sender == watcher		
		print "close the log file and move on" 		
		logFile.write("End time: " + DateTime.Now.ToString('yyyy-mm-dd hh:mm:ss') + "\n")
		logFile.close()
		return
	elif (command == "update"):     
		print "in workbench: update model with new parameters"
		makeStep()
	elif (command == "save"):
		print "in workbench: save the systems using the new parameter values"		
		Save()
		logFile.write("Saving Project\n")
	start = DateTime.Now.Ticks
	
watcher = FileSystemWatcher(projDir + "\listenme")
watcher.Changed += watchListener
watcher.EnableRaisingEvents = True
	
def makeStep():
	print "use the excel"
	excelApp = Excel.ApplicationClass()
	print "define the active workbook and worksheet"
	excelBook = excelApp.Workbooks.Open(projDir + "\iMAexcel.xlsm")
	excelSheet = excelBook.ActiveSheet
	print "make excel visible"	
	excelApp.Visible = True
	
	print "in excel: grab values for the cells that we want data from (input cells)"
	fermaB = excelSheet.Range["Ferma_B"](1,1).Value2
	outerRadius = excelSheet.Range["CircularTube_Ro"](1,1).Value2
	innerRadius = excelSheet.Range["CircularTube_Ri"](1,1).Value2
	fermaH = excelSheet.Range["Ferma_H"](1,1).Value2
	
	print "in workbench: grab the parameter objects for the input values"
	fermaBParam = Parameters.GetParameter(Name="P16")
	outerRadiusParam = Parameters.GetParameter(Name="P18")
	innerRadiusParam = Parameters.GetParameter(Name="P19")
	fermaHParam = Parameters.GetParameter(Name="P20")			
	
	print "in workbench: set the value of the input parameters in workbench using the values we got from excel"
	fermaBParam.Expression = fermaB.ToString()
	outerRadiusParam.Expression = outerRadius.ToString()
	innerRadiusParam.Expression = innerRadius.ToString()
	fermaHParam.Expression = fermaH.ToString()
	
	print "Set the output values to \"Calculating...\" since they no longer match the input values"
	excelSheet.Range["Maximum_Combined_Stress_Maximum"](1,1).Value2 = "Calculating..."
	excelSheet.Range["Geometry_Mass"](1,1).Value2 = "Calculating..."
	excelSheet.Range["Total_Deformation Maximum"](1,1).Value2 = "Calculating..."
	
	print "in workbench: update the systems using the new parameter values"
	Update()
	
	print "in workbench: grab the parameter objects for the output values"
	stressParam = Parameters.GetParameter(Name="P12")
	massParam = Parameters.GetParameter(Name="P13")
	deformationParam = Parameters.GetParameter(Name="P14")
	
	excelSheet.Range["Maximum_Combined_Stress_Maximum"](1,1).Value2 = stressParam.Value.Value	
	excelSheet.Range["Geometry_Mass"](1,1).Value2 = massParam.Value.Value
	excelSheet.Range["Total_Deformation_Maximum"](1,1).Value2 = massParam.Value.Value
		
	print "close excel"
	Marshal.ReleaseComObject(excelSheet)
	excelBook.Close(True)
	Marshal.ReleaseComObject(excelBook)
	excelApp.Quit()
	Marshal.ReleaseComObject(excelApp)
	excelSheet = None
	excelBook = None
	excelApp = None	
	System.GC.Collect()
	
	print "notify matlab to it begin optimization"
	matlabCommand = open(projDir + "\listenme\matlab_command.txt", "w");
	matlabCommand.write('optimize')
	matlabCommand.close();