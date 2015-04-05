classdef Properties 
    properties(Access = public)         
        lengthMin; 
        length;
        lengthMax;
        
        widthMin; 
        width;
        widthMax;
        
        heightMin;
        height;
        heightMax;
        
        pressure;   
        
        workDirectoryPath;
        
        ansysExeFullPath;
        
        ansysProjectPath;
        ansysProjectName;
        
        excelSheetPath;
        excelSheetName;
        
        scriptPath;
        scriptName;
        
        IN = [
            {'Length'},...
            {'Width'},...
            {'Height'},...
            {'Pressure'}
        ];
    
        OUT = [
            {'Max Bending Distance'},...
            {'Mode 1'},...
            {'Mode 2'},...
            {'Mode 3'},...
            {'Mode 4'},...
            {'Mode 5'},...
            {'Mode 6'},...
            {'Mode 7'},...
            {'Mode 8'},...
            {'Mode 9'},...
            {'Mode 10'}
        ];
    end    
    methods
    end    
end

