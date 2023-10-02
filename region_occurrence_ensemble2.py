import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import scipy.io #This will allow us to open .mat files
flytable = pd.read_pickle(r"C:\Users\Dhruvum Bajpai\Desktop\Computational Project\My Scripts\Python Conversion\ensemble2\flytable_ensemble.pkl")
#flytable = pd.read_pickle(r"C:\Users\Dhruvum Bajpai\Desktop\Computational Project\My Scripts\Python Conversion\Maps\1\flytable.pkl")
regions = 11
reactLength = 400 

#%% Plots length of reactions
flytable_filter = flytable.dropna(subset=['frameofStimStart', 'frameofTakeoff']).reset_index()
#flytable_filter = flytable_filter[(flytable_filter.stimProtocol=='loom_10to180_lv40_blackonwhite.mat\n')&(flytable_filter.takeoffTypes==0)].reset_index(drop=True)
#flytable_filter = flytable_filter[(flytable_filter.stimProtocol=='loom_10to180_lv40_blackonwhite.mat\n')&(flytable_filter.manualJumpTest==1)].reset_index(drop=True)
flytable_filter = flytable_filter[(flytable_filter.stimProtocol=='loom_10to180_lv40_blackonwhite.mat\n')&(flytable_filter.manualJumpTest==1)&(flytable.labels==3)].reset_index(drop=True)

#flytable_filter = flytable_filter[flytable_filter.stimProtocol=='loom_10to180_lv40_blackonwhite.mat\n'].reset_index(Drop=True)
#flytable_filter = flytable_filter[flytable_filter.takeoffTypes==0].reset_index(drop=True)
trial_length = flytable_filter.frameofTakeoff - flytable_filter.frameofStimStart

#%% Make Matrix of Region occurrence among all Trials
matrix = np.zeros((len(flytable_filter.trial_list), reactLength))
matrix[:] = np.nan
for i in range(len(flytable_filter.trial_list)):
    full_trial = flytable_filter.trial_full[i]
    stimStart = int(flytable_filter.frameofStimStart[i])
    takeoff = int(flytable_filter.frameofTakeoff[i])
    if (trial_length[i] <= reactLength) & (len(full_trial)>=takeoff) & (takeoff>stimStart):
        matrix[i][0:trial_length[i]] = full_trial[stimStart:takeoff]
        
#%% Matrix of Region Count
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
    plt.plot(reactMatrix_stack[i-1, :], label=i)
    plt.fill_between(x_arr, reactMatrix_stack[i-1, :], interpolate=(True))
plt.legend(loc='upper left')

