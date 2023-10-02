%% Taking the Angle of the Stimulus with respect to the fly into account
filePath='C:\Users\Dhruvum Bajpai\Desktop\Computational Project'; %change this to the file path you want
load([filePath filesep 'flytable.mat'])
load([filePath filesep 'dyntable.mat'])
%%
stimType = "loom_10to180_lv40_blackonwhite.mat";
stimBool = flytable.stimProtocol == stimType;

window_filter = logical(~isnan(flytable.frameofStimStart) .* ~isnan(flytable.legPushFrame) .* ~isnan(flytable.frameofTakeoff)); %Both Long and Short mode escapes have trackable leg-push
flytable_window = flytable(window_filter, :);
dyntable_window = dyntable(window_filter, :);

escape_bool = flytable_window.takeoffTypes == 1;
flytableLong = flytable_window(escape_bool, :);
dyntableLong = dyntable_window(escape_bool, :);

flytableShort = flytable_window(~escape_bool, :);
dyntableShort = dyntable_window(~escape_bool, :);

stimPlot = flytable_window.stimTheta_frms{1};
stimLength = length(stimPlot);
%% All Trials
random_trials = randi(length(flytable_window.trial_list), 500, 1);

for i = 1:length(random_trials)
    trial = random_trials(i);
    frameofStimStart = flytable_window.frameofStimStart(trial);
    legPush = flytable_window.legPushFrame(trial);
    window = (frameofStimStart):legPush;
    
    if length(dyntable_window.headDist{trial}) > legPush && legPush > frameofStimStart
        head_x = dyntable_window.headDist{trial}(window);
        subplot(2, 4, 1)
        plot(1:length(head_x), head_x)
        hold on
        title('Head')

        t1left_x = dyntable_window.t1leftDist{trial}(window);
        subplot(2, 4, 2)
        plot(1:length(head_x), t1left_x)
        hold on
        title('T1 Left')
        
        t2left_x = dyntable_window.t2leftDist{trial}(window);
        subplot(2, 4, 3)
        plot(1:length(head_x), t2left_x)
        hold on
        title('T2 Left')

        t3left_x = dyntable_window.t3leftDist{trial}(window);
        subplot(2, 4, 4)
        plot(1:length(head_x), t3left_x)
        hold on
        title('T3 Left')

        centre_x = dyntable_window.centreDist{trial}(window);
        subplot(2, 4, 5)
        plot(1:length(head_x), centre_x)
        hold on
        title('Centre')

        t1right_x = dyntable_window.t1rightDist{trial}(window);
        subplot(2, 4, 6)
        plot(1:length(head_x), t1right_x)
        hold on
        title('T1 Right')
        
        t2right_x = dyntable_window.t2rightDist{trial}(window);
        subplot(2, 4, 7)
        plot(1:length(head_x), t2right_x)
        hold on
        title('T2 Right')

        t3right_x = dyntable_window.t3rightDist{trial}(window);
        subplot(2, 4, 8)
        plot(1:length(head_x), t3right_x)
        hold on
        title('T3 Right')
    end
end

%% Split Short and Long Mode
beforeStim = 120;
%Long
random_trials = randi(length(flytableLong.trial_list), 10000, 1);
for i = 1:length(random_trials)
    trial = random_trials(i);
    if flytableLong.frameofStimStart(trial) >= beforeStim
        frameofStimStart = flytableLong.frameofStimStart(trial) - beforeStim;
    else
        continue
    end
    legPush = flytableLong.legPushFrame(trial);
    window = (frameofStimStart):legPush;
    
    if length(dyntableLong.headDist{trial}) > legPush && legPush > frameofStimStart
        head_x = dyntableLong.headDist{trial}(window);
        subplot(2, 4, 1)
        ax(1) = plot(1:length(head_x), head_x, 'r');
        hold on
        title('Head')

        t1left_x = dyntableLong.t1leftDist{trial}(window);
        subplot(2, 4, 2)
        ax(2) = plot(1:length(head_x), t1left_x, 'r');
        hold on
        title('T1 Left')
        
        t2left_x = dyntableLong.t2leftDist{trial}(window);
        subplot(2, 4, 3)
        ax(3) = plot(1:length(head_x), t2left_x, 'r');
        hold on
        title('T2 Left')

        t3left_x = dyntableLong.t3leftDist{trial}(window);
        subplot(2, 4, 4)
        ax(4) = plot(1:length(head_x), t3left_x, 'r');
        hold on
        title('T3 Left')

        centre_x = dyntableLong.centreDist{trial}(window);
        subplot(2, 4, 5)
        ax(6) = plot(1:length(head_x), centre_x, 'r');
        hold on
        title('Centre')

        t1right_x = dyntableLong.t1rightDist{trial}(window);
        subplot(2, 4, 6)
        ax(6) = plot(1:length(head_x), t1right_x, 'r');
        hold on
        title('T1 Right')
        
        t2right_x = dyntableLong.t2rightDist{trial}(window);
        subplot(2, 4, 7)
        ax(7) = plot(1:length(head_x), t2right_x, 'r');
        hold on
        title('T2 Right')

        t3right_x = dyntableLong.t3rightDist{trial}(window);
        subplot(2, 4, 8)
        ax(8) = plot(1:length(head_x), t3right_x, 'r');
        hold on
        title('T3 Right')
    end
end

%Short
random_trials = randi(length(flytableShort.trial_list), 10000, 1);
for i = 1:length(random_trials)
    trial = random_trials(i);
    if flytableShort.frameofStimStart(trial) >= beforeStim
        frameofStimStart = flytableShort.frameofStimStart(trial) - beforeStim;
    else
        continue
    end
    legPush = flytableShort.legPushFrame(trial);
    window = (frameofStimStart):legPush;
    
    if length(dyntableShort.headDist{trial}) > legPush && legPush > frameofStimStart
        head_x = dyntableShort.headDist{trial}(window);
        subplot(2, 4, 1)
        ax(9) = plot(1:length(head_x), head_x, 'b');
        hold on
        title('Head')

        t1left_x = dyntableShort.t1leftDist{trial}(window);
        subplot(2, 4, 2)
        ax(10) = plot(1:length(head_x), t1left_x, 'b');
        hold on
        title('T1 Left')
        
        t2left_x = dyntableShort.t2leftDist{trial}(window);
        subplot(2, 4, 3)
        ax(11) = plot(1:length(head_x), t2left_x, 'b');
        hold on
        title('T2 Left')

        t3left_x = dyntableShort.t3leftDist{trial}(window);
        subplot(2, 4, 4)
        ax(12) = plot(1:length(head_x), t3left_x, 'b');
        hold on
        title('T3 Left')

        centre_x = dyntableShort.centreDist{trial}(window);
        subplot(2, 4, 5)
        ax(13) = plot(1:length(head_x), centre_x, 'b');
        hold on
        title('Centre')

        t1right_x = dyntableShort.t1rightDist{trial}(window);
        subplot(2, 4, 6)
        ax(14) = plot(1:length(head_x), t1right_x, 'b');
        hold on
        title('T1 Right')
        
        t2right_x = dyntableShort.t2rightDist{trial}(window);
        subplot(2, 4, 7)
        ax(15) = plot(1:length(head_x), t2right_x, 'b');
        hold on
        title('T2 Right')

        t3right_x = dyntableShort.t3rightDist{trial}(window);
        subplot(2, 4, 8)
        ax(16) = plot(1:length(head_x), t3right_x, 'b');
        hold on
        title('T3 Right')
    end
end