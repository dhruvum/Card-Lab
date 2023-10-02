filePath='C:\Users\Dhruvum Bajpai\Desktop\Computational Project'; %change this to the file path you want
load([filePath filesep 'flytable.mat'])
load([filePath filesep 'dyntable.mat'])
%%
trialLength = cellfun(@length, flytable.trial_regions);
trialLengthThresh = 200;
jumpTrials = flytable.trial_list(~isnan(flytable.frameofTakeoff)&(trialLength>trialLengthThresh));
%jumpTrials lists the IDs of trials that include takeoffs AND are longer
%than a certain threshold
%%

trialNo = 1130;
%874 has a wide range of regions
error = 0;
trialRegions = flytable.trial_regions{trialNo};
startFrame = flytable.frameofStimStart(trialNo);
wingUpFrame = flytable.wingUpFrame(trialNo);
legPushFrame = flytable.legPushFrame(trialNo);
jumpStart = flytable.jumpStart(trialNo);
takeoffFrame = flytable.frameofTakeoff(trialNo);

regionCell = cell(1,9);

for region_num = 1:10
    tempArray = nan(1, length(dyntable.bodyAxis{trialNo}));
    region = double(flytable.trialFull{trialNo} == region_num-1);
    region(region==0) = NaN;
    tempArray(startFrame:startFrame+length(region)-1) = region;
    regionCell{region_num} = tempArray;
end

isJump = flytable.jumpStart(trialNo);

%% Whole Body Tracking - Labeled regions, body points start at 0
h = zeros(1, 23);

z = 1:length(dyntable.centre_x{trialNo});
h(6) = plot3(dyntable.centre_x{trialNo}, dyntable.centre_y{trialNo}, z, '-k', DisplayName='Unassigned/NaN');
hold on
h(1) = plot3(dyntable.centre_x{trialNo}(flytable.frameofStimStart(trialNo)), dyntable.centre_y{trialNo}(flytable.frameofStimStart(trialNo)), flytable.frameofStimStart(trialNo), '*k', DisplayName='Start Stim');
hold on
h(2) = plot3(dyntable.centre_x{trialNo}(flytable.wingUpFrame(trialNo)), dyntable.centre_y{trialNo}(flytable.wingUpFrame(trialNo)), flytable.wingUpFrame(trialNo), '*r', DisplayName='Wing Up');
hold on
h(3) = plot3(dyntable.centre_x{trialNo}(flytable.jumpStart(trialNo)), dyntable.centre_y{trialNo}(flytable.jumpStart(trialNo)), flytable.jumpStart(trialNo), '*g', DisplayName='Jump Start');
hold on
h(4) = plot3(dyntable.centre_x{trialNo}(flytable.legPushFrame(trialNo)), dyntable.centre_y{trialNo}(flytable.legPushFrame(trialNo)), flytable.legPushFrame(trialNo), '*b', DisplayName='Leg Push');
hold on
h(5) = plot3(dyntable.centre_x{trialNo}(flytable.frameofTakeoff(trialNo)), dyntable.centre_y{trialNo}(flytable.frameofTakeoff(trialNo)), flytable.frameofTakeoff(trialNo), '*k', DisplayName='Takeoff');
hold on

