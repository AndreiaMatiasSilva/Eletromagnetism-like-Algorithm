function o = emoptimget(options,name,default)
%EMOPTIMGET Get EM OPTIONS parameter value.
%   VAL = EMOPTIMGET(OPTIONS,'NAME') extracts the value of the named parameter
%   from optimization options structure OPTIONS, returning an empty matrix if
%   the parameter value is not specified in OPTIONS.  It is sufficient to
%   type only the leading characters that uniquely identify the
%   parameter.  Case is ignored for parameter names.  [] is a valid OPTIONS
%   argument.
%   
%   VAL = EMOPTIMGET(OPTIONS,'NAME') extracts the parameter NAME 
%   For example:
%     
%     opts = emoptimset('NumberPopulation',20);
%     val = emoptimget(opts,'NumberPopulation');
%   
%   returns val = 20.
%   
%   See also EMOPTIMSET.
%
%   Copyright 2013 Ana Rocha e Andreia Silva, Inc.
%   $Revision: 30.06.2013 $  $Date: 2012/05/08 20:25:58 $



if nargin < 2
  error(message('EMOPTIMGET:inputarg'));
end
if nargin < 3
  default = [];
end
if nargin < 4
   flag = [];
end

if ~isempty(options) && ~isa(options,'struct')
  error('No input args!');
end

if isempty(options)
  o = default;
  return;
end


Return options with default values and return it when called with one output argument
options=struct( 'NumberPopulation',[], ...
                'MaxIter',[], ...
                'MaxLocalIterations', [], ...
                'Delta', [],...
                'PrecisionTolerance',[],...
                'StallIterLimit',[],...
                'ObjectiveLimit',[],...
                'TolFun',[],...
                'MaxFunEvals',[],...
                'TimeLimit',[],...
                'Display',[],...
                'DisplayInterval',[],...
                'HybridFcn',[],...
                'HybridInterval',[],...
                'PlotFcns',[],...
                'PlotInterval',[],...
                'OutputFcns',[],...
                'DataType',[]);
            

%get names
Names = fieldnames(optionsstruct);

names = lower(Names);

lowName = lower(name);
j = strmatch(lowName,names);

%See if there all options are valids

if isempty(j) % if no matches
  error('The options names are not valid!');
elseif length(j) > 1            % if more than one match
  % Check for any exact matches (in case any names are subsets of others)
  k = strmatch(lowName,names,'exact');
  if length(k) == 1
    j = k;
  else
    allNames = ['(' Names{j(1),:}];
    for k = j(2:length(j))'
      allNames = [allNames ', ' Names{k,:}];
    end
    allNames = sprintf('%s).', allNames);
    error('Those are not valid options names!', allNames);
  end
end

if any(strcmp(Names,Names{j,:}))
   o = options.(Names{j,:});
  if isempty(o)
    o = default;
  end
else
  o = default;
end

end








