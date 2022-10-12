classdef ndfor < handle
%
% iter = ndfor(sz1,sz2,...)
% Creates a handle object to iterate through arbitrary number of dimensions
% Usage is similar to Python generator
% 
% Public Methods
%     numel(iter)    : returns number of elements to iterate through
%     size(iter)     : returns number of elements along each dimension
%     length(iter)   : returns max(size(iter))
%     logical(iter)  : true if iteration is still incomplete
%     next(iter)     : returns next set of indices as multiple outputs
%     nextmat(iter)  : returns next set of indices in single array
% Public Properties
%     N              : equivalent to numel(iter) 
%     ndim           : number of dimensions overwhich to iterate
%
%
% Example usage:
%     iter = ndfor(sz1,sz2,...);
%     while iter
%         [ii,jj,...] = next(iter); % inds is equivalent to output of ind2sub
%         ... % do something with each index
%     end
%
properties (SetAccess=immutable)
    ndim
    N
end

properties (Access=private)
    sz
    counter
    div
end

methods (Access=public)
    function obj = ndfor(sz)
        arguments (Repeating)
            sz (1,1) double {mustBeInteger}
        end
        if isempty(sz)
            aac = matlab.lang.correction.AppendArgumentsCorrection('sz1,sz2');
            error(aac, 'MATLAB:notEnoughInputs', 'Not enough input arguments.')   
        end
        obj.sz = cell2mat(sz);
        obj.ndim = numel(sz);

        obj.N = prod( obj.sz );
        obj.div = zeros(1,obj.ndim);
        obj.div(1) = 1;
        for ii = 2:obj.ndim
            obj.div(ii) = obj.sz(ii-1)*obj.div(ii-1);
        end
        obj.counter = 0;
    end
    function N = numel(obj)
        N = obj.N;
    end
    function sz = size(obj)
        sz = obj.sz;
    end
    function L = length(obj)
        L = max(size(obj));
    end
    function varargout = next(obj)
        % returns next set of indices as separate return objects
        out = indToSub(obj);
        obj.counter = obj.counter + 1;
        varargout = num2cell(out); 
    end
    function var = nextmat(obj)
        % returns next set of indices as signle row vector
        var = indToSub(obj);
        obj.counter = obj.counter + 1;
        % var = cell2mat(out);
    end
    function reset(obj)
        obj.counter = 0;
    end
    function out = logical(obj)
        out = (obj.counter < obj.N);
    end
end
methods (Access=private)
    function sub = indToSub(obj)        
        sub = mod(floor((obj.counter) ./ obj.div),obj.sz)+1;
    end
end
end



