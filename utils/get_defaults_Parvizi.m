function [def]=get_defaults_Parvizi()

% function to load default values into scripts. Those values are specific
% to the Laboratory of Behavioral and Cognitive Neuroscience (Parvizi Lab,
% Stanford University).
%--------------------------------------------------------------------------
% Written by J. Schrouff, Laboratory of Behavioral and Cognitive
% Neuroscience, Stanford University, 10/21/2014.

def = struct();

% Default sampling rates
%--------------------------------------------------------------------------
def.TDTfsample = 1525.88; % default for >2012 TDT files
def.oldNKfsample  = 1000;    % default for clinical data
def.newNKfsample  = 1000;    % default for clinical data

% Default values for pre-processing
%--------------------------------------------------------------------------
def.new_fs = 500;
def.noise_freq = 60; %default line noise
def.lineband = 3;    % band to cut around line: freq-band:freq+band
def.nharmonics = 3; %Number of harmonics including 0

% Default values for bad channel detection
% -------------------------------------------------------------------------
def.varmult = 5; % overall variance on each channel
% def.stdmult = 100; % detection of 'jumps' on each channel, threshold in muV
def.stdmult = 3; % detection of 'jumps' on each channel
def.kurt_thresh = 3; % detection based on Kurtosis/skewness values

% Default value for event detection on diod
% -------------------------------------------------------------------------
def.ichan = 1; % for exported edf (new NK) data, the diod should be the second channel
def.fsample_diod = 24414.1; % sampling for TDT diod
def.thresh_dur = 0.01; % Minimum duration of an event (in seconds)

% Default values for epoching
% -------------------------------------------------------------------------
def.fieldons = 'start'; %epoch on the stimulus onset
def.fieldbc = 'start'; %baseline correction relative to onset
def.twbc = [-200 0]; %baseline of -200 to 0 ms around onset 
def.twepoch = [0 1000]; %epoch of 1s

% Default values for Hilbert Transform
% -------------------------------------------------------------------------
def.bands = [1 3;4 7; 8 12;13 39;40 70;70 175];
def.listrescale = {'LogR', 'Diff', 'Rel','Zscore', 'Log','LogEps', 'Sqrt'};
def.sc_baseline = [-Inf, 0];
def.sc_file = [];

% Default values for Smoothing
% -------------------------------------------------------------------------
def.smooth_win = 50/1000; % s


% Default values for reading SODATA files
% -------------------------------------------------------------------------
% MMR
def.MMR.skip_before = 12;
def.MMR.skip_after = 0;
def.MMR.thresh_dur = 0.01;
def.MMR.listcond = {'self-internal','other','self-external','autobio','math','rest'};

% VTCLoc
def.VTCLoc.skip_before = 12;
def.VTCLoc.skip_after = 0;
def.VTCLoc.thresh_dur = 0.01;
def.VTCLoc.listcond =  {'animals','faces','falsefonts','logos','numbers','places',...
        'spanish_words','words','persian_numbers'};
    
% Animal
def.Animal.skip_before = 12;
def.Animal.skip_after = 1;
def.Animal.thresh_dur = 0.01;
def.Animal.listcond = {'animal_F','animal_NF','bird_F','bird_NF','fish_F','fish_NF',...
        'human_F','human_NF','object','place','limbs'};
    
% category
def.category.skip_before = 12;  % 12
def.category.skip_after = 0;
def.category.thresh_dur = 0.01;
def.category.listcond =  {'words','pseodowords','tools','numbers','mammal_faces','mammal_bodies','bird_faces','bird_bodies' ...
    ,'human_faces','human_bodies','cars_front','logos','buildings','shapes','cars_sides','chairs','false_fonts','hands','natural_scenes' ...
    ,'scrambled_images'};
