#%%
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import scipy.io #This will allow us to open .mat files
flytable = pd.read_pickle(r"C:\Users\Dhruvum Bajpai\Desktop\Computational Project\My Scripts\Python Conversion\ensemble\flytable_ensemble.pkl")
#%%
regions = 50
priorTakeoff = 100
timeMin = 600
timeMax = 960
#%% Plots length of reactions
trial_length = []
flytable_filter = flytable.dropna(subset=['frameofStimStart', 'frameofTakeoff']).reset_index()
#flytable_filter = flytable_filter[(flytable_filter.stimProtocol=='loom_10to180_lv40_blackonwhite.mat\n')&(flytable_filter.takeoffTypes==0)].reset_index(drop=True)
flytable_filter = flytable_filter[(flytable_filter.stimProtocol=='loom_10to180_lv40_blackonwhite.mat\n')&(flytable_filter.takeoffTypes==1)].reset_index(drop=True)
#flytable_filter = flytable_filter[flytable_filter.stimProtocol=='loom_10to180_lv40_blackonwhite.mat\n'].reset_index(Drop=True)
#flytable_filter = flytable_filter[flytable_filter.takeoffTypes==0].reset_index(drop=True)
trial_length = flytable_filter.frameofTakeoff - flytable_filter.frameofStimStart

#%% Make Matrix of Region occurrence among all Trials
matrix = np.zeros((len(flytable_filter.trial_list), priorTakeoff))
matrix[:] = np.nan
for i in range(len(flytable_filter.trial_list)):
    full_trial = flytable_filter.trial_full[i]
    stimStart = int(flytable_filter.frameofStimStart[i])
    takeoff = int(flytable_filter.frameofTakeoff[i])
    reactLength = takeoff - stimStart
    #if (reactLength>=priorTakeoff) & (len(full_trial)>=takeoff):
    if (reactLength>=priorTakeoff) & (len(full_trial)>=takeoff) & (takeoff>=timeMin) & (takeoff<=timeMax):
        matrix[i][0:priorTakeoff] = full_trial[takeoff-priorTakeoff:takeoff]
        
#%% Matrix of Region Count
reactMatrix = np.zeros((regions-1, priorTakeoff))
for i in range(priorTakeoff):
    matrixCol = matrix[:, i]
    for j in range(1, regions):
        reactMatrix[j-1, i] = np.sum(matrixCol == j)

#%% Stacked Region Count Matrix
reactMatrix_stack = np.zeros((regions-1, priorTakeoff))
for i in range(priorTakeoff):
    colSum = np.sum(reactMatrix[:, i])
    totalSum = 0
    for j in range(1, regions):
        regionOcc = reactMatrix[j-1, i]
        prob = reactMatrix[j-1, i]/colSum
        prob_stack = totalSum + prob
        reactMatrix_stack[j-1, i] = prob_stack
        totalSum += prob
        
#%%
x_arr = np.arange(priorTakeoff)

for i in reversed(range(1, regions)):
    plt.plot(reactMatrix_stack[i-1, :])
    plt.fill_between(x_arr, reactMatrix_stack[i-1, :], interpolate=(True))
