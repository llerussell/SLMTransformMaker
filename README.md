# SLMTransformMaker
Matlab script to calculate transform required to map 2P space onto SLM space.

1. Calibrate uncaging galvos using zero order spot. This will ensure the centre of SLM space is the centre of 2P imaging space. (optional)
2. Burn multiple spots onto fluorescent slide (simultaneously or sequentially), take a 2P image of the burnt slide
3. Register the SLM targets image and the 2P burnt spot image
4. Use the saved transform when making all future [SLM phase masks](https://github.com/llerussell/SLMPhaseMaskMaker_MatlabCUDA)


![Imgur](http://i.imgur.com/GnmjOWt.jpg)

Example application of calculated transform:
``` matlab
% load some points from an image
targets_img = imread('/path/to/image');
[y_raw, x_raw, intensities] = find(targets_img);

% load the saved transform
load('20150101_tform_001.mat')

% do the transformation
[x_trans, y_trans] = transformPointsForward(tform, x_raw, y_raw);

% get nearest pixel coordinates
x_trans = round(x_trans);
y_trans = round(y_trans);

% rebuild transformed image
transformed_targets_img = zeros(size(targets_img));
for idx = 1:length(x_trans)
    transformed_targets_img(y_trans(idx), x_trans(idx)) = intensities(idx);
end
```
