 %% Tabulate ALL Data
filePath='C:\Users\Dhruvum Bajpai\Desktop\Computational Project\'; %change this to the file path you want
load([filePath filesep 'allBehaviorMapInputs_120522.mat']) %loads workspace with smoothed tracking data for ~37k trial
%%
currentDir = 'C:\Users\Dhruvum Bajpai\Desktop\Computational Project\';

load([currentDir 'zValues.mat'])
load([currentDir 'frameNumsDR_mat.mat'])
load([currentDir 'trialNumsDR_mat.mat'])
%%
% measure velocity of points through the map
medianLength = 3; %if maps are median filtered, this is the # of frames used
minRest = 6; %only take segments of six consecutive points below velocity threshold
dt = .01; %time interval. Actually kind of arbitrary, but change along with the vel. threshold.
velocityThreshold=380;  %380 units/frame was mean value of multiple runs w/ this dt, picked to make it constant across
%multiple maps.  Could also use a GMM fit to histogram of log10 of
%velocities to pick cutoff (it would be a bimodel distribution)

smooth_z = zValues;
if medianLength > 0
    smooth_z(:,1) = medfilt1(zValues(:,1),medianLength,'omitnan');
    smooth_z(:,2) = medfilt1(zValues(:,2),medianLength,'omitnan');
end
smooth_z(isnan(zValues(:,1)),1)=NaN;
smooth_z(isnan(zValues(:,2)),2)=NaN;

vx = [0;diff(smooth_z(:,1))]./dt; %could also use gradient function to get velo?
vy = [0;diff(smooth_z(:,2))]./dt;
v = sqrt(vx.^2+vy.^2);

noTrialSwitch=[0;diff(trialNumsDR_mat)]==0; %label instances where map coordinates switch from one trial to the next

% find dwells
%divide into "dwells," or epochs where velocity is below a threshold value
%for a number of consecutive frames specified by the variable "minRest"
CC = largeBWConnComp(v < velocityThreshold & noTrialSwitch,minRest);
%this is a custom version of a function normally used for image
%processing which finds connected pixels in a binary image.  Here, our
%"image" is a 1D vector of our velocity through the map (function
%written by Gordon Berman)

starts=cellfun(@(x) x(1), CC.PixelIdxList); %first frame of each dwell
stops=cellfun(@(x) x(length(x)), CC.PixelIdxList); %last frame of each dwell
%cellfun - applies a function to every element in a cell array
%@x means a custom function using the variable x

dwellMedoids=cellfun(@(x) x(calcMedoids(zValues(x,:))),CC.PixelIdxList); %find the medoid point (middle on the map) for each dwell

% perform watershed transform
maxVal=max(max(abs(zValues)));
rangeVals=[-maxVal maxVal];
sigList=[0.4,0.6,1.2]; %increasing sigma values mean that the map will be convolved
%with a bigger gaussian, meaning it will be divided into fewer regions

regionValues_multipleSigmas=NaN(length(sigList),length(zValues)); %we're convolving one map with multiple gaussians
%of several different sizes

