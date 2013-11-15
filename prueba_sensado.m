close all; clear all; home

%% Read and Convert Data

filename = '../log_carolina_9.txt';
opt.plot = 1;
[aRaw,wRaw,mRaw,tRaw,bRaw,~,~,T] = mong_read(filename, opt.plot);
[a,w,euler,m] = mong_conv(aRaw, wRaw, mRaw, opt.plot, tRaw);