filePath='C:\Users\Dhruvum Bajpai\Desktop\Computational Project'; %change this to the file path you want
load([filePath filesep 'flytable.mat'])
load([filePath filesep 'dyntable.mat'])
%%
stimType = "loom_10to180_lv40_blackonwhite.mat";
stimBool = flytable.stimProtocol == stimType;

window_filter = logical(~isnan(flytable.frameofStimStart) .* ~isnan(flytable.legPushFrame) .* ~isnan(flytable.frameofTakeoff) .* (flytable.stimLength==457));
%window_filter = logical(~isnan(flytable.frameofStimStart) .* ~isnan(flytable.legPushFrame) .* ~isnan(flytable.frameofTakeoff)); %Both Long and Short mode escapes have trackable leg-push
flytable_window = flytable(window_filter, :);
dyntable_window = dyntable(window_filter, :);

escape_bool = flytable_window.takeoffTypes == 1;
flytableLong = flytable_window(escape_bool, :);
dyntableLong = dyntable_window(escape_bool, :);

flytableShort = flytable_window(~escape_bool, :);
dyntableShort = dyntable_window(~escape_bool, :);

stimPlot = flytable_window.stimTheta_frms{1};
stimLength = length(stimPlot);
%% Histogram
window = 15;   %15

head_vel_long = nan(length(flytableLong.trial_list), 10000);
for i = 1:length(flytableLong.trial_list)
    frameofStimStart = flytableLong.frameofStimStart(i);
    legPushFrame = flytableLong.legPushFrame(i);
    if length(dyntableLong.headDist{i}) >= legPushFrame
        trial = dyntableLong.headDist{i}(frameofStimStart:legPushFrame);
        padding = 10000 - length(trial);
        head_vel_long(i, :) = [trial; nan(padding, 1)];
    end
end
head_vel_long_mean = mean(head_vel_long, "omitnan");

head_vel_short = nan(length(flytableShort.trial_list), 10000);
for i = 1:length(flytableShort.trial_list)
    frameofStimStart = flytableShort.frameofStimStart(i);
    legPushFrame = flytableShort.legPushFrame(i);
    if length(dyntableShort.headDist{i}) >= legPushFrame
        trial = dyntableShort.headDist{i}(frameofStimStart:legPushFrame);
        padding = 10000 - length(trial);
        head_vel_short(i, :) = [trial; nan(padding, 1)];
    end
end
head_vel_short_mean = mean(head_vel_short, "omitnan");
ax(1) = subplot(2, 4, 1);
plot(movmean(head_vel_long_mean, window), 'r')
hold on
plot(movmean(head_vel_short_mean, window), 'b')
hold on
plot(stimPlot, 'k', 'LineWidth', 2)
xline(stimLength, 'k', 'LineWidth', 2)
title('Head')


centre_vel_long = nan(length(flytableLong.trial_list), 10000);
for i = 1:length(flytableLong.trial_list)
    frameofStimStart = flytableLong.frameofStimStart(i);
    legPushFrame = flytableLong.legPushFrame(i);
    if length(dyntableLong.centreDist{i}) >= legPushFrame
        trial = dyntableLong.centreDist{i}(frameofStimStart:legPushFrame);
        padding = 10000 - length(trial);
        centre_vel_long(i, :) = [trial; nan(padding, 1)];
    end
end
centre_vel_long_mean = mean(centre_vel_long, "omitnan");

centre_vel_short = nan(length(flytableShort.trial_list), 10000);
for i = 1:length(flytableShort.trial_list)
    frameofStimStart = flytableShort.frameofStimStart(i);
    legPushFrame = flytableShort.legPushFrame(i);
    if length(dyntableShort.centreDist{i}) >= legPushFrame
        trial = dyntableShort.centreDist{i}(frameofStimStart:legPushFrame);
        padding = 10000 - length(trial);
        centre_vel_short(i, :) = [trial; nan(padding, 1)];
    end
end
centre_vel_short_mean = mean(centre_vel_short, "omitnan");
ax(2) = subplot(2, 4, 2);
plot(movmean(centre_vel_long_mean, window), 'r')
hold on
plot(movmean(centre_vel_short_mean, window), 'b')
hold on
plot(stimPlot, 'k', 'LineWidth', 2)
xline(stimLength, 'k', 'LineWidth', 2)
title('Centre')


t1left_vel_long = nan(length(flytableLong.trial_list), 10000);
for i = 1:length(flytableLong.trial_list)
    frameofStimStart = flytableLong.frameofStimStart(i);
    legPushFrame = flytableLong.legPushFrame(i);
    if length(dyntableLong.t1leftDist{i}) >= legPushFrame
        trial = dyntableLong.t1leftDist{i}(frameofStimStart:legPushFrame);
        padding = 10000 - length(trial);
        t1left_vel_long(i, :) = [trial; nan(padding, 1)];
    end
