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

function MainForm_OpeningFcn(hObject, ~, handles, varargin)
    % Update handles structure
    guidata(hObject, handles);    
    
    % settings path
    javaaddpath('.\client\libraries\orgjson.jar')
    addpath .\client;
    addpath .\client\ansys;
    addpath .\client\algorithms;
    addpath .\client\utils;
    
    % initialization
    global controller
    controller = Controller();
    
function varargout = MainForm_OutputFcn(~, ~, handles)          

function runButton_Callback(hObject, eventdata, handles)   
    global controller
    Logger.info('Choosing the ansys project file...');    
    [fileName, filePath] = FileChooser.getFile('*.wbpj', 'Choose ansys project file');
    if ~isequal(fileName, 0)
        controller.runAnsys(fullfile(filePath, fileName))
        Logger.info('Ansys started!');
    end   
    
function optimizeButton_Callback(hObject, eventdata, handles)
    global controller;
    controller.optimize('rosenbrock');
    Logger.info('Optimized done');

%     global PROPERTIES       
%     global ansysRunner    
%     
%     xmlWorker = XmlWorker(fullfile(PROPERTIES.mainXmlPath, PROPERTIES.mainXmlName));    
%     scaleFactor = str2double(xmlWorker.getValueOf('scale-factor'));
%     breakFactor = str2double(xmlWorker.getValueOf('break-factor'));
%     failsQuantity = str2double(xmlWorker.getValueOf('fails-quantity'));
%     threshold = str2double(xmlWorker.getValueOf('threshold'));
%     inVector = xmlWorker.getInputParameters();
%     steps = xmlWorker.getSteps();
%     bounds = xmlWorker.getInputBounds();    
%     lowerBorder = bounds(:, 1);
%     upBorder = bounds(:, 2);   
%     
%     [resultX, resultY] = rosenbrok(inVector, failsQuantity, scaleFactor, breakFactor, upBorder, lowerBorder, threshold, steps, @ansysRunner.update);    
%     disp('results--->>>');
%     disp('X');
%     disp(resultX);
%     disp('Y');
%     disp(resultY);
    
function terminateButton_Callback(hObject, eventdata, handles)
    global controller;    
    controller.stop();
    Logger.info('Stooped');
    
function connectButton_Callback(hObject, eventdata, handles)
    global controller;    
    controller.connect();
    Logger.info('Connected');
