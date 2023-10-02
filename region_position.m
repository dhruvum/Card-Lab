localPath = 'C:\Users\Dhruvum Bajpai\Desktop\Computational Project\Saved_Maps\3\';
%0.4 - 50
%0.6 - 26
%1.2 - 10
sigma = 0.6;
plot_row = 2;
plot_col = 13;
plot_num = 24;
load([localPath 'regionValue_by_trial_' num2str(sigma) '.mat']);
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

min_frames = 2;     %Set minimum number of frames for each trial
max_frames = 1000000;

trials = trial_length>min_frames & trial_length<max_frames;
trial_length_adj = trial_length(trials);
trial_regions_adj = trial_regions(trials);
region_order_adj = region_order(trials);
region_count_adj = region_count(trials);

zero_limit = 1;     %How long a dwell of 0s needs to be before considering a new region

upd_region_list = [];
for trial = 1:length(trial_length_adj)      %num trials
    regions = region_order_adj{trial};
    region_lengths = region_count_adj{trial};
    upd_regions = region_order_adj{trial};
    region_list = '';
    prior_region = regions{1};
    for i = 1:length(region_lengths)        %num regions in trial
        if (regions{i} == 0) && (i>1) && (region_lengths{i}<zero_limit)
            for j = 1:region_lengths{i}
                region_list = region_list + string(prior_region);
            end
            udp_regions{i} = prior_region;
        else
            for j = 1:region_lengths{i}
                region_list = region_list + string(regions{i});
            end
            prior_region = regions{i};
        end
    end
    upd_region_list = [upd_region_list; region_list];
end

%% Single-region histograms
roi = '0';     %(roi = region of interest)

reg_position = [];
for trial = 1:length(upd_region_list)
    len = length(upd_region_list{trial});
    idx = strfind(upd_region_list{trial}, roi);
    position = idx/len;
    reg_position = [reg_position, position];
end
histogram(reg_position);

%% All region histograms (different y-axis)
for roi_count = 1:plot_num
    roi = string(roi_count);
    reg_position = [];
    for trial = 1:length(upd_region_list)
        len = length(upd_region_list{trial});
        idx = strfind(upd_region_list{trial}, roi);
        position = idx/len;
        reg_position = [reg_position, position];
    end

    subplot(plot_row, plot_col, roi_count);
    histogram(reg_position);
    title(roi)
end

%% All region histograms (same y-axis)
for roi_count = 1:plot_num
    roi = string(roi_count);
    reg_position = [];
    for trial = 1:length(upd_region_list)
        len = length(upd_region_list{trial});
        idx = strfind(upd_region_list{trial}, roi);
        position = idx/len;
        reg_position = [reg_position, position];
    end
    ax(roi_count) = subplot(plot_row, plot_col, roi_count);
    histogram(reg_position);
    title(roi)
end
linkaxes(ax, 'y')

%% All region histograms (combined)
for roi_count = 1:plot_num
    roi = string(roi_count);
    reg_position = [];
    for trial = 1:length(upd_region_list)
        len = length(upd_region_list{trial});
        idx = strfind(upd_region_list{trial}, roi);
        position = idx/len;
        reg_position = [reg_position, position];
    end
    histogram(reg_position);
    hold on
end
hold off

%% All region histograms (normalized/probability density)
for roi_count = 1:plot_num
    roi = string(roi_count);
    reg_position = [];
    for trial = 1:length(upd_region_list)
        len = length(upd_region_list{trial});
        idx = strfind(upd_region_list{trial}, roi);
        position = idx/len;
        reg_position = [reg_position, position];
    end
    ax(roi_count) = subplot(plot_row, plot_col, roi_count);
    histogram(reg_position, 'Normalization','probability');
    title(roi)
end
linkaxes(ax, 'y')