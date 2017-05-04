%-----------------------------------------------------------------------
% Job saved on 12-Aug-2016 14:38:08 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6470)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.meeg.preproc.artefact.D = '<UNDEFINED>';
matlabbatch{1}.spm.meeg.preproc.artefact.mode = 'reject';
matlabbatch{1}.spm.meeg.preproc.artefact.badchanthresh = 0.5;
matlabbatch{1}.spm.meeg.preproc.artefact.append = true;
matlabbatch{1}.spm.meeg.preproc.artefact.methods(1).channels{1}.regexp = 'indchantype(D,''EEG'',''good'')';
matlabbatch{1}.spm.meeg.preproc.artefact.methods(1).fun.jump.threshold = 100;
matlabbatch{1}.spm.meeg.preproc.artefact.methods(1).fun.jump.excwin = 1000;
matlabbatch{1}.spm.meeg.preproc.artefact.methods(2).channels{1}.regexp = 'indchantype(D,''EEG'',''good'')';
matlabbatch{1}.spm.meeg.preproc.artefact.methods(2).fun.peak2peak.threshold = 500;
matlabbatch{1}.spm.meeg.preproc.artefact.prefix = 'a';
matlabbatch{2}.spm.meeg.tf.tf.D(1) = cfg_dep('Artefact detection: Artefact-detected Datafile', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','Dfname'));
matlabbatch{2}.spm.meeg.tf.tf.channels{1}.all = 'all';
matlabbatch{2}.spm.meeg.tf.tf.frequencies = [1 2 3 4 5 6 7 8 9 10 11 12 13 16 19 22 25 28 31 34 37 40 45 50 55 60 65 70 80 90 100 110 120 130 140 150 160 170];
matlabbatch{2}.spm.meeg.tf.tf.timewin = [-Inf Inf];
matlabbatch{2}.spm.meeg.tf.tf.method.morlet.ncycles = 5;
matlabbatch{2}.spm.meeg.tf.tf.method.morlet.timeres = 0;
matlabbatch{2}.spm.meeg.tf.tf.method.morlet.subsample = 1;
matlabbatch{2}.spm.meeg.tf.tf.phase = 0;
matlabbatch{2}.spm.meeg.tf.tf.prefix = '';
