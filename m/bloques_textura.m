close all
clear all
% home

CROP_IMAGE = 0; % usa solo la mitad de arriba de la imagen
DATA_TYPE  = 0; % case 0: usa el bloque de 3x3
				% case 1: pone 0 o 1 comparando el bloque consigo mismo

im     = imread('../examples/2117.png');
grayIm = rgb2gray(im);
if CROP_IMAGE
	grayIm = grayIm(1:size(grayIm,1)/3,:);
end
[m,n]  = size(grayIm);

Nclusters = 3;

% Bloque de dimensión Nm*Nn
Nm = 3;
Nn = 3;
N  = Nm*Nn;
M  = (m-Nm+1)*(n-Nn+1);

data = zeros(M,N);
k=1;
for j=1:n-Nn+1
	for i=1:m-Nm+1
		if DATA_TYPE == 0
			data(k,:) = reshape(im(i:i+Nm-1,j:j+Nn-1),1,N);
		elseif DATA_TYPE == 1
			data(k,:) = grayIm(i,j) > reshape(grayIm(i:i+Nm-1,j:j+Nn-1),1,N);
		end
		k=k+1;
	end
end
if DATA_TYPE == 1
	data(:,5)=[]; % saco la comparacion consigo mismo
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
    set(h, 'AlphaData', im_out(:,:,i)/3);
end

%%

BW = im_out(1:size(im_out,1),:,1);
[centers, radii, metric] = imfindcircles(BW,[30 100]);
% centersStrong5 = centers(1:5,:);
% radiiStrong5 = radii(1:5);
% metricStrong5 = metric(1:5);
figure; imshow(BW); hold on;
viscircles(centers, radii,'EdgeColor','b');
% viscircles(centersStrong5, radiiStrong5,'EdgeColor','b');
centers

%%

% if ( mod(Nn,2) && mod(Nm,2) )
%     
% %     data2=zeros(M,8);
% % data2(i,:)=data(i,[1:(N+1)/2-1 (N+1)/2+1:N]>data((N+1)/2)])
%     
% end
