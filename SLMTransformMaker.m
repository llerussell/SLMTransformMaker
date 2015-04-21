function SLMTransformMaker
% Lloyd Russell 20150321

% explain the procedure
message = {
    '1. First, calibrate uncaging galvos using zero order spot'
    '2. Burn multiple spots onto fluorescent slide (simultaneously or sequentially), image with 2P'
    '3. Register all SLM targets and the 2P burnt spot image'
    '4. Use the saved transform when making future phase masks'};
msg_title = 'Transform procedure';
uiwait(msgbox(message,msg_title));

% load images
[file_name, path_name] = uigetfile('*.tif*', 'Select the fixed image (SLM targets)');
cd(path_name)
filepath = [path_name filesep file_name];
fixedImg = imread(filepath);

[file_name, path_name] = uigetfile('*.tif*', 'Select the moving image (2P image)');
filepath  = [path_name filesep file_name];
movingImg = imread(filepath);

% convert images for display
fixedImg  = double(fixedImg);
movingImg = double(movingImg);
fixedImg  = uint8(fixedImg/max(max(fixedImg))*255);
movingImg = uint8(movingImg/max(max(movingImg))*255);

% use control points GUI to select reference points
[movingPoints, fixedPoints] = cpselect(movingImg, fixedImg, 'wait',true);

% make the transform (projective or affine?)
tform = fitgeotrans(movingPoints, fixedPoints, 'affine');

% apply transform to moving image
Rfixed = imref2d(size(fixedImg));
registeredImg = imwarp(movingImg, tform, 'FillValues',255, 'OutputView',Rfixed);

% make overlay images for visualisation
beforeTransformOverlay = imfuse(fixedImg, movingImg, 'ColorChannels','red-cyan');
afterTransformOverlay  = imfuse(fixedImg, registeredImg, 'ColorChannels','red-cyan');

% display overlay images
figure('Position',[100 100 800 400], 'menubar', 'none');
subplot(1,2,1)
imshow(beforeTransformOverlay)
title('Before')
subplot(1,2,2)
imshow(afterTransformOverlay)
title('After')

% save the transform
[file_name, path_name] = uiputfile('*.mat', 'Save the transform file');
filepath = [path_name filesep file_name];
save(filepath, 'tform');
