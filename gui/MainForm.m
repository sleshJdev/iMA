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
     
    
function runButton_Callback(hObject, eventdata, handles)   
    Logger.info('Main: runButton_Callback...');  
    
    global PROPERTIES;        
    global ansysRunner;
    
    ansysRunner = AnsysRunner(PROPERTIES.ansysExeFullPath, ...
                              fullfile(PROPERTIES.scriptPath, PROPERTIES.scriptName), ...
                              fullfile(PROPERTIES.ansysProjectPath, PROPERTIES.ansysProjectName));
    ansysRunner.run(); 
    
    Logger.info('success!');
    
function terminateButton_Callback(hObject, eventdata, handles)
    global PROPERTIES;
    
    PROPERTIES.isTerminate = true;
    Logger.info('Stopping... Please, wait while Ansys dont finish calculation.');
    
function makeStepButton_Callback(hObject, eventdata, handles)
    global PROPERTIES       
    global ansysRunner    
    
    xmlWorker = XmlWorker(fullfile(PROPERTIES.mainXmlPath, PROPERTIES.mainXmlName));    
    scaleFactor = str2double(xmlWorker.getValueOf('scale-factor'));
    breakFactor = str2double(xmlWorker.getValueOf('break-factor'));
    failsQuantity = str2double(xmlWorker.getValueOf('fails-quantity'));
    threshold = str2double(xmlWorker.getValueOf('threshold'));
    inVector = xmlWorker.getInputParameters();
    steps = xmlWorker.getSteps();
    bounds = xmlWorker.getInputBounds();    
    lowerBorder = bounds(:, 1);
    upBorder = bounds(:, 2);   
    
    [resultX, resultY] = rosenbrok(inVector, failsQuantity, scaleFactor, breakFactor, upBorder, lowerBorder, threshold, steps, @ansysRunner.update);    
    disp('results--->>>');
    disp('X');
    disp(resultX);
    disp('Y');
    disp(resultY);
    

    