end
t1left_vel_long_mean = mean(t1left_vel_long, "omitnan");

t1left_vel_short = nan(length(flytableShort.trial_list), 10000);
for i = 1:length(flytableShort.trial_list)
    frameofStimStart = flytableShort.frameofStimStart(i);
    legPushFrame = flytableShort.legPushFrame(i);
    if length(dyntableShort.t1leftDist{i}) >= legPushFrame
        trial = dyntableShort.t1leftDist{i}(frameofStimStart:legPushFrame);
        padding = 10000 - length(trial);
        t1left_vel_short(i, :) = [trial; nan(padding, 1)];
    end
end
t1left_vel_short_mean = mean(t1left_vel_short, "omitnan");
ax(3) = subplot(2, 4, 3);
plot(movmean(t1left_vel_long_mean, window), 'r')
hold on
plot(movmean(t1left_vel_short_mean, window), 'b')
hold on
plot(stimPlot, 'k', 'LineWidth', 2)
xline(stimLength, 'k', 'LineWidth', 2)
title('T1 Left')


t1right_vel_long = nan(length(flytableLong.trial_list), 10000);
for i = 1:length(flytableLong.trial_list)
    frameofStimStart = flytableLong.frameofStimStart(i);
    legPushFrame = flytableLong.legPushFrame(i);
    if length(dyntableLong.t1rightDist{i}) >= legPushFrame
        trial = dyntableLong.t1rightDist{i}(frameofStimStart:legPushFrame);
        padding = 10000 - length(trial);
        t1right_vel_long(i, :) = [trial; nan(padding, 1)];
    end
end
t1right_vel_long_mean = mean(t1right_vel_long, "omitnan");

t1right_vel_short = nan(length(flytableShort.trial_list), 10000);
for i = 1:length(flytableShort.trial_list)
    frameofStimStart = flytableShort.frameofStimStart(i);
    legPushFrame = flytableShort.legPushFrame(i);
    if length(dyntableShort.t1rightDist{i}) >= legPushFrame
        trial = dyntableShort.t1rightDist{i}(frameofStimStart:legPushFrame);
        padding = 10000 - length(trial);
        t1right_vel_short(i, :) = [trial; nan(padding, 1)];
    end
end
t1right_vel_short_mean = mean(t1right_vel_short, "omitnan");
ax(4) = subplot(2, 4, 4);
plot(movmean(t1right_vel_long_mean, window), 'r')
hold on
plot(movmean(t1right_vel_short_mean, window), 'b')
hold on
plot(stimPlot, 'k', 'LineWidth', 2)
xline(stimLength, 'k', 'LineWidth', 2)
title('T1 Right')


t2left_vel_long = nan(length(flytableLong.trial_list), 10000);
for i = 1:length(flytableLong.trial_list)
    frameofStimStart = flytableLong.frameofStimStart(i);
    legPushFrame = flytableLong.legPushFrame(i);
    if length(dyntableLong.t2leftDist{i}) >= legPushFrame
        trial = dyntableLong.t2leftDist{i}(frameofStimStart:legPushFrame);
        padding = 10000 - length(trial);
        t2left_vel_long(i, :) = [trial; nan(padding, 1)];
    end
end
t2left_vel_long_mean = mean(t2left_vel_long, "omitnan");

t2left_vel_short = nan(length(flytableShort.trial_list), 10000);
for i = 1:length(flytableShort.trial_list)
    frameofStimStart = flytableShort.frameofStimStart(i);
    legPushFrame = flytableShort.legPushFrame(i);
    if length(dyntableShort.t2leftDist{i}) >= legPushFrame
        trial = dyntableShort.t2leftDist{i}(frameofStimStart:legPushFrame);
        padding = 10000 - length(trial);
        t2left_vel_short(i, :) = [trial; nan(padding, 1)];
    end
end
t2left_vel_short_mean = mean(t2left_vel_short, "omitnan");
ax(5) = subplot(2, 4, 5);
plot(movmean(t2left_vel_long_mean, window), 'r')
hold on
plot(movmean(t2left_vel_short_mean, window), 'b')
hold on
plot(stimPlot, 'k', 'LineWidth', 2)
xline(stimLength, 'k', 'LineWidth', 2)
title('T2 Left')


