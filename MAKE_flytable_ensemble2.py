# -*- coding: utf-8 -*-
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import scipy.io #This will allow us to open .mat files
import os #Allows one to set the Working Directory
import mat73
os.chdir(r"C:\Users\Dhruvum Bajpai\Desktop\Computational Project\My Scripts\Python Conversion") #The 'r' before the directory converts it into a raw string
flycell = scipy.io.loadmat('ensembleCell.mat')['flycell']
#%% Flytable
#1.trial_list, 2.trial_regions, 3.trialFull, 4.frameofStimStart, 5.frameofTakeoff, 6.stimLength, 7.stimTheta_frms, 8.allLVs, 9.legPushFrame
#10.wingUpFrame, 11.jumpStart, 12.gender, 13.takeoffTypes, 14.manualJumpTest, 15.manualFot, 16.stimProtocol, 17.VideoName, 18.VideoPath
#19.midEndFrame, 20.labels_simp, 21.labels

trial_list = []
trial_regions = []
trial_full = []
frameofStimStart = []
frameofTakeoff = []
stimLength = []
stimTheta_frms = []
allLVs = []
legPushFrame = []
wingUpFrame = []
jumpStart = []
takeoffTypes = []
manualJumpTest = []
manualFot = []
midEndFrame = []
labels_simp = []
labels = []

for i in range(0,len(flycell)):
    trial_list.append(flycell[i,0][0][0])
    trial_regions.append(flycell[i,1][0])
    
    
    fulltrial_temp = []
    for j in range(0, len(flycell[i,2])):
                   fulltrial_temp.append(flycell[i,2][j][0])  
    trial_full.append(fulltrial_temp)
    
    frameofStimStart.append(flycell[i,3][0][0])
    frameofTakeoff.append(flycell[i,4][0][0])
    stimLength.append(flycell[i,5][0][0])
    stimTheta_frms.append(flycell[i,6][0])
    allLVs.append(flycell[i,7][0][0])
    legPushFrame.append(flycell[i,8][0][0])
    wingUpFrame.append(flycell[i,9][0][0])
    jumpStart.append(flycell[i,10][0][0])
    takeoffTypes.append(flycell[i,12][0][0])
    manualJumpTest.append(flycell[i,13][0][0])
    manualFot.append(flycell[i,14][0][0])
    midEndFrame.append(flycell[i,18][0][0])
    labels_simp.append(flycell[i,19][0][0])
    labels.append(flycell[i,20][0][0])

with open('gender.txt') as f:
    gender = f.readlines()

with open('stimProtocol.txt') as f:
    stimProtocol = f.readlines()
    
with open('videoName.txt') as f:
    videoName = f.readlines()
    
with open('videoPath.txt') as f:
    videoPath = f.readlines()
    
    
flytable = pd.DataFrame([trial_list, trial_regions, trial_full, frameofStimStart, frameofTakeoff, stimLength,stimTheta_frms, allLVs, legPushFrame, 
                         wingUpFrame, jumpStart, gender, takeoffTypes, stimProtocol, videoName, videoPath, manualJumpTest, manualFot, midEndFrame, 
                         labels_simp, labels])
flytable = flytable.T
flytable.columns = ['trial_list','trial_regions','trial_full','frameofStimStart','frameofTakeoff','stimLength','stimTheta_frms','allLVs','legPushFrame',
                    'wingUpFrame','jumpStart','gender','takeoffTypes','stimProtocol','videoName','videoPath', 'manualJumpTest', 'manualFot', 'midEndFrame',
                    'labels_simp', 'labels']

flytable.to_pickle("flytable_ensemble.pkl")  #Pickle files are simply compressed dataframes, without the need for a CSV

