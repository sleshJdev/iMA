import clr
clr.AddReference('System.Windows.Forms')
from System.Windows.Forms import MessageBox
import System
from System.Collections import *
from System.IO import *
from System import DateTime
from System import TimeSpan

class Watcher:
	def __init__(self, xmlWorker):
		self.xmlWorker = xmlWorker
		self.ansysCommandFile = xmlWorker.getValueOf("//ima/path/ansys-cmd")
		self.matlabCommandFile = xmlWorker.getValueOf("//ima/path/matlab-cmd")
		self.listenPath = DirectoryInfo(self.ansysCommandFile).Parent.FullName	
		self.watcher = FileSystemWatcher(self.listenPath)
		self.watcher.Changed += self.watchListener
		self.watcher.EnableRaisingEvents = True
		# define wait time for avoid 2 update event
		self.WAIT_TIME = TimeSpan.FromSeconds(5).Ticks
		self.start = 0
	
	def watchListener(self, sender, e):
		if (e.FullPath != self.ansysCommandFile):
			return
		if(self.start == 0):
			self.start = DateTime.Now.Ticks
		elif (DateTime.Now.Ticks - self.start < self.WAIT_TIME):
			self.start = 0
			return	
		command = self.readCommand(self.ansysCommandFile)
		print "command: ", command
		if ("close" in command):					
			print "close ansys"			
			return
		elif ("update" in command):     
			print "update model with new parameters"
			self.makeStep()
		elif ("save" in command):
			print "save the systems using the new parameter values"		
			Save()
		self.start = DateTime.Now.Ticks
				
	def makeStep(self):
		print "make step..."
		map = self.xmlWorker.getInputParameters()
		for key in map.Keys:
			Parameters.GetParameter(Name=str(key)).Expression = str(map[key])
			
		print "notify matlab to it wait"
		self.writeCommand(self.matlabCommandFile, "wait")
			
		print "in workbench: update the systems using the new parameter values"
		Update()
		
		print "get output values from workbench"
		map = xmlHelper.getOutputParameters()
		for pair in map.Clone():
			map[pair.Key] = Parameters.GetParameter(Name=str(pair.Key)).Value.Value	
		
		print "save it into xml"
		self.xmlWorker.setOutputParameters(map)
		
		print "notify matlab to it begin optimization"
		self.writeCommand(self.matlabCommandFile, "optimize")
				
	def writeCommand(self, path, command):
		commndFile = open(path, "w");
		commndFile.write(command)
		commndFile.close();
				
	def readCommand(self, pathFile):
		commndFile = open(pathFile, "r")
		command = commndFile.read()
		commndFile.close()
		
		return command;
		
		
		