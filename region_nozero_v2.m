sigma = 0.6;
localPath = 'C:\Users\Dhruvum Bajpai\Desktop\Computational Project\';
load([localPath 'regionValue_by_trial_' num2str(sigma) '_table.mat'])
%% Make non-zero table

trial_regions = regionValue_by_trial.trial_regionValues;
all_trials_idx_switch = regionValue_by_trial.idx_switch;
region_order_temp = regionValue_by_trial.region_order;
region_count = regionValue_by_trial.region_count;

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
roi = 1;

roi_total = 0;
for trial = 1:length(regionValue_by_trial_nozero.trial_no)  %Finds number of instances of the region across all trials
    roi_bool = regionValue_by_trial_nozero.region_order{trial} == roi;
    roi_total = roi_total + sum(roi_bool);
end
roi_x = cell(roi_total, 1);
roi_y = cell(roi_total, 1);


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
                trial_x = NaN;
                trial_y = NaN;
            elseif roi_end(i) > length(dyntable.head_x{trial})
                trial_x = dyntable.t1left_x{trial}(roi_start(i) : end) - dyntable.t1left_x{trial}(roi_start(i));
                trial_y = dyntable.t1left_y{trial}(roi_start(i) : end) - dyntable.t1left_y{trial}(roi_start(i));
            else
                trial_x = dyntable.t1left_x{trial}(roi_start(i) : roi_end(i)) - dyntable.t1left_x{trial}(roi_start(i));
                trial_y = dyntable.t1left_y{trial}(roi_start(i) : roi_end(i)) - dyntable.t1left_y{trial}(roi_start(i));
            end

            roi_x{roi_count} = trial_x;
            roi_y{roi_count} = trial_y;
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
random_trials = randi(length(roi_x), 500, 1);

for j = 1:length(random_trials)
    z = 1:length(roi_x{random_trials(j)});
    plot3(roi_x{random_trials(j)}, roi_y{random_trials(j)}, z)
    hold on
end