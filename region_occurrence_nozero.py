import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import scipy.io #This will allow us to open .mat files
from math import nan

#0.4 - 50
#0.6 - 26
#1.2 - 10

#flytable = pd.read_pickle(r"C:\Users\Dhruvum Bajpai\Desktop\Computational Project\My Scripts\Python Conversion\Maps\2\flytable.pkl")
flytable = pd.read_pickle(r"C:\Users\Dhruvum Bajpai\Desktop\Computational Project\My Scripts\Python Conversion\Maps\1\flytable.pkl")
regions = 10
reactLength = 156

#%% Plots length of reactions
flytable_filter = flytable.dropna(subset=['frameofStimStart', 'midEndFrame', 'labels']).reset_index(drop=True)

trial_length = flytable_filter.midEndFrame - flytable_filter.frameofStimStart
flytable_filter['trial_length'] = trial_length
flytable_filter = flytable_filter[~trial_length.isna()].reset_index(drop=True)
flytable_filter = flytable_filter[(flytable_filter.stimProtocol=='loom_10to180_lv40_blackonwhite.mat\n')&(flytable_filter.labels_simp==3)].reset_index(drop=True)
#flytable_filter = flytable_filter[(flytable_filter.stimProtocol=='loom_10to180_lv40_blackonwhite.mat\n')&(flytable_filter.labels==2)&(flytable_filter.manualJumpTest==1)].reset_index(drop=True)

#flytable_filter = flytable_filter.iloc[0:20]

#%% Flytable - NonZero
flytable_nozero = flytable_filter
zeroThresh = 30;
for i in range(len(flytable_filter.trial_full)):
    trialRegions = flytable_filter.trial_full[i]
    prevRegion = trialRegions[1];
    zeroCount = 0
    zeroStart = 0
    for region_ind in range(2, len(trialRegions)):
        if trialRegions[region_ind] != 0:
            if zeroCount > 0:
                if zeroCount < zeroThresh:
                    trialRegions[zeroStart:zeroStart+zeroCount-1] = prevRegion;
                zeroCount = 0
                zeroStart = 0
            prevRegion = trialRegions[region_ind]
        else:
            if np.isnan(prevRegion) or (prevRegion == 0):
                prevRegion = trialRegions[region_ind]
                continue
            if zeroCount == 0:
                zeroStart = region_ind
            zeroCount += 1
flytable_nozero.trial_full[i] = trialRegions;

#%% Make Matrix of Region occurrence among all Trials
matrix = np.zeros((len(flytable_nozero.trial_list), reactLength))
matrix[:] = np.nan

for i in range(len(flytable_nozero.trial_list)):
    full_trial = flytable_nozero.trial_full[i]
    stimStart = flytable_nozero.frameofStimStart[i]
    midEndFrame = flytable_nozero.midEndFrame[i]
    if (len(full_trial)+stimStart>=midEndFrame) & (midEndFrame>stimStart):
        diff = reactLength - flytable_nozero.trial_length[i]
        if diff>0:
            matrix[i][diff:-1] = full_trial[0:reactLength-diff-1]
        else:
            matrix[i] = full_trial[0 - diff:reactLength]
            #Remember, trial_full begins assigning regions at the frame of stim start.
        
#%% Matrix of Region Count
reactMatrix = np.zeros((regions, reactLength))
for i in range(reactLength):
    matrixCol = matrix[:, i]
    
    #for j in range(1, regions):
    for j in range(2, regions+1):     #If ignoring zero values
        reactMatrix[j-1, i] = np.sum(matrixCol == j-1)

#%% Stacked Region Count Matrix
reactMatrix_stack = np.zeros((regions, reactLength))
for i in range(reactLength):
    colSum = np.sum(reactMatrix[:, i])
    totalSum = 0
    for j in range(1, regions+1):
        regionOcc = reactMatrix[j-1, i]
        prob = reactMatrix[j-1, i]/colSum
        prob_stack = totalSum + prob
        reactMatrix_stack[j-1, i] = prob_stack
        totalSum += prob
        
#%%
x_arr = np.arange(reactLength)

for i in reversed(range(1, regions+1)):
    plt.plot(reactMatrix_stack[i-1, :], label=i-1)
    plt.fill_between(x_arr, reactMatrix_stack[i-1, :], interpolate=(True))
plt.legend(loc='upper left')

