localPath = 'C:\Users\Dhruvum Bajpai\Desktop\Computational Project\Saved_Maps\3\';
%%
%0.4 - 50
%0.6 - 26
%1.2 - 10
sigma = 0.6;
plot_row = 2;
plot_col = 13;
plot_num = 24;
load([localPath 'regionValue_by_trial_' num2str(sigma) '.mat'])
%regionValue_by_trial = ensembleCell;
%%
trial_regions = regionValue_by_trial(1, :);
idx_switch = regionValue_by_trial(2, :);
region_order = regionValue_by_trial(3, :);
region_count = regionValue_by_trial(4, :);

trial_length = zeros(1, length(trial_regions));
region_switch = zeros(1, length(trial_regions));
for i = 1:length(trial_regions)
    trial_length(i) = length(trial_regions{i});   
    region_switch(i) = length(region_count{i});
end

min_frames = 2; %Set minimum number of frames for each trial
max_frames = 1000000;

trials = trial_length>min_frames & trial_length<max_frames;
trial_length_adj = trial_length(trials);
trial_regions_adj = trial_regions(trials);
region_order_adj = region_order(trials);
region_count_adj = region_count(trials);

zero_limit = 1;     %How long a dwell of 0s needs to be before considering a new region
region_list = [];
for trial = 1:length(region_order_adj)
    regions = region_order_adj{trial};
    region_lengths = region_count_adj{trial};
    num_regions = length(regions);
    for i = 1:num_regions
        curr_region = regions{i};
        curr_region_length = region_lengths{i};
        if curr_region ~= 0     %0 is an unassigned action
            new_entry = [curr_region, curr_region_length];
            region_list = [region_list; new_entry];
        else
            if (region_lengths{i}<zero_limit) && (i>1)
                region_list(end, 2) = region_list(end, 2) + curr_region_length;
            end
        end
    end
end

%% Single region histogram
region_hist = 4;

filter = region_list(:, 1) == region_hist;
freq = region_list(filter, 2);

histogram(freq);
hist_title = ['Histogram of Region ' num2str(region_hist) ' Dwell lengths'];
title(hist_title)
xlabel('Length of dwell')
ylabel('Frequency')

%% All region histograms (same x-axis)
for region_hist = 1:plot_num
    filter = region_list(:, 1) == region_hist;
    freq = region_list(filter, 2);

    ax(region_hist) = subplot(plot_row, plot_col, region_hist);
    histogram(freq);
    title(num2str(region_hist))
end
linkaxes(ax, 'x')

%% All region histograms (different x-axis)
for region_hist = 1:plot_num
    filter = region_list(:, 1) == region_hist;
    freq = region_list(filter, 2);

    subplot(plot_row, plot_col, region_hist);
    histogram(freq);
    title(num2str(region_hist))
end