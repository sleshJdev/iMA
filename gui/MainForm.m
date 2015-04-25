function varargout = MainForm(varargin)
    disp('MainForm');            
    
    % settings path
    addpath ..\lib;  
    addpath ..\lib\Rosenbrock    
    
    % MAINFORM MATLAB code for MainForm.fig
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @MainForm_OpeningFcn, ...
        'gui_OutputFcn',  @MainForm_OutputFcn, ...
        'gui_LayoutFcn',  [] , ...
        'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end
    
    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end     
    
    % Clear old data
%     clc;
%     clear;
%     clear all;
    fclose('all');    
    
    % End initialization code - DO NOT EDIT

% --- executes just before MainForm is made visible.
function MainForm_OpeningFcn(hObject, ~, handles, varargin)
    disp('MainForm_OpeningFcn');
    
    % Update handles structure
    guidata(hObject, handles);    
    
     % global value
    global PROPERTIES
    PROPERTIES = Properties;     
    
function varargout = MainForm_OutputFcn(~, ~, handles)
    
%   initialize logger destination
function logListbox_CreateFcn(hObject, eventdata, handles)
    Logger.destination(hObject); % unnecessaty
    % TODO: remove in future

% =============== listeners   =============== %
function workDirectoryPathButton_Callback(hObject, eventdata, handles)
    Logger.info('Main: choose work directory...');
    
    [path] = FileChooser.getDirectory('Choose work directory');
    set(handles.workDirectoryPathEdit, 'String', path);  
    global PROPERTIES;
           PROPERTIES.workDirectoryPath = path;
    
% set path to executable file of ansys workbench
function ansysExePathButton_Callback(hObject, eventdata, handles)
    Logger.info('Main: picked ansys exe file...');
    
    [fileName, filePath] = FileChooser.getFile('*.exe', 'Picked ansys exe file');
    set(handles.ansysExePathEdit, 'String', fullfile(filePath, fileName));  
    
    global PROPERTIES
    PROPERTIES.ansysExeFullPath = fullfile(filePath, fileName);
    
% set path to ansys project file
function ansysProjectPathButton_Callback(hObject, eventdata, handles)
    Logger.info('Main: picked ansys project file...');
    
    [fileName, filePath] = FileChooser.getFile('*.wbpj', 'Picked ansys project file');
    set(handles.ansysProjectPathEdit, 'String', fullfile(filePath, fileName));  
    
    global PROPERTIES;
    PROPERTIES.ansysProjectPath = filePath;
    PROPERTIES.ansysProjectName = fileName;
    
function excelSheetPathButton_Callback(hObject, eventdata, handles)
    Logger.info('Main: choose excel sheet...');
    
    [fileName, filePath] = FileChooser.getFile('*.xlsm', 'Choose excel sheet');
    set(handles.excelSheetPathEdit, 'String', fullfile(filePath, fileName));
    
    global PROPERTIES;
    PROPERTIES.excelSheetPath = filePath;  
    PROPERTIES.excelSheetName = fileName;  
   
function scriptPathButton_Callback(hObject, eventdata, handles)
    Logger.info('Main: choose script...');
    
    [fileName, filePath] = FileChooser.getFile('*.py', 'Choose script');
    set(handles.scriptPathEdit, 'String', fullfile(filePath, fileName));
    
    global PROPERTIES;
    PROPERTIES.scriptPath = filePath;
    PROPERTIES.scriptName = fileName;    
    
function propertiesPathButton_Callback(hObject, eventdata, handles)
    % TODO: implement load propertie file
    
function applyInputParametersButton_Callback(hObject, eventdata, handles)
    Logger.info('Main: apply input pararmeters...');
    
    global PROPERTIES;
    
    handles = guihandles();  
    
    % length
    PROPERTIES.lengthMin = str2double(get(handles.lengthMinEdit, 'String')); 
    PROPERTIES.length = str2double(get(handles.lengthEdit, 'String'));
    PROPERTIES.lengthMax = str2double(get(handles.lengthMaxEdit, 'String')); 

    % width
    PROPERTIES.widthMin = str2double(get(handles.widthMinEdit, 'String')); 
    PROPERTIES.width = str2double(get(handles.widthEdit, 'String'));
    PROPERTIES.widthMax = str2double(get(handles.widthMaxEdit, 'String'));

    % height
    PROPERTIES.heightMin = str2double(get(handles.heightMinEdit, 'String'));
    PROPERTIES.height = str2double(get(handles.heightEdit, 'String'));
    PROPERTIES.heightMax = str2double(get(handles.heightMaxEdit, 'String'));
    
    % pressure
    PROPERTIES.pressure = get(handles.pressureEdit, 'String');     
    
    Logger.info('success!');    
    
function writeOutput()
    Logger.info('Main: write output pararmeters...');
    
    global PROPERTIES;
    
    handles = guihandles();  
    edits = [handles.totalDeformationEdit, handles.massEdit,...
             handles.mode1Edit, handles.mode2Edit, handles.mode3Edit,...
             handles.mode4Edit, handles.mode5Edit, handles.mode6Edit,...
             handles.mode7Edit, handles.mode8Edit, handles.mode9Edit, handles.mode10Edit];
    
    excel = Excel(fullfile(PROPERTIES.excelSheetPath, PROPERTIES.excelSheetName));
    outVector = excel.readParameters();
    [h, ~] = size(outVector);
    for i = 1 : h
        set(edits(i), 'String', outVector(i));
    end   
    
function runButton_Callback(hObject, eventdata, handles)   
    Logger.info('Main: runButton_Callback...');  
    
    global PROPERTIES;        
    global ansysRunner
    
    ansysRunner = AnsysRunner(PROPERTIES.ansysExeFullPath, ...
                              fullfile(PROPERTIES.scriptPath, PROPERTIES.scriptName), ...
                              fullfile(PROPERTIES.ansysProjectPath, PROPERTIES.ansysProjectName));
    ansysRunner.run(); 
    
    Logger.info('success!');
    
function makeStepButton_Callback(hObject, eventdata, handles)
    global PROPERTIES       
    global ansysRunner
    
    inVector = [PROPERTIES.length; PROPERTIES.width; PROPERTIES.height];
    lowBorder = [PROPERTIES.lengthMin; PROPERTIES.widthMin; PROPERTIES.heightMin];
    upBorder = [PROPERTIES.lengthMax; PROPERTIES.widthMax; PROPERTIES.heightMax];    
    result = rosenbrok(inVector, 3, 3, -0.5, upBorder, lowBorder, 0.5, [1; 1; 1], @ansysRunner.update);    
    disp('results--->>>');
    disp(result);
    
    writeOutput();
    

