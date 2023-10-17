%% Set # zeros that have to pass before region repeat when assigning novel regions, Changes 0 values in flytable_filter
%0.4 - 50
%0.6 - 26
%1.2 - 10
%% Run Timetable
sigma = 1.2;
zeroThresh = 0;
reaction_thresh = 0;   %amount of time from stimulus that needs to pass before registering action as reaction, used to filter out premature jump/wing raising
flankFrames = 200;     %#regions following last action
localPath = 'C:\Users\Dhruvum Bajpai\Desktop\Computational Project\';
load([localPath 'flytable_' num2str(sigma) '.mat'])

%% 
stimType = "loom_10to180_lv40_blackonwhite.mat";
%stimType = "loom_5to90_lv40_blackonwhite.mat";
%stimType = "loom_10to180_lv20_blackonwhite.mat";
 

stimBool = flytable.('stimProtocol') == stimType;
%Filter Parameters for Analysis
%response_bool = (~isnan(flytable.('takeoffTypes')) .* ~isnan(flytable.('frameofTakeoff')) .* ~isnan(flytable.('legPushFrame')) .* ~isnan(flytable.('wingUpFrame') .* ~isnan(flytable.('jumpStart'))))==1;
response_bool = (~isnan(flytable.('takeoffTypes')) .* ~isnan(flytable.('frameofTakeoff')))==1;

response_bool = logical(stimBool .* response_bool);
flytable_filter = flytable(response_bool, :);
escapeBool = logical(flytable_filter.takeoffTypes);
stimPlot = flytable_filter.stimTheta_frms{1};

%% Converts 0 regions (ignores NaN)
for i = 1:length(flytable_filter.trialFull)
    trialRegions = flytable_filter.trialFull{i};
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
    flytable_filter.trialFull(i) = {trialRegions};
end
%%
%stimLength = mode(flytable_filter.stimLength);
stimLength = length(flytable_filter.stimTheta_frms{1});
%trial_thresh = stimLength;    %how many frames after the stimulus a trial must contain
trial_thresh = 60;
%%

%Separate long and short mode takeoffs
flytableLong = flytable_filter(escapeBool, :);
flytableShort = flytable_filter(~escapeBool, :);

legPush_long = flytableLong.legPushFrame - flytableLong.frameofStimStart;
wingUp_long = flytableLong.wingUpFrame - flytableLong.frameofStimStart;
jump_long = flytableLong.jumpStart - flytableLong.frameofStimStart;


legPush_long = legPush_long(legPush_long>reaction_thresh);
wingUp_long = wingUp_long(wingUp_long>reaction_thresh);
jump_long = jump_long(jump_long>reaction_thresh);

legPush_long_xline = mean(legPush_long);
wingUp_long_xline = mean(wingUp_long);
jump_long_xline = mean(jump_long);

regionArrayLong = [];
for i = 1:height(flytableLong)
    trial = flytableLong.trialFull{i};
    trialLength = length(trial);
    trialStart = flytableLong.frameofStimStart(i);
    reactionLength = trialLength - trialStart;
    trialAdj = [nan(1,(2*flankFrames + stimLength))];

    trialAdjStart = 1;
    reactionStart = flytableLong.frameofStimStart(i) - flankFrames + 1;
    trialAdjStop = 2*flankFrames + stimLength;
        if reactionLength >= trial_thresh
            if flytableLong.frameofStimStart(i) < flankFrames
                trialAdjStart = flankFrames - flytableLong.frameofStimStart(i) + 1;
                reactionStart = 1;
            end
            if reactionLength < flankFrames + stimLength
               trialAdjStop = flankFrames + reactionLength;
            end
                trialAdj(trialAdjStart:trialAdjStop) = trial(reactionStart:(reactionStart + trialAdjStop-trialAdjStart));
                regionArrayLong = [regionArrayLong;trialAdj];
        end
end

legPush_short = flytableShort.legPushFrame - flytableShort.frameofStimStart;
wingUp_short = flytableShort.wingUpFrame - flytableShort.frameofStimStart;
jump_short = flytableShort.jumpStart - flytableShort.frameofStimStart;


legPush_short = legPush_short(legPush_short>reaction_thresh);
wingUp_short = wingUp_short(wingUp_short>reaction_thresh);
jump_short = jump_short(jump_short>reaction_thresh);

legPush_short_xline = mean(legPush_short);
wingUp_short_xline = mean(wingUp_short);
jump_short_xline = mean(jump_short);

regionArrayShort = [];
for i = 1:height(flytableShort)
    trial = flytableShort.trialFull{i};
    trialLength = length(trial);
    trialStart = flytableShort.frameofStimStart(i);
    reactionLength = trialLength - trialStart;
    trialAdj = [nan(1,(2*flankFrames + stimLength))];

    trialAdjStart = 1;
    reactionStart = flytableShort.frameofStimStart(i) - flankFrames + 1;
    trialAdjStop = 2*flankFrames + stimLength;
        if reactionLength >= trial_thresh
            if flytableShort.frameofStimStart(i) < flankFrames
                trialAdjStart = flankFrames - flytableShort.frameofStimStart(i) + 1;
                reactionStart = 1;
            end
            if reactionLength < flankFrames + stimLength
               trialAdjStop = flankFrames + reactionLength;
            end
                trialAdj(trialAdjStart:trialAdjStop) = trial(reactionStart:(reactionStart + trialAdjStop-trialAdjStart));
                regionArrayShort = [regionArrayShort;trialAdj];
        end
end

nanCount_long = sum(isnan(regionArrayLong))/length(regionArrayLong);
nanCount_short = sum(isnan(regionArrayShort))/length(regionArrayShort);
ax(1) = subplot(2, 6, 1);
plot(nanCount_short, 'r');
hold on
plot(nanCount_long, 'cyan');
hold on
plot([nan(1, flankFrames), stimPlot*0.05], 'k', 'LineWidth', 3, DisplayName='Stimulus')
hold on
xline(flankFrames, 'k', DisplayName='Stim Start')
xline(flankFrames + length(stimPlot), 'k', DisplayName='Stim Stop')
xline(legPush_long_xline + flankFrames, 'cyan', DisplayName='Long Takeoff')
xline(legPush_short_xline + flankFrames, 'r', DisplayName='Short Takeoff')
title('NaN')

columnsNonan_long =  sum(~isnan(regionArrayLong));
columnsNonan_short =  sum(~isnan(regionArrayShort));


for region_hist = 0:10
    regionCountLong = sum(regionArrayLong == region_hist)./columnsNonan_long;
    regionCountShort = sum(regionArrayShort == region_hist)./columnsNonan_short;

    ax(region_hist+1) = subplot(2, 6, region_hist+2);   %Change arrangement of subplots here
    plot(regionCountLong, DisplayName='Long');
    hold on
    plot(regionCountShort, DisplayName='Short');
    hold on
    plot([nan(1, flankFrames), stimPlot*0.2], 'k', 'LineWidth', 3, DisplayName='Stimulus')
    hold on
    xline(flankFrames, 'k', DisplayName='Stim Start')
    xline(flankFrames + length(stimPlot), 'k', DisplayName='Stim Stop')
    xline(legPush_long_xline + flankFrames, 'cyan', DisplayName='Long Takeoff')
    xline(legPush_short_xline + flankFrames, 'r', DisplayName='Short Takeoff')

    if region_hist == 0
        title('0 (Unassigned)')
    else
        plotTitle = [num2str(region_hist)];
        title(plotTitle)
    end
    %legend show
end
linkaxes(ax, 'y')   %Need loop to match #subplots for linkaxes to work