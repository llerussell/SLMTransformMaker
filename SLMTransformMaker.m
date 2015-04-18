function SLMTransformMaker
% Lloyd Russell 20150321

% Explain the procedure
msg = {
    '1. Make 3 spot phase mask with no transform, load onto SLM'
    '2. Burn 3 spots onto fluorescent slide, image with 2P'
    '3. Register the SLM targets image and the 2P image'
    '4. Use the saved transform when making future phase masks'};
msg_title = 'Transform procedure';
uiwait(msgbox(msg, msg_title));

% Load images
[file_name, path_name] = uigetfile('*.tif*', 'Select the fixed image (SLM targets)');
cd(path_name)
file_path = [path_name filesep file_name];
fixed_image = imread(file_path);

[file_name, path_name] = uigetfile('*.tif*', 'Select the moving image (2P image)');
file_path = [path_name filesep file_name];
moving_image = imread(file_path);

% Convert images for display
fixed_image = double(fixed_image);
fixed_image = uint8(fixed_image/max(max(fixed_image))*255);
moving_image = double(moving_image);
moving_image = uint8(moving_image/max(max(moving_image))*255);

% Use control points GUI to select reference points
[moving_points, fixed_points] = cpselect(moving_image, fixed_image, 'wait',true);

% Make the transform (projective or affine?)
tform = fitgeotrans(moving_points, fixed_points, 'projective');

% Apply transform to moving image
r_fixed = imref2d(size(fixed_image));
registered_image = imwarp(moving_image, tform, 'FillValues',255, 'OutputView',r_fixed);

% Make overlay images for visualisation
before_tform_overlay = imfuse(fixed_image, moving_image, 'ColorChannels','red-cyan');
after_tform_overlay = imfuse(fixed_image, registered_image, 'ColorChannels','red-cyan');

% Display overlay images
figure('Position',[100 100 800 400], 'MenuBar','none');
subplot(1,2,1)
imshow(before_tform_overlay)
title('Before')
subplot(1,2,2)
imshow(after_tform_overlay)
title('After')

% Save the transform
[file_name, path_name] = uiputfile('*.mat', 'Save the transform file');
file_path = [path_name filesep file_name];
save(file_path, 'tform');
