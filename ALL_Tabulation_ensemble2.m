filePath='C:\Users\Dhruvum Bajpai\Desktop\Computational Project\'; %change this to the file path you want
load([filePath filesep 'ensemble cluster IDs_all.mat'])  
load([filePath filesep 'concatenatedTNFN.mat']) 
load([filePath filesep 'allBehaviorMapInputs_120522.mat']) %loads workspace with smoothed tracking data for ~37k trial 
%%

%ensembleClusterIDs_allNoNAN = ensembleClusterIDs_all;
%ensembleClusterIDs_allNoNAN(isnan(ensembleClusterIDs_all)) = 0;

%ensemble_by_trial = [concatenatedTNFN, ensembleClusterIDs_allNoNAN];
ensemble_by_trial = [concatenatedTNFN, ensembleClusterIDs_all];

[trial_length, trial_list] = groupcounts(ensemble_by_trial(:, 1));
total_trials = length(trial_list);
        
trial_idx = zeros(1, total_trials); %Holds the start index for each trial
trial_idx(1) = 1;
for i = 2:total_trials
            trial_idx(i) = trial_idx(i-1) + trial_length(i-1);
end
regionValues = ensemble_by_trial(:, 4);
frameNumsDR_mat = ensemble_by_trial(:, 4);

a11_trial_regionValues = cell(total_trials, 1);
a11_idx_switch = cell(total_trials, 1);
a11_region_order = cell(total_trials, 1);
a11_region_count = cell(total_trials, 1);
        
for trial = 1:total_trials
            curr_trial_idx = trial_idx(trial);
    if trial == total_trials %Final trial
                trial_regionValues = regionValues(curr_trial_idx:end); %Holds all region values for given trial
                region_frame = frameNumsDR_mat(curr_trial_idx:end)';
    else
                next_trial_idx = trial_idx(trial+1);
                trial_regionValues = regionValues(curr_trial_idx:next_trial_idx-1);
    end
        
    idx_switch = 1;    %This is the index of every region switch
    region_order = trial_regionValues(1);  %This lists the order of regions throughout the experiment, changing with each switch
    curr_val = trial_regionValues(1);  %This is the current region value being repeated
    region_count = [];  %How long each region is repeated
    

    count = 1;
    for region_idx = 2:length(trial_regionValues)   %Iterates through individual regions
        if trial_regionValues(region_idx) ~= curr_val
            idx_switch = [idx_switch, region_idx];
            region_order = [region_order, trial_regionValues(region_idx)];
            region_count = [region_count, count];
            
            curr_val = trial_regionValues(region_idx);
            count = 1;
        else
            count = count+1;
        end
    end
    region_count = [region_count, count];
    
 
    all_trial_regionValues{trial, 1} = trial_regionValues;
    all_idx_switch{trial, 1} = idx_switch;
    all_region_order{trial, 1} = region_order;
    all_region_count{trial, 1} = region_count;

end
ensembleCell = [all_trial_regionValues, all_idx_switch, all_region_order, all_region_count];

%% ensembleTable
ensembleTable = table(all_trial_regionValues, all_idx_switch, all_region_order, all_region_count, 'VariableNames', ...
    ["trial_regionValues", "idx_switch", "region_order", "region_count"]);

regionValue_by_trial_table = ensembleTable;

%% Make Flytable
filePath='C:\Users\Dhruvum Bajpai\Desktop\Computational Project\My Scripts\Python Conversion\ensemble3\';
load([filePath filesep 'midEndFrame.mat'])
midEndFrame = midEndFrame(trial_list);

load([filePath filesep 'labels_simp.mat'])
labels_simp = labels_simp(trial_list);

load([filePath filesep 'labels.mat'])
labels = labels(trials_list);
%%

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
    'VariableNames', ["trial_list", "trial_regions", "trialFull", "frameofStimStart", "frameofTakeoff", "stimLength", "stimTheta_frms", "allLVs", "legPushFrame", "wingUpFrame", "jumpStart", "gender", "takeoffTypes", "manualJumpTest", "manualFot", "stimProtocol", "VideoName", "VideoPath", "midEndFrame", "labels_simp", "labels"]);

%Fields that are 'double': trial_list, frameofStimStart_adj,
%frameofStimStart_adj, frameofTakeoff_adj, stimLength_adj, allLVs_adj,
%legPushFrame_adj, wingUpFrame_adj, jumpStart_adj, gender,
%takeoffTypes_adj, manualJumpTest, manualFot, stimProtocol, VideoName,
%Video_Path, midEndFrame, labels_simp, labels
flycell = [num2cell(trial_list), trial_regions, trialFull,  num2cell(frameofStimStart_adj), num2cell(frameofTakeoff_adj), num2cell(stimLength_adj), stimTheta_frms_adj, num2cell(allLVs_adj), num2cell(legPushFrame_adj), num2cell(wingUpFrame_adj), num2cell(jumpStart_adj), num2cell(gender), num2cell(takeoffTypes_adj), num2cell(manualJumpTest), num2cell(manualFot), num2cell(stimProtocol), num2cell(VideoName), num2cell(Video_Path), num2cell(midEndFrame), num2cell(labels_simp), num2cell(labels)];

%% Text Files

gender = flytable.gender;
writelines(gender, [filePath filesep 'gender.txt'])

stimProtocol = flytable.stimProtocol;
writelines(stimProtocol, [filePath filesep 'stimProtocol.txt'])

videoName = flytable.VideoName;
writelines(videoName, [filePath filesep 'videoName.txt'])

videoPath = flytable.VideoPath;
writelines(videoPath, [filePath filesep 'videoPath.txt'])

%%
save([filePath 'ensembleTable.mat'],"ensembleTable",'-mat');
save([filePath 'ensembleCell.mat'],"flycell",'-mat');
save([filePath 'flytable_ensemble.mat'],"flytable",'-mat');
