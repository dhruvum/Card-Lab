%This is effectively 'region_nozero_v3'
sigma = 0.6;
localPath = 'C:\Users\Dhruvum Bajpai\Desktop\Computational Project\';
load([localPath 'regionValue_by_trial_' num2str(sigma) '_table.mat'])
%% Make non-zero table

trial_regions = regionValue_by_trial_table.trial_regionValues;
all_trials_idx_switch = regionValue_by_trial_table.idx_switch;
region_order_temp = regionValue_by_trial_table.region_order;
region_count = regionValue_by_trial_table .region_count;

trial_length = zeros(1, length(trial_regions)); %Checks to see if the trial is within reasonable bounds for analysis
for i = 1:length(trial_regions)
    trial_length(i) = length(trial_regions{i});   
end

min_frames = 15; %Set minimum number of frames for each trial
max_frames = 1000000;

trial_filter = trial_length>min_frames & trial_length<max_frames;
trial_regions_adj = trial_regions(trial_filter);
region_order_adj = region_order_temp(trial_filter);
region_count_adj = region_count(trial_filter);
all_trials_idx_switch_adj = all_trials_idx_switch(trial_filter);

trial_no = 1:length(trial_regions);
trial_no = trial_no(trial_filter)';


zero_limit = 15;     %How long a dwell of 0s needs to be before considering a new region

region_order = cell(length(trial_regions_adj), 1);
idx_switch = cell(length(trial_regions_adj), 1);
region_length = cell(length(trial_regions_adj), 1);

for trial = 1:length(trial_regions_adj) %Iterates over all trials
    region_order_temp = [];
    idx_switch_temp = [];
    region_length_temp = [];
    trial_region_length = region_count_adj{trial};
    trial_region_order = region_order_adj{trial};
    trial_idx_switch = all_trials_idx_switch_adj{trial};

    for i = 1:length(trial_region_order)   %Iterates over # of specific region dwells
        curr_region = trial_region_order(i);
        curr_region_length = trial_region_length(i);

        if i==1     %0 is an unassigned action
            region_order_temp = curr_region;
            idx_switch_temp = 1;
            region_length_temp = trial_region_length(1);
        elseif curr_region ~= 0

            if curr_region == trial_region_order(i-1)
                region_length_temp(end) = region_length_temp(end) + trial_region_length(i);
            else
                region_order_temp = [region_order_temp, curr_region];
                idx_switch_temp = [idx_switch_temp, trial_idx_switch(i)];
                region_length_temp = [region_length_temp, trial_region_length(i)];
            end

        else

            if (trial_region_length(i)<zero_limit)
                region_length_temp(end) = region_length_temp(end) + curr_region_length;
            else
                region_order_temp = [region_order_temp, curr_region];
                idx_switch_temp = [idx_switch_temp, trial_idx_switch(i)];
                region_length_temp = [region_length_temp, trial_region_length(i)];
            end

        end

    end

    region_order{trial} = region_order_temp;    
    idx_switch{trial} = idx_switch_temp;
    region_length{trial} = region_length_temp;
end
regionValue_by_trial_nozero = table(trial_no, region_order, idx_switch, region_length);
save([localPath 'regionValue_by_trial_'  num2str(sigma) '_nozero.mat'],"regionValue_by_trial_nozero",'-mat');
%%
load([localPath filesep 'flytable.mat'])
load([localPath filesep 'dyntable.mat'])
load([localPath 'regionValue_by_trial_' num2str(sigma) '_nozero.mat'])
%%
roi = 3;

roi_total = 0;
for trial = 1:length(regionValue_by_trial_nozero.trial_no)  %Finds number of instances of the region across all trials
    roi_bool = regionValue_by_trial_nozero.region_order{trial} == roi;
    roi_total = roi_total + sum(roi_bool);
end
roi_x = cell(roi_total, 7);
roi_y = cell(roi_total, 7);


