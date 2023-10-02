filePath='C:\Users\Dhruvum Bajpai\Desktop\Computational Project'; %change this to the file path you want
load([filePath filesep 'flytable.mat'])
load([filePath filesep 'dyntable.mat'])
%%
trialLength = cellfun(@length, flytable.trial_regions);
trialLengthThresh = 200;
jumpTrials = flytable.trial_list(~isnan(flytable.frameofTakeoff)&(trialLength>trialLengthThresh));
%%
trialNo = 752;
% Best trial: 42
% Region 0 acts as the transitory stage between different regions.
%Region 10 (the Orange line) coincides with fast action, particularly
%takeoff. It also tends to be the longest region.

%It appears that Region 4 occurs immediately after the point of leg-raise
trialRegions = flytable.trial_regions{trialNo};
startFrame = flytable.frameofStimStart(trialNo);
regionCell = cell(1,9);

for region_num = 1:10
    tempArray = nan(1, length(dyntable.bodyAxis{trialNo}));
    region = double(flytable.trialFull{trialNo} == region_num-1);
    region(region==0) = NaN;
    tempArray(startFrame:startFrame+length(region)-1) = region;
    regionCell{region_num} = tempArray;
end

isJump = flytable.jumpStart(trialNo);

%%
error = 0;
ax(1) = subplot(3, 4, 1);
for i = 1:10
    if length(dyntable.t1leftDist{trialNo}) < length(regionCell{i})
        adjLength = length(dyntable.t1leftDist{trialNo});
        adjCell = regionCell{i};
        regionCell{i} = adjCell(1:adjLength);
        if error == 0
        disp('Region count outnumbers Speed count')
        error = 1;
        end
    end
    plot(dyntable.t1leftDist{trialNo}.*regionCell{i}')
    hold on
end
xline(startFrame, 'k', DisplayName='Stim Start')
xline(flytable.wingUpFrame(trialNo), 'blue', DisplayName='Wing Up')
xline(flytable.jumpStart(trialNo), 'magenta', DisplayName='Jump Start')
xline(flytable.legPushFrame(trialNo), 'k', DisplayName='Leg Push')
title('Left T1')
legend

ax(2) = subplot(3, 4, 2);
for i = 1:10
    plot(dyntable.t2leftDist{trialNo}.*regionCell{i}')
    hold on
end
xline(startFrame, 'k', DisplayName='Stim Start')
xline(flytable.wingUpFrame(trialNo), 'blue', DisplayName='Wing Up')
xline(flytable.jumpStart(trialNo), 'magenta', DisplayName='Jump Start')
xline(flytable.legPushFrame(trialNo), 'k', DisplayName='Leg Push')
title('Left T2')

ax(3) = subplot(3, 4, 3);
for i = 1:10
    plot(dyntable.t3leftDist{trialNo}.*regionCell{i}')
    hold on
end
xline(startFrame, 'k', DisplayName='Stim Start')
xline(flytable.wingUpFrame(trialNo), 'blue', DisplayName='Wing Up')
xline(flytable.jumpStart(trialNo), 'magenta', DisplayName='Jump Start')
xline(flytable.legPushFrame(trialNo), 'k', DisplayName='Leg Push')
title('Left T3')

ax(4) = subplot(3, 4, 4);
for i = 1:10
    plot(dyntable.t1rightDist{trialNo}.*regionCell{i}')
    hold on
end
xline(startFrame, 'k', DisplayName='Stim Start')
xline(flytable.wingUpFrame(trialNo), 'blue', DisplayName='Wing Up')
xline(flytable.jumpStart(trialNo), 'magenta', DisplayName='Jump Start')
xline(flytable.legPushFrame(trialNo), 'k', DisplayName='Leg Push')
title('Right T1')

ax(5) = subplot(3, 4, 5);
for i = 1:10
    plot(dyntable.t2rightDist{trialNo}.*regionCell{i}')
    hold on
end
xline(startFrame, 'k', DisplayName='Stim Start')
xline(flytable.wingUpFrame(trialNo), 'blue', DisplayName='Wing Up')
xline(flytable.jumpStart(trialNo), 'magenta', DisplayName='Jump Start')
xline(flytable.legPushFrame(trialNo), 'k', DisplayName='Leg Push')
title('Right T2')

ax(6) = subplot(3, 4, 6);
for i = 1:10
    plot(dyntable.t3rightDist{trialNo}.*regionCell{i}')
    hold on
end
xline(startFrame, 'k', DisplayName='Stim Start')
xline(flytable.wingUpFrame(trialNo), 'blue', DisplayName='Wing Up')
xline(flytable.jumpStart(trialNo), 'magenta', DisplayName='Jump Start')
xline(flytable.legPushFrame(trialNo), 'k', DisplayName='Leg Push')
title('Right T3')

ax(7) = subplot(3, 4, 7);
for i = 1:10
    plot(dyntable.headDist{trialNo}.*regionCell{i}')
    hold on
end
xline(startFrame, 'k', DisplayName='Stim Start')
xline(flytable.wingUpFrame(trialNo), 'blue', DisplayName='Wing Up')
xline(flytable.jumpStart(trialNo), 'magenta', DisplayName='Jump Start')
xline(flytable.legPushFrame(trialNo), 'k', DisplayName='Leg Push')
title('Head')

ax(8) = subplot(3, 4, 8);
for i = 1:10
    plot(dyntable.centreDist{trialNo}.*regionCell{i}')
    hold on
end
xline(startFrame, 'k', DisplayName='Stim Start')
xline(flytable.wingUpFrame(trialNo), 'blue', DisplayName='Wing Up')
xline(flytable.jumpStart(trialNo), 'magenta', DisplayName='Jump Start')
xline(flytable.legPushFrame(trialNo), 'k', DisplayName='Leg Push')
title('Centre')

ax(9) = subplot(3, 4, 9);
for i = 1:10
    plot(dyntable.abdomenDist{trialNo}.*regionCell{i}')
    hold on
end
xline(startFrame, 'k', DisplayName='Stim Start')
xline(flytable.wingUpFrame(trialNo), 'blue', DisplayName='Wing Up')
xline(flytable.jumpStart(trialNo), 'magenta', DisplayName='Jump Start')
xline(flytable.legPushFrame(trialNo), 'k', DisplayName='Leg Push')
title('Abdomen')

ax(10) = subplot(3, 4, 10);
for i = 1:10
    plot(dyntable.bp1Dist{trialNo}.*regionCell{i}')
    hold on
end
xline(startFrame, 'k', DisplayName='Stim Start')
xline(flytable.wingUpFrame(trialNo), 'blue', DisplayName='Wing Up')
xline(flytable.jumpStart(trialNo), 'magenta', DisplayName='Jump Start')
xline(flytable.legPushFrame(trialNo), 'k', DisplayName='Leg Push')
title('Body Point 1')

ax(11) = subplot(3, 4, 11);
for i = 1:10
    plot(dyntable.bp2Dist{trialNo}.*regionCell{i}')
    hold on
end
xline(startFrame, 'k', DisplayName='Stim Start')
xline(flytable.wingUpFrame(trialNo), 'blue', DisplayName='Wing Up')
xline(flytable.jumpStart(trialNo), 'magenta', DisplayName='Jump Start')
xline(flytable.legPushFrame(trialNo), 'k', DisplayName='Leg Push')
title('Body Point 2')

ax(12) = subplot(3, 4, 12);
for i = 1:10
    plot(dyntable.bodyAxisAngularVelocity{trialNo}.*regionCell{i}')
    hold on
end
xline(startFrame, 'k', DisplayName='Stim Start')
xline(flytable.wingUpFrame(trialNo), 'blue', DisplayName='Wing Up')
xline(flytable.jumpStart(trialNo), 'magenta', DisplayName='Jump Start')
xline(flytable.legPushFrame(trialNo), 'k', DisplayName='Leg Push')
title('Angular Velocity')

linkaxes(ax, 'x')