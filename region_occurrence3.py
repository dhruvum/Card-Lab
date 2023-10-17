import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

#0.4 - 50
#0.6 - 26
#1.2 - 10

flytable = pd.read_pickle(r"C:\Users\Dhruvum Bajpai\Desktop\Computational Project\Ensemble\flytable_ensemble.pkl")

reactLength = 156

#%% Plots length of reactions
flytable_filter = flytable.dropna(subset=['frameofStimStart', 'midEndFrame', 'labels']).reset_index(drop=True)

trial_length = flytable_filter.midEndFrame - flytable_filter.frameofStimStart
flytable_filter['trial_length'] = trial_length
flytable_filter = flytable_filter[~trial_length.isna()].reset_index(drop=True)

flytable_filter = flytable_filter[(flytable_filter.stimProtocol=='loom_10to180_lv40_blackonwhite.mat\n')].reset_index(drop=True)
#flytable_filter = flytable_filter[(flytable_filter.stimProtocol=='loom_10to180_lv40_blackonwhite.mat\n')&(flytable_filter.labels_simp==3)].reset_index(drop=True)
#flytable_filter = flytable_filter[(flytable_filter.stimProtocol=='loom_10to180_lv40_blackonwhite.mat\n')&(flytable_filter.labels_simp==1)].reset_index(drop=True)

#flytable_filter = flytable_filter.iloc[0:20]

#%% Make Matrix of Region occurrence among all Trials
matrix = np.zeros((len(flytable_filter.trial_list), reactLength))
matrix[:] = np.nan

for i in range(len(flytable_filter.trial_list)):
    full_trial = flytable_filter.trial_full[i]
    stimStart = flytable_filter.frameofStimStart[i]
    midEndFrame = flytable_filter.midEndFrame[i]
        
    if (len(full_trial)+stimStart>=midEndFrame) & (midEndFrame>stimStart):
        #sum((len(flytable_filter.trial_full)>=flytable_filter.midEndFrame))
        #sum(flytable_filter.midEndFrame>flytable_filter.frameofStimStart)
        diff = reactLength - flytable_filter.trial_length[i]
        if diff>0:
            matrix[i][diff-1:-1] = full_trial[0:midEndFrame-stimStart]
        else:
            matrix[i] = full_trial[-diff:midEndFrame-stimStart]
            #Remember, trial_full begins assigning regions at the frame of stim start.
         
#%% Matrix of Region Count
maxRegion = np.nanmax(matrix).astype(int)
regions = maxRegion + 1

reactMatrix = np.zeros((regions-1, reactLength))
for i in range(reactLength):
    matrixCol = matrix[:, i]
    for j in range(1, regions):
        reactMatrix[j-1, i] = np.sum(matrixCol == j)

#%% Stacked Region Count Matrix
reactMatrix_stack = np.zeros((regions-1, reactLength))
for i in range(reactLength):
    colSum = np.sum(reactMatrix[:, i])
    totalSum = 0
    for j in range(1, regions):
        regionOcc = reactMatrix[j-1, i]
        prob = reactMatrix[j-1, i]/colSum
        prob_stack = totalSum + prob
        reactMatrix_stack[j-1, i] = prob_stack
        totalSum += prob
        
#%%
x_arr = np.arange(reactLength)

for i in reversed(range(1, regions)):
    plt.plot(reactMatrix_stack[i-1, :], label=i-1)
    plt.fill_between(x_arr, reactMatrix_stack[i-1, :], interpolate=(True))
plt.legend(loc='lower center')

