function varargout = MainForm(varargin)     
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
    
    % End initialization code - DO NOT EDIT

% --- executes just before MainForm is made visible.
function MainForm_OpeningFcn(hObject, ~, handles, varargin)
    disp('MainForm_OpeningFcn');
    
    % Update handles structure
    guidata(hObject, handles);    
    
    % settings path
    addpath ..\lib;  
    addpath ..\lib\Rosenbrock
    
    % close unclosed files
    fclose('all'); 
    
     % global value
    global PROPERTIES
    PROPERTIES = Properties;     
    
function varargout = MainForm_OutputFcn(~, ~, handles)
   
% =============== listeners   =============== %
function workDirectoryPathButton_Callback(hObject, eventdata, handles)
    Logger.info('Main: choose work directory...');
    
    [path] = FileChooser.getDirectory('Choose work directory');
    set(handles.workDirectoryPathEdit, 'String', path);  
    global PROPERTIES;
    PROPERTIES.workDirectoryPath = path;
    PROPERTIES.mainXmlPath = path;
    PROPERTIES.mainXmlName = 'main.xml';
    
    PROPERTIES.ansysExeFullPath = get(handles.ansysExePathEdit, 'String');
    
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
    
function scriptPathButton_Callback(hObject, eventdata, handles)
    Logger.info('Main: choose script...');
    
    [fileName, filePath] = FileChooser.getFile('*.py', 'Choose script');
    set(handles.scriptPathEdit, 'String', fullfile(filePath, fileName));
    
    global PROPERTIES;
    PROPERTIES.scriptPath = filePath;
    PROPERTIES.scriptName = fileName;    
       
function applyInputParametersButton_Callback(hObject, eventdata, handles)
    Logger.info('Main: apply input pararmeters...');
    
    global PROPERTIES;       
    
    Logger.info('success!');    
    
function writeOutput()
    Logger.info('Main: write output pararmeters...');
    
    global PROPERTIES;
    
    handles = guihandles();  
    edits = [handles.totalDeformationEdit, handles.massEdit,...
             handles.mode1Edit, handles.mode2Edit, handles.mode3Edit,...
             handles.mode4Edit, handles.mode5Edit, handles.mode6Edit,...
             handles.mode7Edit, handles.mode8Edit, handles.mode9Edit, handles.mode10Edit];
    
    xmlWorker = XmlWorker(fullfile(PROPERTIES.mainXmlPath, PROPERTIES.mainXmlName));
    outVector = xmlWorker.getOutputParameters();
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
    
    xmlWorker = XmlWorker(fullfile(PROPERTIES.mainXmlPath, PROPERTIES.mainXmlName));
    bounds = xmlWorker.getInputBounds();
    inVector = xmlWorker.getInputParameters();
    lowerBorder = bounds(:, 1);
    upBorder = bounds(:, 2);   
    
    [resultX, resultY] = rosenbrok(inVector, 3, 2, -0.5, upBorder, lowerBorder, 0.5, [0.01; 0.01; 1; 1], @ansysRunner.update);    
    disp('results--->>>');
    disp('X');
    disp(resultX);
    disp('Y');
    disp(resultY);
%     writeOutput();
    

