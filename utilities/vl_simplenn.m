function [ren,reh] = vl_simplenn(net, x,y, z,dzdy, res, varargin)
global sigmas;
global sigmas2;
global lea;
opts.conserveMemory = false ;
opts.sync = false ;
opts.mode = 'normal' ;
opts.accumulate = false ;
opts.cudnn = true ;
opts.backPropDepth = +inf ;
opts.skipForward = false ;
opts.parameterServer = [] ;
opts.holdOn = false ;
opts = vl_argparse(opts, varargin);

n = numel(net.layers);
assert(opts.backPropDepth > 0, 'Invalid `backPropDepth` value (!>0)');
backPropLim = max(n - opts.backPropDepth + 1, 1);

if (nargin <= 2) || isempty(dzdy)
    doder = false ;
    if opts.skipForward
        error('simplenn:skipForwardNoBackwPass', ...
            '`skipForward` valid only when backward pass is computed.');
    end
else
    doder = true ;
end

if opts.cudnn
    cudnn = {'CuDNN'} ;
    bnormCudnn = {'NoCuDNN'} ; % ours seems slighty faster
else
    cudnn = {'NoCuDNN'} ;
    bnormCudnn = {'NoCuDNN'} ;
end

switch lower(opts.mode)
    case 'normal'
        testMode = false ;
    case 'test'
        testMode = true ;
    otherwise
        error('Unknown mode ''%s''.', opts. mode) ;
end

gpuMode = isa(x, 'gpuArray') ;

if nargin <= 3 || isempty(res)
    if opts.skipForward
        error('simplenn:skipForwardEmptyRes', ...
            'RES structure must be provided for `skipForward`.');
    end
    res = struct(...
        'x', cell(1,n+1), ...
        'dzdx', cell(1,n+1), ...
        'dzdw', cell(1,n+1), ...
        'aux', cell(1,n+1), ...
        'stats', cell(1,n+1), ...
        'time', num2cell(zeros(1,n+1)), ...
        'backwardTime', num2cell(zeros(1,n+1))) ;
    ren = struct(...
        'y', cell(1,n+1), ...
        'dzdx', cell(1,n+1), ...
        'dzdw', cell(1,n+1), ...
        'aux', cell(1,n+1), ...
        'stats', cell(1,n+1), ...
        'time', num2cell(zeros(1,n+1)), ...
        'backwardTime', num2cell(zeros(1,n+1))) ;
    reh = struct(...
        'z', cell(1,n+1), ...
        'dzdx', cell(1,n+1), ...
        'dzdw', cell(1,n+1), ...
        'aux', cell(1,n+1), ...
        'stats', cell(1,n+1), ...
        'time', num2cell(zeros(1,n+1)), ...
        'backwardTime', num2cell(zeros(1,n+1))) ;
end

if ~opts.skipForward
    res(1).x = x ;
    ren(1).y = y;
    reh(1).z = z;
end

% -------------------------------------------------------------------------
%                                                              Forward pass
% -------------------------------------------------------------------------

for i=1:n
    if opts.skipForward, break; end;
    l = net.layers{i} ;
    %res(i).time = tic ;
    switch l.type
        case 'conv'
            res(i+1).x = vl_nnconv(res(i).x, l.weights{1}, l.weights{2}, ...
                'pad', l.pad, ...
                'stride', l.stride, ...
                'dilate', l.dilate, ...
                l.opts{:}, ...
                cudnn{:}) ;%disp(size(res(i+1).x));
            ren(i+1).y = vl_nnconv(ren(i).y,l.weights{1}, l.weights{2}, ...
                'pad', l.pad, ...
                'stride', l.stride, ...
                'dilate', l.dilate, ...
                l.opts{:}, ...
                cudnn{:}) ;%disp(size(ren(i+1).y));
            reh(i+1).z = vl_nnconv(reh(i).z,l.weights{1}, l.weights{2}, ...
                'pad', l.pad, ...
                'stride', l.stride, ...
                'dilate', l.dilate, ...
                l.opts{:}, ...
                cudnn{:}) ;%disp(size(reh(i+1).y));
            
        case 'concat'
            if size(sigmas,1)~=size(res(i).x,1)
                sigmaMap   = bsxfun(@times,ones(size(res(i).x,1),size(res(i).x,2),1,size(res(i).x,4)),permute(sigmas,[3 4 1 2])) ;
                nsigmaMap   = bsxfun(@times,ones(size(ren(i).y,1),size(ren(i).y,2),1,size(ren(i).y,4)),permute(sigmas2,[3 4 1 2])) ;
                res(i+1).x = vl_nnconcat({res(i).x,sigmaMap}) ;%disp(size(res(i+1).x));
                ren(i+1).y = vl_nnconcat({ren(i).y,nsigmaMap}) ;%disp(size(ren(i+1).y)); 
                reh(i+1).z = vl_nnconcat({reh(i).z,nsigmaMap}) ;%disp(size(ren(i+1).y)); 
            else
                res(i+1).x = vl_nnconcat({res(i).x,sigmas}) ;%disp(size(res(i+1).x));
                ren(i+1).y = vl_nnconcat({ren(i).y,sigmas2}) ;%disp(size(ren(i+1).y)); 
                reh(i+1).z = vl_nnconcat({reh(i).z,sigmas2}) ;%disp(size(ren(i+1).y));                 
            end
            
        case 'SubP'
            res(i+1).x = vl_nnSubP(res(i).x, [],'scale',l.scale) ;%disp(size(res(i+1).x));
            ren(i+1).y = vl_nnSubP(ren(i).y, [],'scale',l.scale) ;%disp(size(ren(i+1).y));
            reh(i+1).z = vl_nnSubP(reh(i).z, [],'scale',l.scale) ;%disp(size(ren(i+1).y));
        case 'relu'
            leak = {} ;
            [res(i+1).x,ren(i+1).y,reh(i+1).z] = vl_nnrelu_new(i+1,res(i).x,ren(i).y,reh(i).z,[],leak{:}) ;%disp(size(res(i+1).x));
            
        case 'bnorm'
            res(i+1).x = vl_nnbnorm(res(i).x, l.weights{1}, l.weights{2}, ...
                'moments', l.weights{3}, ...
                'epsilon', l.epsilon, ...
                bnormCudnn{:}) ;
            ren(i+1).y = vl_nnbnorm(ren(i).y, l.weights{1}, l.weights{2}, ...
                'moments', l.weights{3}, ...
                'epsilon', l.epsilon, ...
                bnormCudnn{:}) ;
            reh(i+1).z = vl_nnbnorm(reh(i).z, l.weights{1}, l.weights{2}, ...
                'moments', l.weights{3}, ...
                'epsilon', l.epsilon, ...
                bnormCudnn{:}) ;            
    end
    
    % optionally forget intermediate results
    needsBProp = doder && i >= backPropLim;
    forget = opts.conserveMemory && ~needsBProp ;
    if i > 1
        lp = net.layers{i-1} ;
        % forget RELU input, even for BPROP
        forget = forget && (~needsBProp || (strcmp(l.type, 'relu') && ~lp.precious)) ;
        forget = forget && ~(strcmp(lp.type, 'loss') || strcmp(lp.type, 'softmaxloss')) ;
        forget = forget && ~lp.precious ;
    end
    if forget
        res(i).x = [] ;
        ren(i).y = [] ;
        reh(i).z = [];
    end
    
    if gpuMode && opts.sync
        wait(gpuDevice) ;
    end
    %res(i).time = toc(res(i).time) ;
end
