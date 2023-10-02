flycellPath='C:\Users\Dhruvum Bajpai\Desktop\Computational Project\';
%load([flycellPath filesep 'flycell_0.6.mat'])
load([flycellPath filesep 'flytable_ensemble.mat'])
%%
filePath='C:\Users\Dhruvum Bajpai\Desktop\Computational Project\My Scripts\Python Conversion\ensemble\';

gender = flytable.gender;
writelines(gender, [filePath filesep 'gender.txt'])

stimProtocol = flytable.stimProtocol;
writelines(stimProtocol, [filePath filesep 'stimProtocol.txt'])

videoName = flytable.VideoName;
writelines(videoName, [filePath filesep 'videoName.txt'])

videoPath = flytable.VideoPath;
writelines(videoPath, [filePath filesep 'videoPath.txt'])
