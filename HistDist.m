function hist = HistDist(t1,t2)
format long g;
[Count1,x]=imhist(t1);
[Count2,x]=imhist(t2);
Sum1=sum(Count1);Sum2=sum(Count2);
Sumup = sqrt(Count1.*Count2);
SumDown = sqrt(Sum1*Sum2);
Sumup = sum(Sumup);
hist=1-sqrt(1-Sumup/SumDown);

[psnr,mse,maxerr,L2rat] = psnr_mse_maxerr(t1,t2);
end