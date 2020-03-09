function I_rgb = expand(map,on,under,left,right,name,Enlargement_Factor)
figure;

if size(map,3)==1
    x(:,:,1) = map;
    x(:,:,2) = map;
    x(:,:,3) = map;
else
    x = map;
end

imshow(x);
if on==0
    rect=getrect(gca);%Manually select the desired area
    disp(rect);
else
    rect = [on,under,left,right];
end
    
bw=imcrop(x,rect);
x(under,on:on+left,1) = 255;x(under,on:on+left,2) = 0;x(under,on:on+left,3) = 0;
x(under+right,on:on+left,1) = 255;x(under+right,on:on+left,2) = 0;x(under+right,on:on+left,3) = 0;
x(under:under+right,on,1) =255;x(under:under+right,on,2) =0;x(under:under+right,on,3) =0;
x(under:under+right,on+left,1) = 255;x(under:under+right,on+left,2) = 0;x(under:under+right,on+left,3) = 0;


Interpolation_Method = 'bicubic'; 
I = imresize(bw,Enlargement_Factor,Interpolation_Method);%·Å´ó
I_rgb = I;
 
if ~exist('LineWidth','var')
    LineWidth = 1;
end
LeftUpPoint= [1,1];
RightBottomPoint=size(I_rgb);
LineWidth=2;
UpRow = LeftUpPoint(1);
LeftColumn = LeftUpPoint(2);
BottomRow = RightBottomPoint(1);
RightColumn = RightBottomPoint(2);
 
% Up
I_rgb(UpRow:UpRow + LineWidth,LeftColumn:RightColumn,1) = 0;
I_rgb(UpRow:UpRow + LineWidth,LeftColumn:RightColumn,2) = 255;
I_rgb(UpRow:UpRow + LineWidth,LeftColumn:RightColumn,3) = 0;
% Under
I_rgb(BottomRow:BottomRow + LineWidth - 1,LeftColumn:RightColumn,1) = 0;
I_rgb(BottomRow:BottomRow + LineWidth - 1,LeftColumn:RightColumn,2) = 255;
I_rgb(BottomRow:BottomRow + LineWidth - 1,LeftColumn:RightColumn,3) = 0;
% left
I_rgb(UpRow:BottomRow,LeftColumn:LeftColumn + LineWidth,1) = 0;
I_rgb(UpRow:BottomRow,LeftColumn:LeftColumn + LineWidth,2) = 255;
I_rgb(UpRow:BottomRow,LeftColumn:LeftColumn + LineWidth,3) = 0;
% right
I_rgb(UpRow:BottomRow,RightColumn:RightColumn + LineWidth - 1,1) = 0;
I_rgb(UpRow:BottomRow,RightColumn:RightColumn + LineWidth - 1,2) = 255;
I_rgb(UpRow:BottomRow,RightColumn:RightColumn + LineWidth - 1,3) = 0;

[Iw,Ih,~] = size(I_rgb);
[w,h,~] = size(x);

x(w-Iw+1:w,1:Ih,:) = I_rgb;
imshow(x);




