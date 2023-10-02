filePath='C:\Users\Dhruvum Bajpai\Desktop\Computational Project\'; %change this to the file path you want
load([filePath filesep 'allBehaviorMapInputs_120522.mat']) %loads workspace with smoothed tracking data for ~37k trial

%%
load([filePath 'frameNumsDR_mat.mat'])
load([filePath 'trialNumsDR_mat.mat'])
load([filePath 'regionValue_by_trial_0.6_table.mat'])  %Choose desired regionValue table                

    %% Make FlyCell
filePath='C:\Users\Dhruvum Bajpai\Desktop\Computational Project\My Scripts\Python Conversion\';
[trial_length, trial_list] = groupcounts(trialNumsDR_mat);

load([filePath filesep 'midEndFrame.mat'])
midEndFrame = midEndFrame(trial_list);

load([filePath filesep 'labels_simp.mat'])
labels_simp = labels_simp(trial_list);

load([filePath filesep 'labels.mat'])
labels = labels(trial_list);

trial_regions = regionValue_by_trial_table.region_order;
trialFull = regionValue_by_trial_table.trial_regionValues;

frameofStimStart_adj = frameofStimStart(trial_list);
frameofTakeoff_adj = frameofTakeoff(trial_list);
stimLength_adj = stimLength(trial_list);
stimTheta_frms_adj = transpose(stimTheta_frms(trial_list));
allLVs_adj = allLVs(trial_list);
legPushFrame_adj = legPushFrame(trial_list);
wingUpFrame_adj = wingUpFrame(trial_list);
jumpStart_adj = jumpStart(trial_list);
takeoffTypes_adj = transpose(takeoffTypes(trial_list));

manualJumpTest = fullset.manualJumpTest(trial_list);
manualFot = fullset.manualFot(trial_list);

VideoName_cell = fullset.('VideoName');
VideoName = string(VideoName_cell(trial_list));
Video_Path_cell = fullset.('Video_Path');
Video_Path = string(Video_Path_cell(trial_list));
gender_cell = fullset.('Gender');
gender = string(gender_cell(trial_list));
stimProtocol = string(stimCharacteristics(trial_list));

flytable = table(trial_list, trial_regions, trialFull,  frameofStimStart_adj, frameofTakeoff_adj, stimLength_adj, stimTheta_frms_adj, allLVs_adj, legPushFrame_adj, wingUpFrame_adj, jumpStart_adj, gender, takeoffTypes_adj, manualJumpTest, manualFot, stimProtocol, VideoName, Video_Path, midEndFrame, labels_simp, labels, ...
    'VariableNames', ["trial_list", "trial_regions", "trialFull", "frameofStimStart", "frameofTakeoff", "stimLength", "stimTheta_frms", "allLVs", "legPushFrame", ...
    "wingUpFrame", "jumpStart", "gender", "takeoffTypes", "manualJumpTest", "manualFot", "stimProtocol", "VideoName", "VideoPath", "midEndFrame", "labels_simp", ...
    "labels"]);

%Fields that are 'double': trial_list, frameofStimStart_adj,
%frameofStimStart_adj, frameofTakeoff_adj, stimLength_adj, allLVs_adj,
%legPushFrame_adj, wingUpFrame_adj, jumpStart_adj, gender,
%takeoffTypes_adj, manualJumpTest, manualFot, stimProtocol, VideoName,
%Video_Path, midEndFrame, labels_simp, labels
flycell = [num2cell(trial_list), trial_regions, trialFull,  num2cell(frameofStimStart_adj), num2cell(frameofTakeoff_adj), num2cell(stimLength_adj), ... 
    stimTheta_frms_adj, num2cell(allLVs_adj), num2cell(legPushFrame_adj), num2cell(wingUpFrame_adj), num2cell(jumpStart_adj), num2cell(gender), ...
    num2cell(takeoffTypes_adj), num2cell(manualJumpTest), num2cell(manualFot), num2cell(stimProtocol), num2cell(VideoName), num2cell(Video_Path), ...
    num2cell(midEndFrame), num2cell(labels_simp), num2cell(labels)];

%% Text Files
filePath='C:\Users\Dhruvum Bajpai\Desktop\Computational Project\My Scripts\Python Conversion\';

gender = flytable.gender;
writelines(gender, [filePath filesep 'gender.txt'])

stimProtocol = flytable.stimProtocol;
writelines(stimProtocol, [filePath filesep 'stimProtocol.txt'])

videoName = flytable.VideoName;
writelines(videoName, [filePath filesep 'videoName.txt'])

videoPath = flytable.VideoPath;
writelines(videoPath, [filePath filesep 'videoPath.txt'])

%% Save FlyCell
save([filePath 'flycell.mat'],"flycell",'-mat');
