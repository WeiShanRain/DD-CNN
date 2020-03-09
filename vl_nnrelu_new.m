function [x,y,z] = vl_nnrelu_new(num,x,y,z,dzdy,varargin)
global lea
opts.leak = 0 ;
opts = vl_argparse(opts, varargin, 'nonrecursive') ;

if opts.leak == 0
    w = x;%��x����w
    x = max(x, 0) ;%x�д���0�������䣬С��0������0    
    w(w==0) =1;%w(x)��Ϊ0������1
    w = max(w,0);%w(x)�д���0�������䣬С��0 ������0
    w(w>0) = 1;%w(x)�д���0������1������ʱԭx=max(x,0)�еĲ�����w����0,1�����������1Ϊ������0Ϊ��0
    y = y.*w;%��x��max(x,0)����ת�Ƶ�y�ϡ�
    y=max(y,lea*y);%���ڲο�ͼ���ʱ��ʹ��
    
    z=max(z,0);
else
    w = x;%��x����w
    x = max(x, opts.leak*x) ;%x�д���0�������䣬С��0������0    
    w(w==0) =1;%w(x)��Ϊ0������1
    w = max(w,0);%w(x)�д���0�������䣬С��0 ������0
    w(w>0) = 1;%w(x)�д���0������1������ʱԭx=max(x,0)�еĲ�����w����0,1�����������1Ϊ������0Ϊ��0
    w(x<=0)=opts.leak;
    y = y.*w;%��x��max(x,0)����ת�Ƶ�y�ϡ�
    y=max(y,opts.leak*y);
    z=max(z,0);
end
