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
    javaaddpath('C:\Users\User\Documents\MATLAB\iMA\client\libraries\orgjson.jar')
    addpath .\algorithms;
    addpath .\utils;
    
    % initialization
    global controller
%     global configContainer
%     configContainer = ConfigContainer('C:\Users\User\Documents\MATLAB\iMA\client\config\config.json');
    controller = Controller();
    
function varargout = MainForm_OutputFcn(~, ~, handles)
   
function workDirectoryPathButton_Callback(hObject, eventdata, handles)
    Logger.info('Choosing the work directory...');
    [path] = FileChooser.getDirectory('Choose work directory');
    set(handles.workDirectoryPathEdit, 'String', path);
    
% set path to executable file of ansys workbench
function ansysExePathButton_Callback(hObject, eventdata, handles)
%     global configContainer
    Logger.info('Main: picked ansys exe file...');    
    [fileName, filePath] = FileChooser.getFile('*.exe', 'Choose ansys exe file');
%     configContainer.setAnsysExePath(fullfile(filePath, fileName));
    set(handles.ansysExePathEdit, 'String', fullfile(filePath, fileName));
    
% set path to ansys project file
function ansysProjectPathButton_Callback(hObject, eventdata, handles)
%     global configContainer
    Logger.info('Choosing the ansys project file...');    
    [fileName, filePath] = FileChooser.getFile('*.wbpj', 'Choose ansys project file');
%     configContainer.setAnsysProjectPath(fullfile(filePath, fileName));
    set(handles.ansysProjectPathEdit, 'String', fullfile(filePath, fileName));
    
function scriptPathButton_Callback(hObject, eventdata, handles)
%     global configContainer
    Logger.info('Choose the mediator app script...');    
    [fileName, filePath] = FileChooser.getFile('*.py', 'Choose script');
%     configContainer.setMediatorAppPath(fullfile(filePath, fileName));
    set(handles.scriptPathEdit, 'String', fullfile(filePath, fileName));
       
function applyInputParametersButton_Callback(hObject, eventdata, handles)
    Logger.info('Main: apply input pararmeters...');   
    Logger.info('success!');

function writeOutput()
    Logger.info('Main: write output pararmeters...');   
    Logger.info('success!');    

function runButton_Callback(hObject, eventdata, handles)   
    global controller
    controller.setup()
    Logger.info('Runned!');
    
function terminateButton_Callback(hObject, eventdata, handles)
    global controller;    
    controller.stop();
    Logger.info('Stooped');

function optimizeButton_Callback(hObject, eventdata, handles)
    global controller;
    controller.optimize('rosenbrock');
    Logger.info('Optimized');

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
    

    


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
