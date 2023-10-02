stimPath = 'Z:\hhmiData\dm11\cardlab\pez3000_variables\visual_stimuli\';
load([stimPath filesep 'loom_10to180_lv40_blackonwhite.mat'])
%%
%image(stimulusStruct.imgReset)
stimulusStruct_inverse = stimulusStruct;
flipReference = stimulusStruct.flipReference;

imgReset = stimulusStruct.imgReset;
imgReset_inverse = 255 - imgReset;

imgFin = stimulusStruct.imgFin;
imgFin_inverse = 255 - imgFin;

stimLength = size(stimulusStruct.imgCell);
stimLength = stimLength(1);
imgCell_inverse = cell(stimLength, 1);
for i = 1:stimLength
    img = stimulusStruct.imgCell{i};
    img_inverse = 255 - img;
    imgCell_inverse{i} = img_inverse;
end

stimulusStruct_inverse.imgReset = imgReset_inverse;
stimulusStruct_inverse.imgFin = imgFin_inverse;
stimulusStruct_inverse.imgCell = imgCell_inverse;
%%
stimulusStruct = stimulusStruct_inverse;

savePath='C:\Users\Dhruvum Bajpai\Desktop\Computational Project\';
save([savePath 'loom_10to180_lv40_whiteonblack.mat'],"stimulusStruct",'-mat');