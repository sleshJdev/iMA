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
javaaddpath('.\client\libraries\formatter.jar');
addpath(genpath('./client'), '-end');
addpath(genpath('./client/algorithms'), '-end');

% initialization
global controller
controller = Controller();
Logger.info('Application has started');
function varargout = MainForm_OutputFcn(~, ~, handles)

function runButton_Callback(~, ~, ~)
global controller
Logger.info('Choosing the ansys project file...');
[fileName, filePath] = FileChooser.getFile('*.wbpj', 'Choose ansys project file');
if ~isequal(fileName, 0)
    controller.ansys.run(fullfile(filePath, fileName))
    Logger.info('Ansys started!');
end

function selectedObjectiveTitle = getSelectedObjectiveTitle()
handles = guihandles();
options = cellstr(get(handles.objectiveFunctionPopupmenu, 'String'));
optionIndex = get(handles.objectiveFunctionPopupmenu, 'Value');
selectedObjectiveTitle = options{optionIndex};

function selectedAlgorithmTitle = getSelectedAlgorithm()
handles = guihandles();
options = cellstr(get(handles.algorithmPopupmenu, 'String'));
optionIndex = get(handles.algorithmPopupmenu, 'Value');
selectedAlgorithmTitle = options{optionIndex};

function optimizeButton_Callback(~, ~, ~)
global controller;
controller.optimize(getSelectedAlgorithm(), getSelectedObjectiveTitle());

function terminateButton_Callback(~, ~, ~)
global controller;
controller.terminate();

function connectButton_Callback(~, ~, ~)
global controller;
controller.wbclient.setup();

function fetchParamsInfoPushbutton_Callback(hObject, eventdata, handles)
global controller;
controller.fetchMetadata();

function stopAnsysButton_Callback(~, ~, ~)
global controller;
controller.ansys.stop();

function algorithmPopupmenu_CreateFcn(hObject, ~, ~)
global controller;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
if ~isempty(controller)
    set(hObject, 'String', controller.algorithms.configs.getTitles());
end

function objectiveFunctionPopupmenu_CreateFcn(hObject, eventdata, handles)
global controller;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
if ~isempty(controller)
    set(hObject, 'String', controller.objectivities.configs.getTitles());
end

function optimizationSettingPushbutton_Callback(hObject, eventdata, handles)
global controller;
algoTitle = getSelectedAlgorithm();
settingsJson = controller.algorithms.configs.getSettings(algoTitle);
names = settingsJson.names();
settingNames = cell(1, names.length());
defaults = cell(1, names.length());
types = cell(1, names.length());
for i = 1 : names.length()
    name = names.get(i - 1);
    settingNames{i} = name;
    value = settingsJson.get(name);
    if isnumeric(value)
        defaults{i} = num2str(value);
        types{i} = 'number';
    else
        if isa(value, 'org.json.JSONArray')
            types{i} = 'array';
        elseif isa(value, 'java.lang.String')
            types{i} = 'string';
        end
        defaults{i} = char(value.toString());
    end
end
answer = inputdlg(settingNames, ['Settings of ', algoTitle], [1, 50], defaults);
if ~isempty(answer)
    for i = 1 : names.length()
        name = names.get(i - 1);
        if isequal(types{i}, 'number')
            settingsJson.put(name, str2double(answer{i}));
        elseif isequal(types{i}, 'string')
            settingsJson.put(name, answer{i});
        elseif isequal(types{i}, 'array')
            settingsJson.put(name, org.json.JSONArray(answer{i}));
        end
    end
    controller.algorithms.configs.applySettings(algoTitle, settingsJson);
end

function clearLogPushbutton_Callback(hObject, eventdata, handles)
Logger.clear();

function imaFigure_DeleteFcn(hObject, eventdata, handles)
Logger.close();

function inParamsPushbutton_Callback(hObject, eventdata, handles)
global controller;
inParamsMetaInfoMap = controller.inParamsMetaInfoMap;
if(isempty(inParamsMetaInfoMap))
    Logger.error('The metadata is not loaded!');
    return;
end
paramNames = keys(inParamsMetaInfoMap);
prompts = cell(1, inParamsMetaInfoMap.Count);
defaults = cell(1, inParamsMetaInfoMap.Count);
for i = 1 : inParamsMetaInfoMap.Count
    paramJson = inParamsMetaInfoMap(paramNames{i});
    prompts{i} = [paramNames{i}, '(', char(paramJson.getString('displayText')),')',...
                  ', Unit: ', char(paramJson.getString('unit'))];
    default = org.json.JSONObject();
    default.put('Min', paramJson.getDouble('minValue'));
    default.put('Min', paramJson.getDouble('minValue'));
    default.put('Max', paramJson.getDouble('maxValue'));
    default.put('Step', paramJson.optDouble('stepSize', 1));
    default.put('Weight', paramJson.optDouble('weight', 1));
    defaults{i} = char(default.toString());
end
answer = inputdlg(prompts, 'Weight of input parameters', [1, 100], defaults);
if ~isempty(answer)
    for i = 1 : inParamsMetaInfoMap.Count
        newParamJson = org.json.JSONObject(answer{i});
        paramJson = inParamsMetaInfoMap(paramNames{i});      
        paramJson.put('minValue', newParamJson.getDouble('Min'));
        paramJson.put('maxValue', newParamJson.getDouble('Max'));
        paramJson.put('stepSize', newParamJson.getDouble('Step'));
        paramJson.put('weight', newParamJson.getDouble('Weight'));
    end
end

function outParamsPushbutton_Callback(hObject, eventdata, handles)
global controller;
outParamsMetaInfoMap = controller.outParamsMetaInfoMap;
if(isempty(outParamsMetaInfoMap))
    Logger.error('The metadata is not loaded!');
    return;
end
paramNames = keys(outParamsMetaInfoMap);
prompts = cell(1, outParamsMetaInfoMap.Count);
defaults = cell(1, outParamsMetaInfoMap.Count);
for i = 1 : outParamsMetaInfoMap.Count
    paramJson = outParamsMetaInfoMap(paramNames{i});
    prompts{i} = [paramNames{i}, '(', char(paramJson.getString('displayText')),') min or max: '];    
    defaults{i} = char(paramJson.optString('target', 'min'));
end
answer = inputdlg(prompts, 'Targets for output parameters(min or max)', [1, 60], defaults);
if ~isempty(answer)
    for i = 1 : outParamsMetaInfoMap.Count        
        paramJson = outParamsMetaInfoMap(paramNames{i});        
        paramJson.put('target', char(answer{i}));
    end
end