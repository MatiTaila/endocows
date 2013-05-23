close all
clear all
% home

im     = imread('pics/sc.jpg');
grayIm = rgb2gray(im);
[m,n]  = size(grayIm);

Nclusters = 3;

% Bloque de dimensión Nm*Nn
Nm = 3;
Nn = 3;
N  = Nm*Nn;
M  = (m-Nm+1)*(n-Nn+1);

data = zeros(M,N);
k=1;
for i=1:m-Nm+1 
    for j=1:n-Nn+1
        data(k,:) = reshape(im(i:i+Nm-1,j:j+Nn-1),1,N);
        k=k+1;
    end
end

[C, U, OBJ_FCN] = fcm(data, Nclusters);

%%

maxU = max(U);
im_out = zeros(m-Nm+1,n-Nn+1,Nclusters);

for i=1:Nclusters
    im_out(:,:,i) = reshape(U(i,:) == maxU,m-Nm+1,n-Nn+1);
end

%%

green = zeros(m-Nm+1,n-Nn+1,3); green(:,:,2)=ones(m-Nm+1,n-Nn+1);

for i=1:Nclusters
    figure;
    imshow(im(1:m-Nm+1,1:n-Nn+1));
    hold on
    h = imshow(green);
    hold off
    set(h, 'AlphaData', im_out(:,:,i)'/3);
end

%%

if ( mod(Nn,2) && mod(Nm,2) )
    
%     data2=zeros(M,8);
% data2(i,:)=data(i,[1:(N+1)/2-1 (N+1)/2+1:N]>data((N+1)/2)])
    
    
    
    
    
    
    
end











