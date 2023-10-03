import numpy as np
import pandas as pd
import os #Allows one to set the Working Directory
import matplotlib.pyplot as plt

#%%
os.chdir(r"C:\Users\Dhruvum Bajpai\Desktop\Computational Project")
flytable = pd.read_pickle(r"C:\Users\Dhruvum Bajpai\Desktop\Computational Project\My Scripts\Python Conversion\flytable.pkl")
dyntable = pd.read_pickle(r"C:\Users\Dhruvum Bajpai\Desktop\Computational Project\My Scripts\Python Conversion\dyntable.pkl")
alltable = dyntable
for i in flytable.columns:
    alltable[i] = flytable[i]
#%%
reactLength = 156

alltable = alltable.dropna(subset=['frameofStimStart', 'midEndFrame', 'labels', 'labels_simp'])
trial_length = alltable.midEndFrame - alltable.frameofStimStart
alltable['trial_length'] = trial_length
alltable['azi_rel'] = alltable.bodyAxis*(180/np.pi) - alltable.azi

alltable_filter = alltable[(alltable.stimProtocol=='loom_10to180_lv40_blackonwhite.mat\n')&(alltable.trial_length==reactLength)&(alltable.allLVs==40)].reset_index(drop=True)

#%% Filter out trials which don't have full recordings over reaction period
input_seq = alltable_filter[['azi_rel',
       'bodyAxisAngularVelocity', 'head_x', 'head_y', 'abdomen_x',
       'abdomen_y', 't1left_x', 't1left_y',
       't2left_x', 't2left_y', 't3left_x', 't3left_y',
      't3right_x', 't3right_y', 't2right_x',
       't2right_y', 't1right_x', 't1right_y',
       'bp1_x', 'bp1_y','bp2_x', 'bp2_y', 'neck_x',
       'neck_y', 'centre_x', 'centre_y']]
column_names = input_seq.columns

selectIdx = range(input_seq.shape[0])
dropIdx = []

X = np.zeros((input_seq.shape[0], reactLength, input_seq.shape[1]*2))
for trial in range(input_seq.shape[0]):
    frameofStimStart = alltable_filter.frameofStimStart[trial] - 1
    midEndFrame = alltable_filter.midEndFrame[trial] - 1
    
    for i, column in enumerate(column_names):  
        if len(input_seq[column][trial]) > midEndFrame:
            entry = input_seq[column][trial][frameofStimStart:midEndFrame]
            X[trial, :, i] = np.nan_to_num(entry, nan=0)
            X[trial, :, i+len(column_names)] = np.isnan(entry)      #Deals with NaN values by creating corresponding isnan bool entries
        else:
            dropIdx.append(trial)

selectIdx = np.setdiff1d(selectIdx, np.unique(dropIdx))
X = X[np.unique(selectIdx), :, :]

alltable_filter = alltable_filter.drop(np.unique(dropIdx))

input_cat = alltable_filter[['ele', 'gender']]
input_cat_dummies = pd.get_dummies(input_cat.astype('string'))
cat_columns = input_cat_dummies.columns

input_cat_vector = np.zeros((input_cat_dummies.shape[0], reactLength, input_cat_dummies.shape[1]))
for trial in range(input_cat_dummies.shape[0]):
    for i, column in enumerate(cat_columns):
        input_cat_vector[trial, :, i] = np.ones(reactLength) * input_cat_dummies[column][trial]

#%% Split into Training and Testing Sets
from sklearn.model_selection import train_test_split
from scipy.stats import zscore

y_simp = np.asarray(alltable_filter.labels_simp).astype(np.float32) - 1     #The labels need to start with the value 0
y = np.asarray(alltable_filter.labels).astype(np.float32) - 1

X_scaled = X
for i in range(X.shape[2]):
    neg_arr = X[:, :, i] < 0
    pos_arr = X[:, :, i] > 0
    zero_arr = X[:, :, i] == 0
    scaled = zscore(X_scaled[:, :, i])
    X_scaled[:, :, i] = scaled
    
X_final = np.concatenate((X_scaled, input_cat_vector), axis=2)
#X_train, X_test, y_train, y_test = train_test_split(X_final, y, test_size=0.5, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X_final, y, test_size=0.5, random_state=42)

#%% Selects equal number of region outputs
X_train_arr = np.array(X_train)
y_train_arr = np.array(y_train)

X_train_equal = []
y_train_equal = []

reg_values, reg_counts = np.unique(y_train_arr, return_counts=True)
min_occ = min(reg_counts)
for region in reg_values:
    X_train_reg = X_train[y_train == region][:min_occ, :, :]
    y_train_reg = y_train[y_train == region][:min_occ]
    
    X_train_equal.append(X_train_reg)
    y_train_equal.append(y_train_reg)

X_train_equal = np.concatenate(X_train_equal, axis=0)
y_train_equal = np.concatenate(y_train_equal, axis=0)

#Shuffle both X_train and y_train
r_indexes = np.arange(len(y_train_equal))
np.random.shuffle(r_indexes)

X_train_equal = X_train_equal[r_indexes, :, :]
y_train_equal = y_train_equal[r_indexes]
#%%
import keras
from keras.models import Sequential
from keras import layers


n_input = X_train.shape[1]  #156
n_features = X_train.shape[2] #38  #Depends on #time series used to produce result

loss = keras.losses.SparseCategoricalCrossentropy(from_logits=True)
optim = keras.optimizers.Adam(learning_rate=0.001)

model = Sequential()
model.add(keras.Input((n_input, n_features)))
model.add(layers.GRU(n_features, return_sequences=True))
model.add(layers.GRU(44, return_sequences=True))
model.add(layers.GRU(22, return_sequences=True))
model.add(layers.SimpleRNN(11))
model.add(layers.Dense(7))
print(model.summary())

model.compile(loss=loss, optimizer=optim, metrics=['accuracy'])

model.fit(X_train_equal, y_train_equal, validation_data=(X_train_equal, y_train_equal), epochs=10 )

#%% Testing Accuracy
from sklearn.metrics import confusion_matrix

pred_prob = model.predict(X_test)

pred_cat = np.argmax(pred_prob,axis=1)
print(confusion_matrix(pred_cat, y_test))

comparison = np.asarray([pred_cat, y_test])
