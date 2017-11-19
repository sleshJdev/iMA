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
        self.document.Load(self.path)
        list = self.document.SelectSingleNode("//ima/parameters/input").ChildNodes
        map = Hashtable()
        for item in list:
            key = item.Attributes["id"].Value
            value = item.InnerText
            map[key] = value	
            
        return map
                
    def setOutputParameters(self, map):		
        list = self.document.SelectSingleNode("//ima/parameters/output").ChildNodes
        if (list.Count != map.Count):
            raise ValueError("\"map\" must have same size as parameters quantity")
        for key in map.Keys:
            for item in list:
                if (item.Attributes["id"].Value == key):
                    item.InnerText = str(map[key])
        self.document.Save(self.path)	
    
    def getOutputParameters(self):
        self.document.Load(self.path)
        list = self.document.SelectSingleNode("//ima/parameters/output").ChildNodes
        map = Hashtable()
        for item in list:
            key = item.Attributes["id"].Value
            value = item.InnerText
            map[key] = value	
                
        return map
            
    def getValueOf(self, xpath):
        return self.document.SelectSingleNode(xpath).InnerText
    
    def __str__(self):
        print self.path