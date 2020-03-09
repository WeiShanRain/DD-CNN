function outputn = histogram(outputh,outputn)
f = im2uint8(outputn);
f_ref = im2uint8(outputh);
[h1,w1] = size(f);
[h2,w2] = size(f_ref);

hist1 = zeros(1,256);   
for row = 1:h1
    for col = 1:w1
        hist1(f(row,col)+1) = hist1(f(row,col)+1)+1;    
    end
end

f_table = zeros(1,256);   
cum_sum = 0;
for index = 1:256;
    cum_sum = cum_sum + hist1(index);
    f_table(index) = (255/(h1*w1))*cum_sum;
end

hist1_ref = zeros(1,256);   
for row = 1:h2
    for col = 1:w2
        hist1_ref(f_ref(row,col)+1) = hist1_ref(f_ref(row,col)+1)+1;   
    end
end

f_ref_table = zeros(1,256);  
cum_sum = 0;
for index = 1:256;
    cum_sum = cum_sum + hist1_ref(index);
    f_ref_table(index) = (255/(h2*w2))*cum_sum;
end

map_table = zeros(1,256);
for index = 1:256
    [temp,ind] = min(abs(f_table(index)-f_ref_table));
    map_table(index) = ind-1;
end


f_match = zeros(h1,w1);  
for row = 1:h1
    for col = 1:w1
        f_match(row,col) = map_table(double(f(row,col)+1));  
    end
end

outputn = uint8(f_match);