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

% clear
clear java;
clear all;

% settings path
javaaddpath('.\client\libraries\orgjson.jar');
addpath(genpath('./client'), '-end');
addpath(genpath('./client/algorithms'), '-end');

% initialization
global controller
controller = Controller();

function varargout = MainForm_OutputFcn(~, ~, handles)

function runButton_Callback(~, ~, ~)
global controller
Logger.info('Choosing the ansys project file...');
[fileName, filePath] = FileChooser.getFile('*.wbpj', 'Choose ansys project file');
if ~isequal(fileName, 0)
    controller.runAnsys(fullfile(filePath, fileName))
    Logger.info('Ansys started!');
end

function optimizeButton_Callback(~, ~, handles)
global controller;
Logger.info('Optimization started');
options = cellstr(get(handles.algorithmPopupmenu,'String'));
optionIndex = get(handles.algorithmPopupmenu,'Value');
selectedAlgorithmTitle = options{optionIndex};
controller.optimize(selectedAlgorithmTitle);
Logger.info('Optimized done');

function terminateButton_Callback(~, ~, ~)
global controller;
Logger.info('Terminating of optimization...');
controller.terminate();
Logger.info('Optimization was terminated');

function connectButton_Callback(~, ~, ~)
global controller;
Logger.info('Connecting to Ansys...');
controller.connect();
Logger.info('Connected');

function stopAnsysButton_Callback(~, ~, ~)
global controller;
Logger.info('Stopping Ansys...');
controller.stopAnsys();
Logger.info('Ansys stoppd');

function algorithmPopupmenu_CreateFcn(hObject, ~, ~)
global controller;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', controller.getAlgorithmTitles());

