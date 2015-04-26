import clr
clr.AddReference('System.Xml')
clr.AddReference('System.Windows.Forms')

from System.Windows.Forms import MessageBox
from System.Xml import *
from System.Collections import *

class XmlWorker:
	def __init__(self, pathToXmlDocument):
		self.path = pathToXmlDocument
		self.document = XmlDocument()	
		self.document.Load(self.path)		
				
	def getInputParameters(self):
		#MessageBox.Show("getInputParameters")
		self.document.Load(self.path)
		list = self.document.SelectSingleNode("//ima/parameters/input").ChildNodes
		map = Hashtable()
		for item in list:
			key = item.Attributes["id"].Value
			value = item.InnerText
			map[key] = value	
		
		#MessageBox.Show("getInputParameters return")
		return map
				
	def setOutputParameters(self, map):		
		#MessageBox.Show("setOutputParameters")
		list = self.document.SelectSingleNode("//ima/parameters/output").ChildNodes
		if (list.Count != map.Count):
			raise ValueError("\"map\" must have same size as parameters quantity")
		for key in map.Keys:
			for item in list:
				if (item.Attributes["id"].Value == key):
					item.InnerText = str(map[key])
		self.document.Save(self.path)	
		#MessageBox.Show("setOutputParameters end")
	
	def getOutputParameters(self):
		#MessageBox.Show("getOutputParameters")
		self.document.Load(self.path)
		list = self.document.SelectSingleNode("//ima/parameters/output").ChildNodes
		map = Hashtable()
		for item in list:
			key = item.Attributes["id"].Value
			value = item.InnerText
			map[key] = value	
		#MessageBox.Show("getOutputParameters return")
		return map
			
	def getValueOf(self, xpath):
		#MessageBox.Show("getValueOf return")
		return self.document.SelectSingleNode(xpath).InnerText
	
	def __str__(self):
		print self.path
		
		
import clr
import System
clr.AddReference('System.Windows.Forms')
from System.Windows.Forms import MessageBox
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
		print self.ansysCommandFile
		print self.matlabCommandFile
		print self.listenPath
		self.watcher = FileSystemWatcher(self.listenPath)
		self.watcher.Changed += self.watchListener
		self.watcher.EnableRaisingEvents = True
		# define wait time for avoid 2 update event
		self.previousCommand = "" 
	
	def watchListener(self, sender, e):
		#MessageBox.Show("watchListener begin")
		if (e.FullPath != self.ansysCommandFile):
			return		 
			
		#MessageBox.Show("watchListener read command")
		command = self.readCommand(self.ansysCommandFile)
		
		if (self.previousCommand == command):
			return
		self.previousCommand = command
		
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
				
	def makeStep(self):
		#MessageBox.Show("make step...")
		print "make step..."
		map = self.xmlWorker.getInputParameters()
		for key in map.Keys:
			Parameters.GetParameter(Name=str(key)).Expression = str(map[key])
			
		#MessageBox.Show("notify matlab to it wait")
		print "notify matlab to it wait"
		self.writeCommand(self.matlabCommandFile, "wait")
		
		#MessageBox.Show("in workbench: update the systems using the new parameter values")
		print "in workbench: update the systems using the new parameter values"
		Update()
		
		#MessageBox.Show("get output values from workbench")
		print "get output values from workbench"
		map = self.xmlWorker.getOutputParameters()
		for pair in map.Clone():# to avoid: InvalidOperationException: Collection was modified; enumeration operation may not execute.
			map[pair.Key] = Parameters.GetParameter(Name=str(pair.Key)).Value.Value	
		
		#MessageBox.Show("save it into xml")
		print "save it into xml"
		self.xmlWorker.setOutputParameters(map)
		
		#MessageBox.Show("notify matlab to it begin optimization")
		print "notify matlab to it begin optimization"
		self.writeCommand(self.matlabCommandFile, "optimize")
				
	def writeCommand(self, path, command):
		commndFile = open(path, "w")
		commndFile.write(command)
		commndFile.close()
				
	def readCommand(self, pathFile):
		commndFile = open(pathFile, "r")
		command = commndFile.read()
		commndFile.close()
		
		return command

# use the ANSYS function GetProjectDirectory to figure out what directory you are in and set that to the current directory
projDir = GetProjectDirectory()
Directory.SetCurrentDirectory(projDir)

imaPath = DirectoryInfo(projDir).Parent.FullName
xmlWorker = XmlWorker(imaPath + "/main.xml")		

watcher = Watcher(xmlWorker)


