function  [externalID,maxSSIM] = cos_ssim(files,aid,sigma)
    dirs = dir( files ); 
    dirs = dirs(3:length(dirs),1);
    externalID = 0;
    maxSSIM = 0;
    views = zeros(size(length(dirs)));

    for i =1:1:length(dirs)
        filename = dirs(i,1).name;
        allname = strcat(files,'\',filename);
        id = str2double(filename(1:length(filename)-4));
        if  ((id>5)&&(id<90))||((id>113)&&(id<147))||((id>169)&&(id<209))
         if ((id<(aid-10))||(id>(aid+10)))
            target =  (imread(strcat(files,'\',num2str(aid),'.png')));
            external  = (imread(allname));
            [target,external] = AddNoise(target,external,sigma);
            [~,~,ssim,~,~] = accumelate(target,external);
            views(id)=ssim;
        
            if ssim>maxSSIM
                maxSSIM = ssim;
                externalID = id;
            end     
         end
        end
    end
end

function [PSNR,cos,SSIM,persion,mse] = accumelate(target,external)
    [PSNR, SSIM]  = Cal_PSNRSSIM(im2uint8(target),im2uint8(external),0,0);
    cos = CosS(im2uint8(target),im2uint8(external));
    persion = HistDist(im2uint8(target),im2uint8(external));
    [~,mse,~] = psnr_mse_maxerr(im2uint8(target),im2uint8(external));
end

function [target,external] = AddNoise(target,external,sigma)

    if size(target,3)==3
        target = rgb2gray(target);
        external = rgb2gray(external);
    end
    
    target = im2double(target);
    external= im2double(external);

    % add noise
    randn('seed',0);

    external = single(external);
    target = target+sigma/255.*randn(size(target));%Ìí¼ÓÔëÉù(un_Clipping)
    target = single(target);
end