for s=1:length(sigList)
    sigma=sigList(s);
    [xx,density] = findPointDensity(zValues(dwellMedoids,:),sigma,1001,rangeVals);
    %this is the function (taken from Gordon Berman's MotionMapper code) which
    %convolves the behavior map with a gaussian to estimate density

    LL = watershed(-density,8); %performing watershed transform on the density map
    LL(density < 1e-6) = 0; %removing areas with very low density

    %name watershed regions
    a = setdiff(unique(LL),0);
    for i=1:length(a)
        LL(LL==a(i)) = i;
    end

    load('saved_colormaps.mat','cc','cc2')
%plot density map and in adjacent subplot show region numbers
    figure('units','normalized','outerposition',[0 0 1 1])
    subplot(1,2,1)
    imagesc(xx,xx,density)
    caxis([0 max(density(:)) * .8])
    axis equal tight off xy
    hold on
    set(gca,'fontsize',16,'fontweight','bold')

    subplot(1,2,2)
    imagesc(xx,xx,LL)
    axis equal tight off xy
    hold on
    colormap(cc)

    numRegions = max(LL(:));

    %loop through plot to add region names
    Bs = cell(numRegions,1);
    for i=1:numRegions
        if numel(find(LL==i))>0
            B = bwboundaries(LL==i);
            subplot(1,2,1)
            plot(xx(B{1}(:,2)),xx(B{1}(:,1)),'k-','linewidth',2)

            subplot(1,2,2)
            plot(xx(B{1}(:,2)),xx(B{1}(:,1)),'k-','linewidth',2)

            Bs{i} = B{1};

            [ii,jj] = find(LL==i);
            medianX = xx(round(median(jj)));
            medianY = xx(round(median(ii)));
            text(medianX,medianY,num2str(i),'backgroundcolor','k','color','w','fontweight','bold','fontsize',12)
        end
    end


    vals = round((smooth_z(dwellMedoids,:) + max(xx))*length(xx)/(2*max(xx)));
    vals(vals<1) = 1;
    vals(vals>length(xx)) = length(xx);

    %assign values to particular region on map based on their location
    %in density map image
    watershedValues = zeros(CC.NumObjects,1);
    for i=1:CC.NumObjects
        watershedValues(i) = diag(LL(vals(i,2),vals(i,1)));
    end

  %if any points are missing a region assignment, give them the
  %assignment of neighboring points
    findOs=find(watershedValues==0);
    findAssigned=find(watershedValues~=0);
    %~= means not equal to, watershedValues give numerical assignments
    %for map regions
    nn=knnsearch(zValues(dwellMedoids,:),zValues(dwellMedoids(findOs),:),'k',15,'distance','euclidean');

    for o=1:length(findOs)
        watershedValues(findOs(o))=mode(watershedValues(intersect(findAssigned,nn(o,:))));
    end

    regionValues=zeros(1,length(zValues));
    %Values (numbers) automatically produced by the Watershed Transform

    for i=1:length(watershedValues) 
        regionValues(CC.PixelIdxList{i})=watershedValues(i);
    end

    regionValues_multipleSigmas(s,:)=regionValues;

    %% Split Trials in trialNumsDR_mat - CELL
    [trial_length, trial_list] = groupcounts(trialNumsDR_mat);
    total_trials = length(trial_list);
            
    trial_idx = zeros(1, total_trials); %Holds the start index for each trial
    trial_idx(1) = 1;
    for i = 2:total_trials
                trial_idx(i) = trial_idx(i-1) + trial_length(i-1);
    end
    
    a11_trial_regionValues = cell(total_trials, 1);
    a11_idx_switch = cell(total_trials, 1);
    a11_region_order = cell(total_trials, 1);
    a11_region_count = cell(total_trials, 1);
    a11_region_frame = cell(total_trials, 1);
            
    for trial = 1:total_trials
                curr_trial_idx = trial_idx(trial);
        if trial == total_trials %Final trial
                    trial_regionValues = regionValues(curr_trial_idx:end); %Holds all region values for given trial
                    region_frame = frameNumsDR_mat(curr_trial_idx:end)';
        else
                    next_trial_idx = trial_idx(trial+1);
                    trial_regionValues = regionValues(curr_trial_idx:next_trial_idx-1);
                    region_frame = frameNumsDR_mat(curr_trial_idx:next_trial_idx-1)';
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
        
        %{
        if isempty(idx_switch)
            idx_switch = {nan}; %This means that the entire trial never changed regions
            %idx_switch = 1;
        end
        %}
    
        all_trial_regionValues{trial, 1} = trial_regionValues;
        all_idx_switch{trial, 1} = idx_switch;
        all_region_order{trial, 1} = region_order;
        all_region_count{trial, 1} = region_count;
        all_region_frame{trial, 1} = region_frame;

    end

    regionValue_by_trial = [all_trial_regionValues, all_idx_switch, all_region_order, all_region_count, all_region_frame];
    %% regionValue_by_trial - Table
    regionValue_by_trial_table = table(all_trial_regionValues, all_idx_switch, all_region_order, all_region_count, all_region_frame, 'VariableNames', ...
        ["trial_regionValues", "idx_switch", "region_order", "region_count", "region_frame"]);

    %% Make Dyntable
    if s==1
        flipbool = fullset.flipBool;
    
        head_x = APTdataCell(:, 1);
        head_y = APTdataCell(:, 2);
        headDist = distanceTraveled(:, 1);
        
        abdomen_x = APTdataCell(:, 3);
        abdomen_y = APTdataCell(:, 4);
        abdomenDist = distanceTraveled(:, 2);
        
        t1left_x = APTdataCell(:, 5);
        t1left_y = APTdataCell(:, 6);
        t1leftDist = distanceTraveled(:, 3);
        
        t2left_x = APTdataCell(:, 7);
        t2left_y = APTdataCell(:, 8);
        t2leftDist = distanceTraveled(:, 4);
        
        t3left_x = APTdataCell(:, 9);
        t3left_y = APTdataCell(:, 10);
        t3leftDist = distanceTraveled(:, 5);
        
        t3right_x = APTdataCell(:, 11);
        t3right_y = APTdataCell(:, 12);
        t3rightDist = distanceTraveled(:, 6);
        
        t2right_x = APTdataCell(:, 13);
        t2right_y = APTdataCell(:, 14);
        t2rightDist = distanceTraveled(:, 7);
        
        t1right_x = APTdataCell(:, 15);
        t1right_y = APTdataCell(:, 16);
        t1rightDist = distanceTraveled(:, 8);
        
        bp1_x = APTdataCell(:, 17);
        bp1_y = APTdataCell(:, 18);
        bp1Dist = distanceTraveled(:, 9);
        
        bp2_x = APTdataCell(:, 19);
        bp2_y = APTdataCell(:, 20);
        bp2Dist = distanceTraveled(:, 10);
        
        neck_x = APTdataCell(:, 21);
        neck_y = APTdataCell(:, 22);
        neckDist = distanceTraveled(:, 11);
        
        centre_x = APTdataCell(:, 23);
        centre_y = APTdataCell(:, 24);
        centreDist = distanceTraveled(:, 12);
        
        dyntable = table(allLVs, ele, azi, flipbool, bodyAxis, bodyAxisAngularVelocity, head_x, head_y, headDist, abdomen_x, abdomen_y, abdomenDist, t1left_x, t1left_y, t1leftDist, t2left_x, t2left_y, t2leftDist, t3left_x, t3left_y, t3leftDist, t3right_x, t3right_y, t3rightDist, t2right_x, t2right_y, t2rightDist, t1right_x, t1right_y, t1rightDist, bp1_x, bp1_y, bp1Dist, bp2_x, bp2_y, bp2Dist, neck_x, neck_y, neckDist, centre_x, centre_y, centreDist, startSize, endSize);
        
        %Fields that are 'double': allLVs, ele, azi, flipbool
        dyncell = [num2cell(allLVs), num2cell(ele), num2cell(azi), num2cell(flipbool), bodyAxis, bodyAxisAngularVelocity, head_x, head_y, headDist, abdomen_x, abdomen_y, abdomenDist, t1left_x, t1left_y, t1leftDist, t2left_x, t2left_y, t2leftDist, t3left_x, t3left_y, t3leftDist, t3right_x, t3right_y, t3rightDist, t2right_x, t2right_y, t2rightDist, t1right_x, t1right_y, t1rightDist, bp1_x, bp1_y, bp1Dist, bp2_x, bp2_y, bp2Dist, neck_x, neck_y, neckDist, centre_x, centre_y, centreDist, startSize, endSize];        
    end

    %% Make Flytable
    trial_regions = regionValue_by_trial_table.trial_regionValues;
     
    trialFull = cell(length(trial_regions), 1);
    for i = 1:length(trial_regions)
        trialFrames = regionValue_by_trial_table.region_frame{i};
        maxFrame = trialFrames(end);
        trialOrdered = nan(1, maxFrame);
        regions = trial_regions{i};
        for j = 1:length(trialFrames)
            trialOrdered(trialFrames(j)) = regions(j);
        end
        trialFull(i) = {trialOrdered};
    end

    frameofStimStart_adj = frameofStimStart(trial_list);
    frameofTakeoff_adj = frameofTakeoff(trial_list);
    stimLength_adj = stimLength(trial_list);
    stimTheta_frms_adj = transpose(stimTheta_frms(trial_list));
    allLVs_adj = allLVs(trial_list);
    legPushFrame_adj = legPushFrame(trial_list);
    wingUpFrame_adj = wingUpFrame(trial_list);
    jumpStart_adj = jumpStart(trial_list);
    takeoffTypes_adj = transpose(takeoffTypes(trial_list));

    VideoName_cell = fullset.('VideoName');
    VideoName = string(VideoName_cell(trial_list));
    Video_Path_cell = fullset.('Video_Path');
    Video_Path = string(Video_Path_cell(trial_list));
    gender_cell = fullset.('Gender');
    gender = string(gender_cell(trial_list));
    stimProtocol = string(stimCharacteristics(trial_list));

    flytable = table(trial_list, trial_regions, trialFull,  frameofStimStart_adj, frameofTakeoff_adj, stimLength_adj, stimTheta_frms_adj, allLVs_adj, legPushFrame_adj, wingUpFrame_adj, jumpStart_adj, gender, takeoffTypes_adj, stimProtocol, VideoName, Video_Path, ...
        'VariableNames', ["trial_list", "trial_regions", "trialFull", "frameofStimStart", "frameofTakeoff", "stimLength", "stimTheta_frms", "allLVs", "legPushFrame", "wingUpFrame", "jumpStart", "gender", "takeoffTypes", "stimProtocol", "VideoName", "VideoPath"]);
    
    %Fields that are 'double': trial_list, frameofStimStart_adj, frameofStimStart_adj, frameofTakeoff_adj, stimLength_adj, allLVs_adj, legPushFrame_adj, wingUpFrame_adj, jumpStart_adj, gender, takeoffTypes_adj, stimProtocol, VideoName, Video_Path
    flycell = [num2cell(trial_list), trial_regions, trialFull,  num2cell(frameofStimStart_adj), num2cell(frameofTakeoff_adj), num2cell(stimLength_adj), stimTheta_frms_adj, num2cell(allLVs_adj), num2cell(legPushFrame_adj), num2cell(wingUpFrame_adj), num2cell(jumpStart_adj), num2cell(gender), num2cell(takeoffTypes_adj), num2cell(stimProtocol), num2cell(VideoName), num2cell(Video_Path)];
   
    %% Flytable - NonZero
    flytable_nozero = flytable;
    zeroThresh = 30;
    for i = 1:length(flytable.trialFull)
        trialRegions = flytable.trialFull{i};
        prevRegion = trialRegions(1);
        zeroCount = 0;
        zeroStart = 0;
        for region_ind = 2:length(trialRegions)
            if trialRegions(region_ind) ~= 0
                if zeroCount > 0
                    if zeroCount < zeroThresh
                        trialRegions(zeroStart:zeroStart+zeroCount-1) = prevRegion;
                    end
                    zeroCount = 0;
                    zeroStart = 0;
                end
                prevRegion = trialRegions(region_ind);
            else
                if isnan(prevRegion) || (prevRegion == 0)
                    prevRegion = trialRegions(region_ind);
                    continue
                end
                if zeroCount == 0
                    zeroStart = region_ind;
                end
                zeroCount = zeroCount + 1;
            end
        end
    flytable_nozero.trialFull(i) = {trialRegions};
    end
    %%
    save([currentDir 'regionValue_by_trial_'  num2str(sigma) '.mat'],"regionValue_by_trial",'-mat');
    save([currentDir 'regionValue_by_trial_'  num2str(sigma) '_table.mat'],"regionValue_by_trial_table",'-mat');
    save([currentDir filesep 'dyncell.mat'],"dyncell",'-v7.3');
    save([currentDir filesep 'dyntable.mat'],"dyntable",'-v7.3');
    save([currentDir filesep 'flytable_' num2str(sigma) '.mat'],"flytable",'-mat');
    save([currentDir filesep 'flycell_' num2str(sigma) '.mat'],"flycell",'-mat');
    save([currentDir filesep 'smoothedData.mat'],"smoothedData",'-mat');
    save([currentDir filesep 'fullset.mat'],"fullset",'-mat');
    save([currentDir filesep 'starts.mat'],"starts",'-mat');
    save([currentDir filesep 'stops.mat'],"stops",'-mat');
end