roi_count = 1;
for trial = 1:length(regionValue_by_trial_nozero.trial_no)
    stim_start = flytable.frameofStimStart(trial);
    roi_bool = regionValue_by_trial_nozero.region_order{trial} == roi;
    
    if sum(roi_bool)>0
        roi_idx = regionValue_by_trial_nozero.idx_switch{trial}(roi_bool);
        roi_length = regionValue_by_trial_nozero.region_length{trial}(roi_bool);
    
        roi_start = roi_idx + stim_start;
        roi_end = roi_start + roi_length - 1;
        

        for i = 1:sum(roi_bool) %Assign regions to body parts
            if roi_start(i) > length(dyntable.head_x{trial})
                head_x = NaN;
                head_y = NaN;

                t1left_x = NaN;
                t1left_y = NaN;

                t2left_x = NaN;
                t2left_y = NaN;

                t3left_x = NaN;
                t3left_y = NaN;

                t1right_x = NaN;
                t1right_y = NaN;

                t2right_x = NaN;
                t2right_y = NaN;

                t3right_x = NaN;
                t3right_y = NaN;

            elseif roi_end(i) > length(dyntable.head_x{trial})
                head_x = dyntable.head_x{trial}(roi_start(i) : end) - dyntable.head_x{trial}(roi_start(i));
                head_y = dyntable.head_y{trial}(roi_start(i) : end) - dyntable.head_y{trial}(roi_start(i));

                t1left_x = dyntable.t1left_x{trial}(roi_start(i) : end) - dyntable.t1left_x{trial}(roi_start(i));
                t1left_y = dyntable.t1left_y{trial}(roi_start(i) : end) - dyntable.t1left_y{trial}(roi_start(i));

                t2left_x = dyntable.t2left_x{trial}(roi_start(i) : end) - dyntable.t2left_x{trial}(roi_start(i));
                t2left_y = dyntable.t2left_y{trial}(roi_start(i) : end) - dyntable.t2left_y{trial}(roi_start(i));

                t3left_x = dyntable.t3left_x{trial}(roi_start(i) : end) - dyntable.t3left_x{trial}(roi_start(i));
                t3left_y = dyntable.t3left_y{trial}(roi_start(i) : end) - dyntable.t3left_y{trial}(roi_start(i));

                t1right_x = dyntable.t1right_x{trial}(roi_start(i) : end) - dyntable.t1right_x{trial}(roi_start(i));
                t1right_y = dyntable.t1right_y{trial}(roi_start(i) : end) - dyntable.t1right_y{trial}(roi_start(i));

                t2right_x = dyntable.t2right_x{trial}(roi_start(i) : end) - dyntable.t2right_x{trial}(roi_start(i));
                t2right_y = dyntable.t2right_y{trial}(roi_start(i) : end) - dyntable.t2right_y{trial}(roi_start(i));

                t3right_x = dyntable.t3right_x{trial}(roi_start(i) : end) - dyntable.t3right_x{trial}(roi_start(i));
                t3right_y = dyntable.t3right_y{trial}(roi_start(i) : end) - dyntable.t3right_y{trial}(roi_start(i));
            else

                head_x = dyntable.head_x{trial}(roi_start(i) : roi_end(i)) - dyntable.head_x{trial}(roi_start(i));
                head_y = dyntable.head_y{trial}(roi_start(i) : roi_end(i)) - dyntable.head_y{trial}(roi_start(i));

                t1left_x = dyntable.t1left_x{trial}(roi_start(i) : roi_end(i)) - dyntable.t1left_x{trial}(roi_start(i));
                t1left_y = dyntable.t1left_y{trial}(roi_start(i) : roi_end(i)) - dyntable.t1left_y{trial}(roi_start(i));

                t2left_x = dyntable.t2left_x{trial}(roi_start(i) : roi_end(i)) - dyntable.t2left_x{trial}(roi_start(i));
                t2left_y = dyntable.t2left_y{trial}(roi_start(i) : roi_end(i)) - dyntable.t2left_y{trial}(roi_start(i));

                t3left_x = dyntable.t3left_x{trial}(roi_start(i) : roi_end(i)) - dyntable.t3left_x{trial}(roi_start(i));
                t3left_y = dyntable.t3left_y{trial}(roi_start(i) : roi_end(i)) - dyntable.t3left_y{trial}(roi_start(i));

                t1right_x = dyntable.t1right_x{trial}(roi_start(i) : roi_end(i)) - dyntable.t1right_x{trial}(roi_start(i));
                t1right_y = dyntable.t1right_y{trial}(roi_start(i) : roi_end(i)) - dyntable.t1right_y{trial}(roi_start(i));

                t2right_x = dyntable.t2right_x{trial}(roi_start(i) : roi_end(i)) - dyntable.t2right_x{trial}(roi_start(i));
                t2right_y = dyntable.t2right_y{trial}(roi_start(i) : roi_end(i)) - dyntable.t2right_y{trial}(roi_start(i));

                t3right_x = dyntable.t3right_x{trial}(roi_start(i) : roi_end(i)) - dyntable.t3right_x{trial}(roi_start(i));
                t3right_y = dyntable.t3right_y{trial}(roi_start(i) : roi_end(i)) - dyntable.t3right_y{trial}(roi_start(i));
            end
            roi_x{roi_count, 1} = head_x;
            roi_y{roi_count, 1} = head_y;

            roi_x{roi_count, 2} = t1left_x;
            roi_y{roi_count, 2} = t1left_y;

            roi_x{roi_count, 3} = t2left_x;
            roi_y{roi_count, 3} = t2left_y;

            roi_x{roi_count, 4} = t3left_x;
            roi_y{roi_count, 4} = t3left_y;

            roi_x{roi_count, 5} = t1right_x;
            roi_y{roi_count, 5} = t1right_y;

            roi_x{roi_count, 6} = t2right_x;
            roi_y{roi_count, 6} = t2right_y;

            roi_x{roi_count, 7} = t3right_x;
            roi_y{roi_count, 7} = t3right_y;

            roi_count = roi_count+1;
        end  
    end 
