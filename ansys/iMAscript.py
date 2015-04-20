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

# Define wait time for avoid 2 update event
start = 0
WAIT_TIME = TimeSpan.FromSeconds(5).Ticks

print "init start ", start
print "WAIT_TIME ", WAIT_TIME

# Initialize listener	
def watchListener(sender, args):
	global start
	print "begin  watchListener"
	if(start == 0):
		print "init start"
		start = DateTime.Now.Ticks
	elif (DateTime.Now.Ticks - start < WAIT_TIME):
		print "slip"
		start = DateTime.Now.Ticks
		return
	
	print "begin read"
	reader = StreamReader(args.FullPath)
	print "init reader ok"
	command = reader.ReadLine().Trim().ToLower()
	print "command ", command
	if (command == "close"):		 
		sender.write("close ", args.Name)
		# Cancel watch of directory
		watcher.EnableRaisingEvents = False		
		# Close the log file and move on 
		global logFile
		logFile.write("End time: " + DateTime.Now.ToString('yyyy-mm-dd hh:mm:ss') + "\n")
		logFile.close()
	elif (command == "update"):     
		makeStep()
	elif (command == "save"):
		# In Workbench: save the systems using the new parameter values
		logFile.write("Saving Project\n")
		Save()
	reader.Close()
	
watcher = FileSystemWatcher(projDir + "\listenme")
watcher.Changed += watchListener
watcher.EnableRaisingEvents = True
	
def makeStep():
	# Use the Excel GetActiveObject funtion to get the object for the excel session
	excelApp = Excel.ApplicationClass()

	# Make Excel visible
	excelApp.Visible = True
	
	# Define the active workbook and worksheet
	excelBook = excelApp.Workbooks.Open(projDir + "\iMAexcel.xlsm")
	excelSheet = excelBook.ActiveSheet
	
	# In Excel: Grab values for the cells that we want data from (input cells)
	length = excelSheet.Range["Length"](1,1).Value2
	width = excelSheet.Range["Width"](1,1).Value2
	height = excelSheet.Range["Height"](1,1).Value2
	press = excelSheet.Range["Pressure"](1,1).Value2
	upress =  excelSheet.Range["Pressure"](1,2).Value2

	# In Workbench: Grab the parameter objects for the input values
	lenParam = Parameters.GetParameter(Name="P1")
	widParam = Parameters.GetParameter(Name="P2")
	hgtParam = Parameters.GetParameter(Name="P3")
	prsParam = Parameters.GetParameter(Name="P5")
	defParam = Parameters.GetParameter(Name="P4")
	
	#In Workbench: Set the value of the input parameters in Workbench using the values we got from Excel
	lenParam.Expression = length.ToString()
	widParam.Expression = width.ToString()
	hgtParam.Expression = height.ToString()
	prsParam.Expression = press.ToString() + " [" + upress + "]"
	
	# Set the output values to "Calculating..." since they no longer match the input values
	excelSheet.Range["Max_Bending_Distance"](1,1).Value2 = "Calculating..."
	excelSheet.Range["Mode_1"](1,1).Value2 = "Calculating..."
	excelSheet.Range["Mode_2"](1,1).Value2 = "Calculating..."
	excelSheet.Range["Mode_3"](1,1).Value2 = "Calculating..."
	excelSheet.Range["Mode_4"](1,1).Value2 = "Calculating..."
	excelSheet.Range["Mode_5"](1,1).Value2 = "Calculating..."
	excelSheet.Range["Mode_6"](1,1).Value2 = "Calculating..."
	excelSheet.Range["Mode_7"](1,1).Value2 = "Calculating..."
	excelSheet.Range["Mode_8"](1,1).Value2 = "Calculating..."
	excelSheet.Range["Mode_9"](1,1).Value2 = "Calculating..."
	excelSheet.Range["Mode_10"](1,1).Value2 = "Calculating..."
	
	# In Workbench: update the systems using the new parameter values
	logFile.write("Updating Project\n")
	Update()
	
	# Assign the value of the Excel deflection cell output deflection from Workbench 
	excelSheet.Range["Max_Bending_Distance"](1,1).Value2 = defParam.Value.Value
	
	# Now go through the value of each natural frequency in Workbench and 
	#   set the corresponding cell in Excel
	#    This could be made more general or at least more concise by using a do loop
	#    Also note that instead of getting the objects, then the values the two steps are 
	#    combined for these values
	excelSheet.Range["Mode_1"](1,1).Value2 = Parameters.GetParameter(Name="P6").Value.Value
	excelSheet.Range["Mode_2"](1,1).Value2 = Parameters.GetParameter(Name="P7").Value.Value
	excelSheet.Range["Mode_3"](1,1).Value2 = Parameters.GetParameter(Name="P8").Value.Value
	excelSheet.Range["Mode_4"](1,1).Value2 = Parameters.GetParameter(Name="P9").Value.Value
	excelSheet.Range["Mode_5"](1,1).Value2 = Parameters.GetParameter(Name="P10").Value.Value
	excelSheet.Range["Mode_6"](1,1).Value2 = Parameters.GetParameter(Name="P11").Value.Value
	excelSheet.Range["Mode_7"](1,1).Value2 = Parameters.GetParameter(Name="P12").Value.Value
	excelSheet.Range["Mode_8"](1,1).Value2 = Parameters.GetParameter(Name="P13").Value.Value
	excelSheet.Range["Mode_9"](1,1).Value2 = Parameters.GetParameter(Name="P14").Value.Value
	excelSheet.Range["Mode_10"](1,1).Value2 = Parameters.GetParameter(Name="P15").Value.Value
	
	print "close excel"
	
	# Close excel
	Marshal.ReleaseComObject(excelSheet)
	excelBook.Close(False)
	Marshal.ReleaseComObject(excelBook)
	excelApp.Quit()
	Marshal.ReleaseComObject(excelApp)
	
	print "set None"
	
	excelSheet = None
	excelBook = None
	excelApp = None

	print "collect"
	
	System.GC.Collect()