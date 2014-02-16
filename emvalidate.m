function options  = emvalidate(options,problem)
% EMVALIDATE is used to ensure that the options structure for a
% ELETROMAGNETISM_LIKE.
%   problem is valid and each field in it has an acceptable type.
%
%   This function is private to ELETROMAGNETISM_LIKE.


% Sanity check for the options structure
options = emoptimset(options);

% Determine the verbosity // Default - final 
switch  options.Display
    case {'off','none'}
        options.Verbosity = 0;
    case 'final'
        options.Verbosity = 1;
    case 'iter'
        options.Verbosity = 2;
    case 'diagnose'
        options.Verbosity = 3;
    otherwise
        options.Verbosity = 1;
end

% NumberPopulation default value is string
if strcmpi(options.NumberPopulation,'10*numberofvariables')
    options.NumberPopulation = 10*problem.nvar;
end

% MaxFunEvals default value is string
if strcmpi(options.MaxFunEvals,'3000*numberofvariables')
    options.MaxFunEvals = 3000*problem.nvar;
end

% StallIterLimit default value is string
if strcmpi(options.StallIterLimit,'500*numberofvariables')
    options.StallIterLimit = 500*problem.nvar;
end

% MaxLocalIterations default value is string
if strcmpi(options.MaxLocalIterations,'5')
    options.MaxLocalIterations = 5;
end 

if strcmpi(options.HybridInterval, 'end')
    options.HybridInterval = [];
elseif strcmpi(options.HybridInterval, 'never')
    options.HybridFcn = [];
elseif isempty(options.HybridInterval)
else
    nonNegInteger('HybridInterval', options.HybridInterval)
end

positiveInteger('NumberPopulation', options.NumberPopulation);
positiveInteger('StallIterLimit', options.StallIterLimit);
positiveInteger('MaxIter', options.MaxIter);
positiveInteger('MaxFunEvals', options.MaxFunEvals);

positiveScalar('TimeLimit', options.TimeLimit);
realScalar('ObjectiveLimit', options.ObjectiveLimit);

nonNegInteger('DisplayInterval', options.DisplayInterval);
nonNegInteger('PlotInterval', options.PlotInterval);

nonNegScalar('TolFun',options.TolFun);


if ~isempty(options.HybridFcn)
    [options.HybridFcn,options.HybridFcnArgs] = functionHandleOrCell('HybridFcn',options.HybridFcn);
end

% this special case takes an array of function cells
[options.PlotFcns,options.PlotFcnsArgs] = functionHandleOrCellArray('PlotFcns',options.PlotFcns);
[options.OutputFcns,options.OutputFcnsArgs] = functionHandleOrCellArray('OutputFcns',options.OutputFcns);


