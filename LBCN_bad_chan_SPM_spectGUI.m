function varargout = LBCN_bad_chan_SPM_spectGUI(varargin)
% LBCN_BAD_CHAN_SPM_SPECTGUI MATLAB code for LBCN_bad_chan_SPM_spectGUI.fig
%      LBCN_BAD_CHAN_SPM_SPECTGUI, by itself, creates a new LBCN_BAD_CHAN_SPM_SPECTGUI or raises the existing
%      singleton*.
%
%      H = LBCN_BAD_CHAN_SPM_SPECTGUI returns the handle to a new LBCN_BAD_CHAN_SPM_SPECTGUI or the handle to
%      the existing singleton*.
%
%      LBCN_BAD_CHAN_SPM_SPECTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LBCN_BAD_CHAN_SPM_SPECTGUI.M with the given input arguments.
%
%      LBCN_BAD_CHAN_SPM_SPECTGUI('Property','Value',...) creates a new LBCN_BAD_CHAN_SPM_SPECTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LBCN_bad_chan_SPM_spectGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LBCN_bad_chan_SPM_spectGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LBCN_bad_chan_SPM_spectGUI

% Last Modified by GUIDE v2.5 26-Oct-2015 12:05:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LBCN_bad_chan_SPM_spectGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LBCN_bad_chan_SPM_spectGUI_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before LBCN_bad_chan_SPM_spectGUI is made visible.
function LBCN_bad_chan_SPM_spectGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LBCN_bad_chan_SPM_spectGUI (see VARARGIN)

% Choose default command line output for LBCN_bad_chan_SPM_spectGUI
handles.output = hObject;

if ~isempty(varargin{2})
    handles.D = varargin{2}{1};
    handles.data_pxx = varargin{2}{2};
    handles.freqs = varargin{2}{3};
end

handles.good_chan_ids=indchantype(handles.D,'EEG','good');
handles.bad_chan_ids=indchantype(handles.D,'EEG','bad');

plot_channels(handles.axes1,'good',handles)
plot_channels(handles.axes2,'bad',handles)
set(gcf,'name',['Spectrogram for ',fname(handles.D)]);
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes LBCN_bad_chan_SPM_spectGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LBCN_bad_chan_SPM_spectGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = [];



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save(handles.D);
uiresume(handles.figure1)
delete(handles.figure1)
disp('Done')

function plot_channels(axestouse,type,handles)

axes(axestouse)
ClearLinesFromAxes(handles)
if strcmpi(type,'good')
    ichan = handles.good_chan_ids;
else
    ichan = handles.bad_chan_ids;
end

colors = colormap(lines(numel(ichan)));

for i = 1:numel(ichan) 
    name_chan = chanlabels(handles.D,ichan(i));
    if strcmpi(type,'good')
        h(i)=line(handles.freqs,handles.data_pxx(:,ichan(i)),...
            'userdata',name_chan,'buttondownfcn',@updateplotgood);
    else
        h(i)=line(handles.freqs,handles.data_pxx(:,ichan(i)),...
            'userdata',name_chan,'buttondownfcn',@updateplotbad);
    end
    set(h(i),'Color',colors(i,:))
end
handles.h = h;
% Mark the harmonics of 60 Hz
hold on;
v=axis;
ct=1;
lnnz=60;
while lnnz<=max(handles.freqs) && lnnz>=min(handles.freqs)
    plot([1 1]*lnnz,v(3:4),'k--');
    ct=ct+1;
    lnnz=60*ct;
end
if strcmpi(type,'good')
    title('Current Good Channels');
else
    title('Current Bad Channels');
end
% Update handles structure
guidata(handles.figure1, handles);


function updateplotgood(gcbo, EventData, handles)

% Transfer channel from good to bad
name_chan = get(gcbo, 'userdata');
handles = guidata(gcf);
ind_chan = indchannel(handles.D,name_chan);
handles.D = badchannels(handles.D,ind_chan,1);
handles.good_chan_ids=indchantype(handles.D,'EEG','good');
handles.bad_chan_ids=indchantype(handles.D,'EEG','bad');
fprintf('Labelling %s as bad.\n',name_chan{1});
save(handles.D);
% Update handles structure
guidata(handles.figure1, handles);
plot_channels(handles.axes1,'good',handles)
plot_channels(handles.axes2,'bad',handles)



function updateplotbad(gcbo, EventData, handles)

% Transfer channel from good to bad
name_chan = get(gcbo, 'userdata');
handles = guidata(gcf);
ind_chan = indchannel(handles.D,name_chan);
handles.D = badchannels(handles.D,ind_chan,0);
handles.good_chan_ids=indchantype(handles.D,'EEG','good');
handles.bad_chan_ids=indchantype(handles.D,'EEG','bad');
fprintf('Labelling %s as good.\n',name_chan{1});
save(handles.D);
% Update handles structure
guidata(handles.figure1, handles);
plot_channels(handles.axes1,'good',handles)
plot_channels(handles.axes2,'bad',handles)


function ClearLinesFromAxes(handles)
axesHandlesToChildObjects = findobj(gca, 'Type', 'line');
if ~isempty(axesHandlesToChildObjects)
    delete(axesHandlesToChildObjects);
end
guidata(handles.figure1,handles)



    
    
