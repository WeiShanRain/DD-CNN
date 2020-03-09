function covs = calculatecov(x,y)
covs =0;
   [height,width] = size(x);
   Minput = mean(mean(x));
   Moutput = mean(mean(y));
    for i = 1:1:height
        for j = 1:1:width
            covs = covs+(x(i,j)-Minput)*(y(i,j)-Moutput);
        end
    end
    covs = covs/(height*width-1);