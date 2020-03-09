%clear; clc;
format compact;
global sigmas;
global sigmas2;
global lea ;
addpath(fullfile('utilities'));

useGPU      = 0;    %Without GPU

lea = 0.1;
% hold on;

imageNoiseSigma =50;    %Add noise for the clear image
inputNoiseSigma2 = 50;	%The noise level for the denoising network

load(fullfile('models','FFDNet_gray.mat'));

net = vl_simplenn_tidy(net);

if useGPU
    net = vl_simplenn_move(net, 'gpu') ;
end

Dataset = 'image1';
i = 57; %Band of input image
ClearImage= imread(fullfile('./Hyperspectral/resize_image/',Dataset,strcat(num2str(i),'.png')));

%Denoising with Well-Selected Reference images
[externalid,SSIM] = cos_ssim(strcat('./Hyperspectral/resize_image/',Dataset),i,0);
ExternalImage= imread(fullfile('./Hyperspectral/resize_image/',Dataset,strcat(num2str(externalid),'.png')));

%Denoising with Unsatisfactory Reference Features
% ExternalImage= imread(fullfile('./Hyperspectral/resize_image/',Dataset,'91.png'));

[w,h,~]=size(ExternalImage);

if size(ExternalImage,3)==3
    ExternalImage = rgb2gray(ExternalImage);
    ClearImage = rgb2gray(ClearImage);
end
ExternalImage = im2double(ExternalImage);
ClearImage= im2double(ClearImage);

% add noise
randn('seed',0);
external = single(ExternalImage);
noised = ClearImage+imageNoiseSigma/255.*randn(size(ClearImage));%Ìí¼ÓÔëÉù(un_Clipping)

noised = single(noised);

cos = CosS(im2uint8(external),im2uint8(noised));
inputNoiseSigma =inputNoiseSigma2*cos/3;

if mod(w,2)==1
    external = cat(1,external, external(end,:)) ;
    noised = cat(1,noised, noised(end,:)) ;
end
if mod(h,2)==1
    external = cat(2,external, external(:,end)) ;
    noised = cat(2,noised, noised(:,end)) ;
end

% tic;
if useGPU
    external = gpuArray(external);
    noised = gpuArray(noised);
end


% set noise level map
sigmas = inputNoiseSigma/255; %The noise level of external image
sigmas2 = inputNoiseSigma2/255;%The noise level of noise image
[resultD,resultF]    = vl_simplenn(net,external,noised,noised,[],[],'conserveMemory',true,'mode','test'); % matconvnet default

outputD = resultD(end).y;
outputF = resultF(end).z;

if mod(w,2)==1
    outputD = outputD(1:end-1,:);
    outputF = outputF(1:end-1,:);
    noised  = noised(1:end-1,:);
end
if mod(h,2)==1
    outputD = outputD(:,1:end-1);
    outputF = outputF(:,1:end-1);
    noised  = noised(:,1:end-1);
end
if useGPU
    outputD = gather(outputD);
    outputF = gather(outputF);
    input  = gather(input);
end

outputD = histogram(outputF, outputD);%Histogram matching
% Calculation PSNR and SSIM
[PSNRCur1, SSIMCur1] = Cal_PSNRSSIM(im2uint8(ClearImage),im2uint8(outputD),0,0);%DD-CNN
[PSNRCur2, SSIMCur2] = Cal_PSNRSSIM(im2uint8(ClearImage),im2uint8(outputF),0,0);%FFDNet

disp(['DD-CNN' ,'¡ªPSNR£º',num2str(PSNRCur1,'%2.4f'),'dB','    SSIM£º',num2str(SSIMCur1,'%2.4f'),'    FFDNet' ,'¡ªPSNR£º',num2str(PSNRCur2,'%2.2f'),'dB','    SSIM£º',num2str(SSIMCur2,'%2.4f')]);
imshow(cat(2,im2uint8(noised),im2uint8(outputD),im2uint8(outputF)));


