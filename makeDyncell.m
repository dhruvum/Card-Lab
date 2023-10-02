 %% Tabulate ALL Data
filePath='C:\Users\Dhruvum Bajpai\Desktop\Computational Project\'; %change this to the file path you want
load([filePath filesep 'allBehaviorMapInputs_120522.mat']) %loads workspace with smoothed tracking data for ~37k trial
load([filePath 'frameNumsDR_mat.mat'])
load([filePath 'trialNumsDR_mat.mat'])
%%
[trial_length, trial_list] = groupcounts(trialNumsDR_mat);
total_trials = length(trial_list);

%%
filePath = 'C:\Users\Dhruvum Bajpai\Desktop\Computational Project\My Scripts\Python Conversion\';
load([filePath 'labels_simp.mat'])
label_simp = labels_simp(trial_list);

load([filePath 'labels.mat'])
label = labels(trial_list);

flipbool = fullset.flipBool;
flipbool = flipbool(trial_list);

head_x = APTdataCell(:, 1);
head_x = head_x(trial_list);
head_y = APTdataCell(:, 2);
head_y = head_y(trial_list);
headDist = distanceTraveled(:, 1);
headDist = headDist(trial_list);

abdomen_x = APTdataCell(:, 3);
abdomen_x = abdomen_x(trial_list);
abdomen_y = APTdataCell(:, 4);
abdomen_y = abdomen_y(trial_list);
abdomenDist = distanceTraveled(:, 2);
abdomenDist = abdomenDist(trial_list);

t1left_x = APTdataCell(:, 5);
t1left_x = t1left_x(trial_list);
t1left_y = APTdataCell(:, 6);
t1left_y = t1left_y(trial_list);
t1leftDist = distanceTraveled(:, 3);
t1leftDist = t1leftDist(trial_list);

t2left_x = APTdataCell(:, 7);
t2left_x = t2left_x(trial_list);
t2left_y = APTdataCell(:, 8);
t2left_y = t2left_y(trial_list);
t2leftDist = distanceTraveled(:, 4);
t2leftDist = t2leftDist(trial_list);

t3left_x = APTdataCell(:, 9);
t3left_x = t3left_x(trial_list);
t3left_y = APTdataCell(:, 10);
t3left_y = t3left_y(trial_list);
t3leftDist = distanceTraveled(:, 5);
t3leftDist = t3leftDist(trial_list);

t3right_x = APTdataCell(:, 11);
t3right_x = t3right_x(trial_list);
t3right_y = APTdataCell(:, 12);
t3right_y = t3right_y(trial_list);
t3rightDist = distanceTraveled(:, 6);
t3rightDist = t3rightDist(trial_list);

t2right_x = APTdataCell(:, 13);
t2right_x = t2right_x(trial_list);
t2right_y = APTdataCell(:, 14);
t2right_y = t2right_y(trial_list);
t2rightDist = distanceTraveled(:, 7);
t2rightDist = t2rightDist(trial_list);

t1right_x = APTdataCell(:, 15);
t1right_x = t1right_x(trial_list);
t1right_y = APTdataCell(:, 16);
t1right_y = t1right_y(trial_list);
t1rightDist = distanceTraveled(:, 8);
t1rightDist = t1rightDist(trial_list);

bp1_x = APTdataCell(:, 17);
bp1_x = bp1_x(trial_list);
bp1_y = APTdataCell(:, 18);
bp1_y = bp1_y(trial_list);
bp1Dist = distanceTraveled(:, 9);
bp1Dist = bp1Dist(trial_list);

bp2_x = APTdataCell(:, 19);
bp2_x = bp2_x(trial_list);
bp2_y = APTdataCell(:, 20);
bp2_y = bp2_y(trial_list);
bp2Dist = distanceTraveled(:, 10);
bp2Dist = bp2Dist(trial_list);

neck_x = APTdataCell(:, 21);
neck_x = neck_x(trial_list);
neck_y = APTdataCell(:, 22);
neck_y = neck_y(trial_list);
neckDist = distanceTraveled(:, 11);
neckDist = neckDist(trial_list);

centre_x = APTdataCell(:, 23);
centre_x = centre_x(trial_list);
centre_y = APTdataCell(:, 24);
centre_y = centre_y(trial_list);
centreDist = distanceTraveled(:, 12);
centreDist = centreDist(trial_list);

%%
startsize = transpose(startSize(trial_list));
endsize = transpose(endSize(trial_list));

dyntable = table(allLVs(trial_list), ele(trial_list), azi(trial_list), flipbool, bodyAxis(trial_list), bodyAxisAngularVelocity(trial_list), head_x, head_y, headDist, abdomen_x, abdomen_y, abdomenDist, t1left_x, t1left_y, t1leftDist, t2left_x, t2left_y, t2leftDist, t3left_x, t3left_y, t3leftDist, t3right_x, t3right_y, t3rightDist, t2right_x, t2right_y, t2rightDist, t1right_x, t1right_y, t1rightDist, bp1_x, bp1_y, bp1Dist, bp2_x, bp2_y, bp2Dist, neck_x, neck_y, neckDist, centre_x, centre_y, centreDist, startsize, endsize, label, label_simp);

%Fields that are 'double': allLVs, ele, azi, flipbool
dyncell = [num2cell(allLVs(trial_list)), num2cell(ele(trial_list)), num2cell(azi(trial_list)), num2cell(flipbool), bodyAxis(trial_list), bodyAxisAngularVelocity(trial_list), head_x, head_y, headDist, abdomen_x, abdomen_y, abdomenDist, t1left_x, t1left_y, t1leftDist, t2left_x, t2left_y, t2leftDist, t3left_x, t3left_y, t3leftDist, t3right_x, t3right_y, t3rightDist, t2right_x, t2right_y, t2rightDist, t1right_x, t1right_y, t1rightDist, bp1_x, bp1_y, bp1Dist, bp2_x, bp2_y, bp2Dist, neck_x, neck_y, neckDist, centre_x, centre_y, centreDist, num2cell(startsize), num2cell(endsize), num2cell(label), num2cell(label_simp)];        
%%
savePath = 'C:\Users\Dhruvum Bajpai\Desktop\Computational Project\My Scripts\Python Conversion\';
save([savePath filesep 'dyncell.mat'],"dyncell",'-v7.3');
%save([currentDir filesep 'dyntable.mat'],"dyntable",'-v7.3');