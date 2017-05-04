%-----------------------------------------------------------------------
% Job saved on 27-Jul-2015 10:41:42 by cfg_util (rev $Rev: 6134 $)
% spm SPM - SPM12 (6225)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.meeg.preproc.filter.D = '<UNDEFINED>';
matlabbatch{1}.spm.meeg.preproc.filter.type = 'butterworth';
matlabbatch{1}.spm.meeg.preproc.filter.band = 'stop';
matlabbatch{1}.spm.meeg.preproc.filter.freq = [57 63];
matlabbatch{1}.spm.meeg.preproc.filter.dir = 'twopass';
matlabbatch{1}.spm.meeg.preproc.filter.order = 3;
matlabbatch{1}.spm.meeg.preproc.filter.prefix = 'f';
matlabbatch{2}.spm.meeg.preproc.filter.D(1) = cfg_dep('Filter: Filtered Datafile', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','Dfname'));
matlabbatch{2}.spm.meeg.preproc.filter.type = 'butterworth';
matlabbatch{2}.spm.meeg.preproc.filter.band = 'stop';
matlabbatch{2}.spm.meeg.preproc.filter.freq = [117 123];
matlabbatch{2}.spm.meeg.preproc.filter.dir = 'twopass';
matlabbatch{2}.spm.meeg.preproc.filter.order = 3;
matlabbatch{2}.spm.meeg.preproc.filter.prefix = 'f';
matlabbatch{3}.spm.meeg.preproc.filter.D(1) = cfg_dep('Filter: Filtered Datafile', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','Dfname'));
matlabbatch{3}.spm.meeg.preproc.filter.type = 'butterworth';
matlabbatch{3}.spm.meeg.preproc.filter.band = 'stop';
matlabbatch{3}.spm.meeg.preproc.filter.freq = [177 183];
matlabbatch{3}.spm.meeg.preproc.filter.dir = 'twopass';
matlabbatch{3}.spm.meeg.preproc.filter.order = 3;
matlabbatch{3}.spm.meeg.preproc.filter.prefix = 'f';