end


%% 2D Graph
random_trials = randi(length(roi_x), 500, 1);

ax(1) = subplot(2, 1, 1);
for j = 1:length(random_trials)
    plot(roi_x{random_trials(j)})
    hold on
end

ax(2) = subplot(2, 1, 2);
for j = 1:length(random_trials)
    plot(roi_y{random_trials(j)})
    hold on
end

%% 3D Graph
random_trials = randi(length(roi_x), 250, 1);

ax(1) = subplot(2, 4, 1);
for j = 1:length(random_trials)
    z = 1:length(roi_x{random_trials(j)});
    plot3(roi_x{random_trials(j), 1}, roi_y{random_trials(j), 1}, z)
    hold on
end
title('Head')

ax(2) = subplot(2, 4, 2);
for j = 1:length(random_trials)
    z = 1:length(roi_x{random_trials(j)});
    plot3(roi_x{random_trials(j), 2}, roi_y{random_trials(j), 2}, z)
    hold on
end
title('T1 Left')

ax(3) = subplot(2, 4, 3);
for j = 1:length(random_trials)
    z = 1:length(roi_x{random_trials(j)});
    plot3(roi_x{random_trials(j), 3}, roi_y{random_trials(j), 3}, z)
    hold on
end
title('T2 Left')

ax(4) = subplot(2, 4, 4);
for j = 1:length(random_trials)
    z = 1:length(roi_x{random_trials(j)});
    plot3(roi_x{random_trials(j), 4}, roi_y{random_trials(j), 4}, z)
    hold on
end
title('T3 Left')

ax(5) = subplot(2, 4, 6);
for j = 1:length(random_trials)
    z = 1:length(roi_x{random_trials(j)});
    plot3(roi_x{random_trials(j), 5}, roi_y{random_trials(j), 5}, z)
    hold on
end
title('T1 Right')

ax(6) = subplot(2, 4, 7);
for j = 1:length(random_trials)
    z = 1:length(roi_x{random_trials(j)});
    plot3(roi_x{random_trials(j), 6}, roi_y{random_trials(j), 6}, z)
    hold on
end
title('T2 Right')

ax(7) = subplot(2, 4, 8);
for j = 1:length(random_trials)
    z = 1:length(roi_x{random_trials(j)});
    plot3(roi_x{random_trials(j), 7}, roi_y{random_trials(j), 7}, z)
    hold on
end
title('T3 Right')

linkaxes(ax, 'xyz')