t2right_vel_long = nan(length(flytableLong.trial_list), 10000);
for i = 1:length(flytableLong.trial_list)
    frameofStimStart = flytableLong.frameofStimStart(i);
    legPushFrame = flytableLong.legPushFrame(i);
    if length(dyntableLong.t2rightDist{i}) >= legPushFrame
        trial = dyntableLong.t2rightDist{i}(frameofStimStart:legPushFrame);
        padding = 10000 - length(trial);
        t2right_vel_long(i, :) = [trial; nan(padding, 1)];
    end
end
t2right_vel_long_mean = mean(t2right_vel_long, "omitnan");

t2right_vel_short = nan(length(flytableShort.trial_list), 10000);
for i = 1:length(flytableShort.trial_list)
    frameofStimStart = flytableShort.frameofStimStart(i);
    legPushFrame = flytableShort.legPushFrame(i);
    if length(dyntableShort.t2rightDist{i}) >= legPushFrame
        trial = dyntableShort.t2rightDist{i}(frameofStimStart:legPushFrame);
        padding = 10000 - length(trial);
        t2right_vel_short(i, :) = [trial; nan(padding, 1)];
    end
end
t2right_vel_short_mean = mean(t2right_vel_short, "omitnan");
ax(6) = subplot(2, 4, 6);
plot(movmean(t2right_vel_long_mean, window), 'r')
hold on
plot(movmean(t2right_vel_short_mean, window), 'b')
hold on
plot(stimPlot, 'k', 'LineWidth', 2)
xline(stimLength, 'k', 'LineWidth', 2)
title('T2 Right')


t3left_vel_long = nan(length(flytableLong.trial_list), 10000);
for i = 1:length(flytableLong.trial_list)
    frameofStimStart = flytableLong.frameofStimStart(i);
    legPushFrame = flytableLong.legPushFrame(i);
    if length(dyntableLong.t3leftDist{i}) >= legPushFrame
        trial = dyntableLong.t3leftDist{i}(frameofStimStart:legPushFrame);
        padding = 10000 - length(trial);
        t3left_vel_long(i, :) = [trial; nan(padding, 1)];
    end
end
t3left_vel_long_mean = mean(t3left_vel_long, "omitnan");

t3left_vel_short = nan(length(flytableShort.trial_list), 10000);
for i = 1:length(flytableShort.trial_list)
    frameofStimStart = flytableShort.frameofStimStart(i);
    legPushFrame = flytableShort.legPushFrame(i);
    if length(dyntableShort.t3leftDist{i}) >= legPushFrame
        trial = dyntableShort.t3leftDist{i}(frameofStimStart:legPushFrame);
        padding = 10000 - length(trial);
        t3left_vel_short(i, :) = [trial; nan(padding, 1)];
    end
end
t3left_vel_short_mean = mean(t3left_vel_short, "omitnan");
ax(7) = subplot(2, 4, 7);
plot(movmean(t3left_vel_long_mean, window), 'r')
hold on
plot(movmean(t3left_vel_short_mean, window), 'b')
hold on
plot(stimPlot, 'k', 'LineWidth', 2)
xline(stimLength, 'k', 'LineWidth', 2)
title('T3 Left')


t3right_vel_long = nan(length(flytableLong.trial_list), 10000);
for i = 1:length(flytableLong.trial_list)
    frameofStimStart = flytableLong.frameofStimStart(i);
    legPushFrame = flytableLong.legPushFrame(i);
    if length(dyntableLong.t3rightDist{i}) >= legPushFrame
        trial = dyntableLong.t3rightDist{i}(frameofStimStart:legPushFrame);
        padding = 10000 - length(trial);
        t3right_vel_long(i, :) = [trial; nan(padding, 1)];
    end
end
t3right_vel_long_mean = mean(t2right_vel_long, "omitnan");

t3right_vel_short = nan(length(flytableShort.trial_list), 10000);
for i = 1:length(flytableShort.trial_list)
    frameofStimStart = flytableShort.frameofStimStart(i);
    legPushFrame = flytableShort.legPushFrame(i);
    if length(dyntableShort.t3rightDist{i}) >= legPushFrame
        trial = dyntableShort.t3rightDist{i}(frameofStimStart:legPushFrame);
        padding = 10000 - length(trial);
        t3right_vel_short(i, :) = [trial; nan(padding, 1)];
    end
end
t3right_vel_short_mean = mean(t3right_vel_short, "omitnan");
ax(8) = subplot(2, 4, 8);
plot(movmean(t3right_vel_long_mean, window), 'r')
hold on
plot(movmean(t3right_vel_short_mean, window), 'b')
hold on
plot(stimPlot, 'k', 'LineWidth', 2)
xline(stimLength, 'k', 'LineWidth', 2)
title('T3 Right')