for i = 1:10
    adjLength = length(regionCell{i});
    if length(dyntable.centre_x{trialNo}) < length(regionCell{i})
        adjLength = length(dyntable.centre_x{trialNo});
        adjCell = regionCell{i};
        regionCell{i} = adjCell(1:adjLength);
        if error == 0
        disp('Region count outnumbers Speed count')
        error = 1;
        end
    end

    x = (dyntable.centre_x{trialNo}.*regionCell{i}');
    y = (dyntable.centre_y{trialNo}.*regionCell{i}');
    plot_name = 'Region ' + string((i-1));
    cm = hsv(10);
    h(i + 6) = plot3(x, y, z, Color=cm(i, :), DisplayName=plot_name);
    hold on
end
cm2 = jet(7);
h(17) = plot3(dyntable.centre_x{trialNo}(1), dyntable.centre_y{trialNo}(1), 0, 'o', Color=cm2(1, :), DisplayName='Centre');

plot3(dyntable.t1left_x{trialNo}, dyntable.t1left_y{trialNo}, z, '-k');
hold on
plot3(dyntable.t1left_x{trialNo}(flytable.frameofStimStart(trialNo)), dyntable.t1left_y{trialNo}(flytable.frameofStimStart(trialNo)), flytable.frameofStimStart(trialNo), '*k');
hold on
plot3(dyntable.t1left_x{trialNo}(flytable.wingUpFrame(trialNo)), dyntable.t1left_y{trialNo}(flytable.wingUpFrame(trialNo)), flytable.wingUpFrame(trialNo), '*r');
hold on
plot3(dyntable.t1left_x{trialNo}(flytable.jumpStart(trialNo)), dyntable.t1left_y{trialNo}(flytable.jumpStart(trialNo)), flytable.jumpStart(trialNo), '*g');
hold on
plot3(dyntable.t1left_x{trialNo}(flytable.legPushFrame(trialNo)), dyntable.t1left_y{trialNo}(flytable.legPushFrame(trialNo)), flytable.legPushFrame(trialNo), '*b');
hold on
plot3(dyntable.t1left_x{trialNo}(flytable.frameofTakeoff(trialNo)), dyntable.t1left_y{trialNo}(flytable.frameofTakeoff(trialNo)), flytable.frameofTakeoff(trialNo), '*k');
hold on

for i = 1:10
    adjLength = length(regionCell{i});
    x = (dyntable.t1left_x{trialNo}.*regionCell{i}');
    y = (dyntable.t1left_y{trialNo}.*regionCell{i}');
    z = 1:length(x);
    cm = hsv(10);
    plot3(x, y, z, Color=cm(i, :))
    hold on
end
h(18) = plot3(dyntable.t1left_x{trialNo}(1), dyntable.t1left_y{trialNo}(1), 0, 'o', Color=cm2(2, :), DisplayName='T1 Left');

plot3(dyntable.t2left_x{trialNo}, dyntable.t2left_y{trialNo}, z, '-k');
hold on
plot3(dyntable.t2left_x{trialNo}(flytable.frameofStimStart(trialNo)), dyntable.t2left_y{trialNo}(flytable.frameofStimStart(trialNo)), flytable.frameofStimStart(trialNo), '*k');
hold on
plot3(dyntable.t2left_x{trialNo}(flytable.wingUpFrame(trialNo)), dyntable.t2left_y{trialNo}(flytable.wingUpFrame(trialNo)), flytable.wingUpFrame(trialNo), '*r');
hold on
plot3(dyntable.t2left_x{trialNo}(flytable.jumpStart(trialNo)), dyntable.t2left_y{trialNo}(flytable.jumpStart(trialNo)), flytable.jumpStart(trialNo), '*g');
hold on
plot3(dyntable.t2left_x{trialNo}(flytable.legPushFrame(trialNo)), dyntable.t2left_y{trialNo}(flytable.legPushFrame(trialNo)), flytable.legPushFrame(trialNo), '*b');
hold on
plot3(dyntable.t2left_x{trialNo}(flytable.frameofTakeoff(trialNo)), dyntable.t2left_y{trialNo}(flytable.frameofTakeoff(trialNo)), flytable.frameofTakeoff(trialNo), '*k');
hold on

for i = 1:10
    adjLength = length(regionCell{i});
    x = (dyntable.t2left_x{trialNo}.*regionCell{i}');
    y = (dyntable.t2left_y{trialNo}.*regionCell{i}');
    z = 1:length(x);
    cm = hsv(10);
    plot3(x, y, z, Color=cm(i, :))
    hold on
end
h(19) = plot3(dyntable.t2left_x{trialNo}(1), dyntable.t2left_y{trialNo}(1), 0, 'o', Color=cm2(3, :), DisplayName='T2 Left');

plot3(dyntable.t3left_x{trialNo}, dyntable.t3left_y{trialNo}, z, '-k');
hold on
plot3(dyntable.t3left_x{trialNo}(flytable.frameofStimStart(trialNo)), dyntable.t3left_y{trialNo}(flytable.frameofStimStart(trialNo)), flytable.frameofStimStart(trialNo), '*k');
hold on
plot3(dyntable.t3left_x{trialNo}(flytable.wingUpFrame(trialNo)), dyntable.t3left_y{trialNo}(flytable.wingUpFrame(trialNo)), flytable.wingUpFrame(trialNo), '*r');
hold on
plot3(dyntable.t3left_x{trialNo}(flytable.jumpStart(trialNo)), dyntable.t3left_y{trialNo}(flytable.jumpStart(trialNo)), flytable.jumpStart(trialNo), '*g');
hold on
plot3(dyntable.t3left_x{trialNo}(flytable.legPushFrame(trialNo)), dyntable.t3left_y{trialNo}(flytable.legPushFrame(trialNo)), flytable.legPushFrame(trialNo), '*b');
hold on
plot3(dyntable.t3left_x{trialNo}(flytable.frameofTakeoff(trialNo)), dyntable.t3left_y{trialNo}(flytable.frameofTakeoff(trialNo)), flytable.frameofTakeoff(trialNo), '*k');
hold on

for i = 1:10
    adjLength = length(regionCell{i});
    x = (dyntable.t3left_x{trialNo}.*regionCell{i}');
    y = (dyntable.t3left_y{trialNo}.*regionCell{i}');
    z = 1:length(x);
    cm = hsv(10);
    plot3(x, y, z, Color=cm(i, :))
    hold on
end
h(20) = plot3(dyntable.t3left_x{trialNo}(1), dyntable.t3left_y{trialNo}(1), 0, 'o', Color=cm2(4, :), DisplayName='T3 Left');

plot3(dyntable.t1right_x{trialNo}, dyntable.t1right_y{trialNo}, z, '-k');
hold on
plot3(dyntable.t1right_x{trialNo}(flytable.frameofStimStart(trialNo)), dyntable.t1right_y{trialNo}(flytable.frameofStimStart(trialNo)), flytable.frameofStimStart(trialNo), '*k');
hold on
plot3(dyntable.t1right_x{trialNo}(flytable.wingUpFrame(trialNo)), dyntable.t1right_y{trialNo}(flytable.wingUpFrame(trialNo)), flytable.wingUpFrame(trialNo), '*r');
hold on
plot3(dyntable.t1right_x{trialNo}(flytable.jumpStart(trialNo)), dyntable.t1right_y{trialNo}(flytable.jumpStart(trialNo)), flytable.jumpStart(trialNo), '*g');
hold on
plot3(dyntable.t1right_x{trialNo}(flytable.legPushFrame(trialNo)), dyntable.t1right_y{trialNo}(flytable.legPushFrame(trialNo)), flytable.legPushFrame(trialNo), '*b');
hold on
plot3(dyntable.t1right_x{trialNo}(flytable.frameofTakeoff(trialNo)), dyntable.t1right_y{trialNo}(flytable.frameofTakeoff(trialNo)), flytable.frameofTakeoff(trialNo), '*k');
hold on

for i = 1:10
    adjLength = length(regionCell{i});
    x = (dyntable.t1right_x{trialNo}.*regionCell{i}');
    y = (dyntable.t1right_y{trialNo}.*regionCell{i}');
    z = 1:length(x);
    cm = hsv(10);
    plot3(x, y, z, Color=cm(i, :))
    hold on
end
h(21) = plot3(dyntable.t1right_x{trialNo}(1), dyntable.t1right_y{trialNo}(1), 0, 'o', Color=cm2(5, :), DisplayName='T1 Right');

plot3(dyntable.t2right_x{trialNo}, dyntable.t2right_y{trialNo}, z, '-k');
hold on
plot3(dyntable.t2right_x{trialNo}(flytable.frameofStimStart(trialNo)), dyntable.t2right_y{trialNo}(flytable.frameofStimStart(trialNo)), flytable.frameofStimStart(trialNo), '*k');
hold on
plot3(dyntable.t2right_x{trialNo}(flytable.wingUpFrame(trialNo)), dyntable.t2right_y{trialNo}(flytable.wingUpFrame(trialNo)), flytable.wingUpFrame(trialNo), '*r');
hold on
plot3(dyntable.t2right_x{trialNo}(flytable.jumpStart(trialNo)), dyntable.t2right_y{trialNo}(flytable.jumpStart(trialNo)), flytable.jumpStart(trialNo), '*g');
hold on
plot3(dyntable.t2right_x{trialNo}(flytable.legPushFrame(trialNo)), dyntable.t2right_y{trialNo}(flytable.legPushFrame(trialNo)), flytable.legPushFrame(trialNo), '*b');
hold on
plot3(dyntable.t2right_x{trialNo}(flytable.frameofTakeoff(trialNo)), dyntable.t2right_y{trialNo}(flytable.frameofTakeoff(trialNo)), flytable.frameofTakeoff(trialNo), '*k');
hold on

for i = 1:10
    adjLength = length(regionCell{i});
    x = (dyntable.t2right_x{trialNo}.*regionCell{i}');
    y = (dyntable.t2right_y{trialNo}.*regionCell{i}');
    z = 1:length(x);
    cm = hsv(10);
    plot3(x, y, z, Color=cm(i, :))
    hold on
end
h(22) = plot3(dyntable.t2right_x{trialNo}(1), dyntable.t2right_y{trialNo}(1), 0, 'o', Color=cm2(6, :), DisplayName='T2 Right');

plot3(dyntable.t3right_x{trialNo}, dyntable.t3right_y{trialNo}, z, '-k');
hold on
plot3(dyntable.t3right_x{trialNo}(flytable.frameofStimStart(trialNo)), dyntable.t3right_y{trialNo}(flytable.frameofStimStart(trialNo)), flytable.frameofStimStart(trialNo), '*k');
hold on
plot3(dyntable.t3right_x{trialNo}(flytable.wingUpFrame(trialNo)), dyntable.t3right_y{trialNo}(flytable.wingUpFrame(trialNo)), flytable.wingUpFrame(trialNo), '*r');
hold on
plot3(dyntable.t3right_x{trialNo}(flytable.jumpStart(trialNo)), dyntable.t3right_y{trialNo}(flytable.jumpStart(trialNo)), flytable.jumpStart(trialNo), '*g');
hold on
plot3(dyntable.t3right_x{trialNo}(flytable.legPushFrame(trialNo)), dyntable.t3right_y{trialNo}(flytable.legPushFrame(trialNo)), flytable.legPushFrame(trialNo), '*b');
hold on
plot3(dyntable.t3right_x{trialNo}(flytable.frameofTakeoff(trialNo)), dyntable.t3right_y{trialNo}(flytable.frameofTakeoff(trialNo)), flytable.frameofTakeoff(trialNo), '*k');
hold on

for i = 1:10
    adjLength = length(regionCell{i});
    x = (dyntable.t3right_x{trialNo}.*regionCell{i}');
    y = (dyntable.t3right_y{trialNo}.*regionCell{i}');
    z = 1:length(x);
    cm = hsv(10);
    plot3(x, y, z, Color=cm(i, :))
    hold on
end
h(23) = plot3(dyntable.t3right_x{trialNo}(1), dyntable.t3right_y{trialNo}(1), 0, 'o', Color=cm2(7, :), DisplayName='T3 Right');

legend(h(1:end))
%% %% Whole Body Tracking - Smoothed
h = zeros(1, 23);

z = 1:length(dyntable.centre_x{trialNo});
h(6) = plot3(smoothdata(dyntable.centre_x{trialNo}), smoothdata(dyntable.centre_y{trialNo}), z, '-k', DisplayName='Unassigned/NaN');
hold on
h(1) = plot3(dyntable.centre_x{trialNo}(flytable.frameofStimStart(trialNo)), dyntable.centre_y{trialNo}(flytable.frameofStimStart(trialNo)), flytable.frameofStimStart(trialNo), '*k', DisplayName='Start Stim');
hold on
h(2) = plot3(dyntable.centre_x{trialNo}(flytable.wingUpFrame(trialNo)), dyntable.centre_y{trialNo}(flytable.wingUpFrame(trialNo)), flytable.wingUpFrame(trialNo), '*r', DisplayName='Wing Up');
hold on
h(3) = plot3(dyntable.centre_x{trialNo}(flytable.jumpStart(trialNo)), dyntable.centre_y{trialNo}(flytable.jumpStart(trialNo)), flytable.jumpStart(trialNo), '*g', DisplayName='Jump Start');
hold on
h(4) = plot3(dyntable.centre_x{trialNo}(flytable.legPushFrame(trialNo)), dyntable.centre_y{trialNo}(flytable.legPushFrame(trialNo)), flytable.legPushFrame(trialNo), '*b', DisplayName='Leg Push');
hold on
h(5) = plot3(dyntable.centre_x{trialNo}(flytable.frameofTakeoff(trialNo)), dyntable.centre_y{trialNo}(flytable.frameofTakeoff(trialNo)), flytable.frameofTakeoff(trialNo), '*k', DisplayName='Takeoff');
hold on

for i = 1:10
    adjLength = length(regionCell{i});
    if length(dyntable.centre_x{trialNo}) < length(regionCell{i})
        adjLength = length(dyntable.centre_x{trialNo});
        adjCell = regionCell{i};
        regionCell{i} = adjCell(1:adjLength);
        if error == 0
        disp('Region count outnumbers Speed count')
        error = 1;
        end
    end

    x = (dyntable.centre_x{trialNo}.*regionCell{i}');
    y = (dyntable.centre_y{trialNo}.*regionCell{i}');
    plot_name = 'Region ' + string((i-1));
    cm = hsv(10);
    h(i + 6) = plot3(x, y, z, Color=cm(i, :), DisplayName=plot_name);
    hold on
end
cm2 = jet(7);
h(17) = plot3(dyntable.centre_x{trialNo}(1), dyntable.centre_y{trialNo}(1), 0, 'o', Color=cm2(1, :), DisplayName='Centre');

plot3(smoothdata(dyntable.t1left_x{trialNo}), smoothdata(dyntable.t1left_y{trialNo}), z, '-k');
hold on
plot3(dyntable.t1left_x{trialNo}(flytable.frameofStimStart(trialNo)), dyntable.t1left_y{trialNo}(flytable.frameofStimStart(trialNo)), flytable.frameofStimStart(trialNo), '*k');
hold on
plot3(dyntable.t1left_x{trialNo}(flytable.wingUpFrame(trialNo)), dyntable.t1left_y{trialNo}(flytable.wingUpFrame(trialNo)), flytable.wingUpFrame(trialNo), '*r');
hold on
plot3(dyntable.t1left_x{trialNo}(flytable.jumpStart(trialNo)), dyntable.t1left_y{trialNo}(flytable.jumpStart(trialNo)), flytable.jumpStart(trialNo), '*g');
hold on
plot3(dyntable.t1left_x{trialNo}(flytable.legPushFrame(trialNo)), dyntable.t1left_y{trialNo}(flytable.legPushFrame(trialNo)), flytable.legPushFrame(trialNo), '*b');
hold on
plot3(dyntable.t1left_x{trialNo}(flytable.frameofTakeoff(trialNo)), dyntable.t1left_y{trialNo}(flytable.frameofTakeoff(trialNo)), flytable.frameofTakeoff(trialNo), '*k');
hold on

for i = 1:10
    adjLength = length(regionCell{i});
    x = (dyntable.t1left_x{trialNo}.*regionCell{i}');
    y = (dyntable.t1left_y{trialNo}.*regionCell{i}');
    z = 1:length(x);
    cm = hsv(10);
    plot3(x, y, z, Color=cm(i, :))
    hold on
end
h(18) = plot3(dyntable.t1left_x{trialNo}(1), dyntable.t1left_y{trialNo}(1), 0, 'o', Color=cm2(2, :), DisplayName='T1 Left');

plot3(smoothdata(dyntable.t2left_x{trialNo}), smoothdata(dyntable.t2left_y{trialNo}), z, '-k');
hold on
plot3(dyntable.t2left_x{trialNo}(flytable.frameofStimStart(trialNo)), dyntable.t2left_y{trialNo}(flytable.frameofStimStart(trialNo)), flytable.frameofStimStart(trialNo), '*k');
hold on
plot3(dyntable.t2left_x{trialNo}(flytable.wingUpFrame(trialNo)), dyntable.t2left_y{trialNo}(flytable.wingUpFrame(trialNo)), flytable.wingUpFrame(trialNo), '*r');
hold on
plot3(dyntable.t2left_x{trialNo}(flytable.jumpStart(trialNo)), dyntable.t2left_y{trialNo}(flytable.jumpStart(trialNo)), flytable.jumpStart(trialNo), '*g');
hold on
plot3(dyntable.t2left_x{trialNo}(flytable.legPushFrame(trialNo)), dyntable.t2left_y{trialNo}(flytable.legPushFrame(trialNo)), flytable.legPushFrame(trialNo), '*b');
hold on
plot3(dyntable.t2left_x{trialNo}(flytable.frameofTakeoff(trialNo)), dyntable.t2left_y{trialNo}(flytable.frameofTakeoff(trialNo)), flytable.frameofTakeoff(trialNo), '*k');
hold on

for i = 1:10
    adjLength = length(regionCell{i});
    x = (dyntable.t2left_x{trialNo}.*regionCell{i}');
    y = (dyntable.t2left_y{trialNo}.*regionCell{i}');
    z = 1:length(x);
    cm = hsv(10);
    plot3(x, y, z, Color=cm(i, :))
    hold on
end
h(19) = plot3(dyntable.t2left_x{trialNo}(1), dyntable.t2left_y{trialNo}(1), 0, 'o', Color=cm2(3, :), DisplayName='T2 Left');

plot3(smoothdata(dyntable.t3left_x{trialNo}), smoothdata(dyntable.t3left_y{trialNo}), z, '-k');
hold on
plot3(dyntable.t3left_x{trialNo}(flytable.frameofStimStart(trialNo)), dyntable.t3left_y{trialNo}(flytable.frameofStimStart(trialNo)), flytable.frameofStimStart(trialNo), '*k');
hold on
plot3(dyntable.t3left_x{trialNo}(flytable.wingUpFrame(trialNo)), dyntable.t3left_y{trialNo}(flytable.wingUpFrame(trialNo)), flytable.wingUpFrame(trialNo), '*r');
hold on
plot3(dyntable.t3left_x{trialNo}(flytable.jumpStart(trialNo)), dyntable.t3left_y{trialNo}(flytable.jumpStart(trialNo)), flytable.jumpStart(trialNo), '*g');
hold on
plot3(dyntable.t3left_x{trialNo}(flytable.legPushFrame(trialNo)), dyntable.t3left_y{trialNo}(flytable.legPushFrame(trialNo)), flytable.legPushFrame(trialNo), '*b');
hold on
plot3(dyntable.t3left_x{trialNo}(flytable.frameofTakeoff(trialNo)), dyntable.t3left_y{trialNo}(flytable.frameofTakeoff(trialNo)), flytable.frameofTakeoff(trialNo), '*k');
hold on

for i = 1:10
    adjLength = length(regionCell{i});
    x = (dyntable.t3left_x{trialNo}.*regionCell{i}');
    y = (dyntable.t3left_y{trialNo}.*regionCell{i}');
    z = 1:length(x);
    cm = hsv(10);
    plot3(x, y, z, Color=cm(i, :))
    hold on
end
h(20) = plot3(dyntable.t3left_x{trialNo}(1), dyntable.t3left_y{trialNo}(1), 0, 'o', Color=cm2(4, :), DisplayName='T3 Left');

plot3(smoothdata(dyntable.t1right_x{trialNo}), smoothdata(dyntable.t1right_y{trialNo}), z, '-k');
hold on
plot3(dyntable.t1right_x{trialNo}(flytable.frameofStimStart(trialNo)), dyntable.t1right_y{trialNo}(flytable.frameofStimStart(trialNo)), flytable.frameofStimStart(trialNo), '*k');
hold on
plot3(dyntable.t1right_x{trialNo}(flytable.wingUpFrame(trialNo)), dyntable.t1right_y{trialNo}(flytable.wingUpFrame(trialNo)), flytable.wingUpFrame(trialNo), '*r');
hold on
plot3(dyntable.t1right_x{trialNo}(flytable.jumpStart(trialNo)), dyntable.t1right_y{trialNo}(flytable.jumpStart(trialNo)), flytable.jumpStart(trialNo), '*g');
hold on
plot3(dyntable.t1right_x{trialNo}(flytable.legPushFrame(trialNo)), dyntable.t1right_y{trialNo}(flytable.legPushFrame(trialNo)), flytable.legPushFrame(trialNo), '*b');
hold on
plot3(dyntable.t1right_x{trialNo}(flytable.frameofTakeoff(trialNo)), dyntable.t1right_y{trialNo}(flytable.frameofTakeoff(trialNo)), flytable.frameofTakeoff(trialNo), '*k');
hold on

for i = 1:10
    adjLength = length(regionCell{i});
    x = (dyntable.t1right_x{trialNo}.*regionCell{i}');
    y = (dyntable.t1right_y{trialNo}.*regionCell{i}');
    z = 1:length(x);
    cm = hsv(10);
    plot3(x, y, z, Color=cm(i, :))
    hold on
end
h(21) = plot3(dyntable.t1right_x{trialNo}(1), dyntable.t1right_y{trialNo}(1), 0, 'o', Color=cm2(5, :), DisplayName='T1 Right');

plot3(smoothdata(dyntable.t2right_x{trialNo}), smoothdata(dyntable.t2right_y{trialNo}), z, '-k');
hold on
plot3(dyntable.t2right_x{trialNo}(flytable.frameofStimStart(trialNo)), dyntable.t2right_y{trialNo}(flytable.frameofStimStart(trialNo)), flytable.frameofStimStart(trialNo), '*k');
hold on
plot3(dyntable.t2right_x{trialNo}(flytable.wingUpFrame(trialNo)), dyntable.t2right_y{trialNo}(flytable.wingUpFrame(trialNo)), flytable.wingUpFrame(trialNo), '*r');
hold on
plot3(dyntable.t2right_x{trialNo}(flytable.jumpStart(trialNo)), dyntable.t2right_y{trialNo}(flytable.jumpStart(trialNo)), flytable.jumpStart(trialNo), '*g');
hold on
plot3(dyntable.t2right_x{trialNo}(flytable.legPushFrame(trialNo)), dyntable.t2right_y{trialNo}(flytable.legPushFrame(trialNo)), flytable.legPushFrame(trialNo), '*b');
hold on
plot3(dyntable.t2right_x{trialNo}(flytable.frameofTakeoff(trialNo)), dyntable.t2right_y{trialNo}(flytable.frameofTakeoff(trialNo)), flytable.frameofTakeoff(trialNo), '*k');
hold on

for i = 1:10
    adjLength = length(regionCell{i});
    x = (dyntable.t2right_x{trialNo}.*regionCell{i}');
    y = (dyntable.t2right_y{trialNo}.*regionCell{i}');
    z = 1:length(x);
    cm = hsv(10);
    plot3(x, y, z, Color=cm(i, :))
    hold on
end
h(22) = plot3(dyntable.t2right_x{trialNo}(1), dyntable.t2right_y{trialNo}(1), 0, 'o', Color=cm2(6, :), DisplayName='T2 Right');

plot3(smoothdata(dyntable.t3right_x{trialNo}), smoothdata(dyntable.t3right_y{trialNo}), z, '-k');
hold on
plot3(dyntable.t3right_x{trialNo}(flytable.frameofStimStart(trialNo)), dyntable.t3right_y{trialNo}(flytable.frameofStimStart(trialNo)), flytable.frameofStimStart(trialNo), '*k');
hold on
plot3(dyntable.t3right_x{trialNo}(flytable.wingUpFrame(trialNo)), dyntable.t3right_y{trialNo}(flytable.wingUpFrame(trialNo)), flytable.wingUpFrame(trialNo), '*r');
hold on
plot3(dyntable.t3right_x{trialNo}(flytable.jumpStart(trialNo)), dyntable.t3right_y{trialNo}(flytable.jumpStart(trialNo)), flytable.jumpStart(trialNo), '*g');
hold on
plot3(dyntable.t3right_x{trialNo}(flytable.legPushFrame(trialNo)), dyntable.t3right_y{trialNo}(flytable.legPushFrame(trialNo)), flytable.legPushFrame(trialNo), '*b');
hold on
plot3(dyntable.t3right_x{trialNo}(flytable.frameofTakeoff(trialNo)), dyntable.t3right_y{trialNo}(flytable.frameofTakeoff(trialNo)), flytable.frameofTakeoff(trialNo), '*k');
hold on

for i = 1:10
    adjLength = length(regionCell{i});
    x = (dyntable.t3right_x{trialNo}.*regionCell{i}');
    y = (dyntable.t3right_y{trialNo}.*regionCell{i}');
    z = 1:length(x);
    cm = hsv(10);
    plot3(x, y, z, Color=cm(i, :))
    hold on
end
h(23) = plot3(dyntable.t3right_x{trialNo}(1), dyntable.t3right_y{trialNo}(1), 0, 'o', Color=cm2(7, :), DisplayName='T3 Right');

legend(h(1:end))