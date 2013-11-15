load('cows_cfg');
I = im2double(imread([patients(10).path '/' patients(10).tambo '/' patients(10).selected_pics{1}]));
H = fspecial('gaussian',[10 10], 3);
I2 = imfilter(I,H,'replicate');
figure; 
imshow(I2)
gabor_example(I2)

