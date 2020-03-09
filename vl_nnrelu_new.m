function [x,y,z] = vl_nnrelu_new(num,x,y,z,dzdy,varargin)
global lea
opts.leak = 0 ;
opts = vl_argparse(opts, varargin, 'nonrecursive') ;

if opts.leak == 0
    w = x;%将x赋给w
    x = max(x, 0) ;%x中大于0的数不变，小于0的数置0    
    w(w==0) =1;%w(x)中为0的数置1
    w = max(w,0);%w(x)中大于0的数不变，小于0 的数置0
    w(w>0) = 1;%w(x)中大于0的数置1——此时原x=max(x,0)中的操作在w中用0,1进行了替代。1为保留，0为置0
    y = y.*w;%将x的max(x,0)操作转移到y上。
    y=max(y,lea*y);%基于参考图像的时候使用
    
    z=max(z,0);
else
    w = x;%将x赋给w
    x = max(x, opts.leak*x) ;%x中大于0的数不变，小于0的数置0    
    w(w==0) =1;%w(x)中为0的数置1
    w = max(w,0);%w(x)中大于0的数不变，小于0 的数置0
    w(w>0) = 1;%w(x)中大于0的数置1——此时原x=max(x,0)中的操作在w中用0,1进行了替代。1为保留，0为置0
    w(x<=0)=opts.leak;
    y = y.*w;%将x的max(x,0)操作转移到y上。
    y=max(y,opts.leak*y);
    z=max(z,0);
end
