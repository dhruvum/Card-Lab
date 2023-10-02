%% This script separates the region values based on trials. It then counts transitions between regions, ignoring 0 values. If two different regions flank a 0 region/reasonably small dwell (whose max length can be prescribed), it will be counted as a transition between the flanking regions.
%It creates heatmaps of the region transitions.

localPath = 'C:\Users\Dhruvum Bajpai\Desktop\Computational Project\Saved_Maps\3\';
load([localPath 'regionValue_by_trial_0.6']);

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
%% Doesn't allow for repeats
%Make list of pairs, ignoring intermediate 0s (which mean 'unassigned')
zero_limit = 15; %How many consecutive zero regions can occur before counting new pair
region_pairs = {};
first_region = [];
second_region = [];

for trial_no = 1:length(trial_regions_adj)  %Iterates through all trials
    trial = trial_regions_adj{trial_no};    %Shorthand for current trial's entire region sequence
    
    start = 0;
    for i = 1:length(trial)-1
        if trial(i) ~= 0
            start = i;
            break
        end
    end

    if start == 0   %If all (but the last) regions in the trial are 0, skips to next trial
        region_pairs{end+1} = nan;
        continue
    end
    
    current_region = trial(start);
    zero_count = 0;
    for i = start:length(trial)-1   %Iterates through all regions in trial starting from first non-zero
        if trial(i) ~= trial(i+1)
            if trial(i+1) == 0
                current_region = trial(i);
                zero_count = zero_count+1;

            elseif trial(i) == 0
                if (zero_count < zero_limit) && (current_region ~= trial(i+1))
                    pair = string(current_region) + "/" + string(trial(i+1));
                    region_pairs{end+1} = pair;
                    first_region(end + 1) = current_region;
                    second_region(end + 1) = trial(i+1);
                end
                current_region = trial(i+1);
                zero_count = 0;

            else
                pair = string(trial(i)) + "/" + string(trial(i+1));
                region_pairs{end+1} = pair;
                first_region(end + 1) = current_region;
                second_region(end + 1) = trial(i+1);
                current_region = trial(i+1);
            end

        elseif trial(i+1) == 0  %If subsequent trials are 0
            zero_count = zero_count+1;

        end
    end
end

first_values = unique(first_region);
second_values = unique(second_region);
cdata = transpose(crosstab(first_region, second_region));
row_sum = sum(cdata);

prob = [];
for i = 1:length(row_sum)
    new_row = cdata(:, i)/row_sum(i);
    prob = [prob, new_row];
end


%h = heatmap(first_values, second_values, cdata, Colormap=flipud(gray));    %raw transitions
h = heatmap(first_values, second_values, prob, Colormap=flipud(gray));   %percentage (Colormap=gray)
h.XLabel = 'First Region';
h.YLabel = 'Second Region';

axp = struct(h);       %you will get a warning, moves x-label to top
axp.Axes.XAxisLocation = 'top';
%% Allows for repeats
%Make list of pairs, ignoring intermediate 0s (which mean 'unassigned')
zero_limit = 15; %How many consecutive zero regions can occur before counting new pair
region_pairs = {};
first_region = [];
second_region = [];

for trial_no = 1:length(trial_regions_adj)  %Iterates through all trials
    trial = trial_regions_adj{trial_no};    %Shorthand for current trial's entire region sequence
    
    start = 0;
    for i = 1:length(trial)-1
        if trial(i) ~= 0
            start = i;
            break
        end
    end

    if start == 0   %If all (but the last) regions in the trial are 0, skips to next trial
        region_pairs{end+1} = nan;
        continue
    end
    
    current_region = trial(start);
    zero_count = 0;
    for i = start:length(trial)-1   %Iterates through all regions in trial starting from first non-zero
        if trial(i) ~= trial(i+1)
            if trial(i+1) == 0
                current_region = trial(i);
                zero_count = zero_count+1;

            elseif trial(i) == 0
                if zero_count < zero_limit
                    pair = string(current_region) + "/" + string(trial(i+1));
                    region_pairs{end+1} = pair;
                    first_region(end + 1) = current_region;
                    second_region(end + 1) = trial(i+1);
                end
                current_region = trial(i+1);
                zero_count = 0;

            else
                pair = string(trial(i)) + "/" + string(trial(i+1));
                region_pairs{end+1} = pair;
                first_region(end + 1) = current_region;
                second_region(end + 1) = trial(i+1);
                current_region = trial(i+1);
            end

        elseif trial(i+1) == 0  %If subsequent trials are 0
            zero_count = zero_count+1;

        else    %Repeat of non-zero value
            pair = string(trial(i)) + "/" + string(trial(i+1));
                region_pairs{end+1} = pair;
                first_region(end + 1) = current_region;
                second_region(end + 1) = trial(i+1);
        end
    end
end

first_values = unique(first_region);
second_values = unique(second_region);
cdata = transpose(crosstab(first_region, second_region));
row_sum = sum(cdata);

prob = [];
for i = 1:length(row_sum)
    new_row = cdata(:, i)/row_sum(i);
    prob = [prob, new_row];
end


%h = heatmap(first_values, second_values, cdata, Colormap=flipud(gray));    %raw transitions
h = heatmap(first_values, second_values, prob, Colormap=flipud(gray));   %percentage
h.XLabel = 'First Region';
h.YLabel = 'Second Region';

axp = struct(h);       %you will get a warning, moves x-label to top
axp.Axes.XAxisLocation = 'top';
%% Histogram
%Converting cell array of pairs to string array
region_pairs_str = string(region_pairs);

[a, ~, c] = unique(region_pairs_str);
d = hist(c,length(a));

%Filter results based on occurence
min_occurrence = 30;
cat_adj = d>=min_occurrence;

bar(categorical(a(cat_adj)), d(cat_adj))