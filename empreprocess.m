function [output,solverData,problem,options]=...
    empreprocess(FUN,lb,ub,options,defaultopt)

%A function string
if ischar(FUN) 
    FUN=str2func(FUN);
end

% Only function_handle are allowed
if isempty(FUN) ||  ~isa(FUN,'function_handle')
    error(message('globaloptim:empreprocess:needFunctionHandle'));
end

% Use default options if empty
if ~isempty(options) && ~isa(options,'struct')
    error(message('globaloptim:empreprocess:fourthInputNotStruct'));
elseif isempty(options)
    options = defaultopt;
end

% All inputs should be double
try
    dataType = superiorfloat(lb,ub);
    if ~isequal('double', dataType)
        error(message('globaloptim:empreprocess:dataType'))
    end
catch
    error(message('globaloptim:empreprocess:dataType'))
end


numberOfVariables = length(lb);

% Get all default options and merge with non-default options
options = emoptimset(defaultopt,options);

%Initialize the output values
output.iterations = 0;
output.funccount  = 0;
output.message    = '';
output.totaltime  = 0;
dflt = RandStream.getGlobalStream;
output.rngstate = struct('state',{dflt.State}, 'type',{dflt.Type});

% Initialize data structures for problem and also for solver state
problem = struct('objective', FUN, 'nvar', numberOfVariables);
solverData  = struct('t0',cputime);

% Call emvalidate to ensure that all the fields of options are valid
options = emvalidate(options,problem);

problem.lb = lb; 
problem.ub = ub;

% Make sure the problem is not unbounded
if min(ub)==Inf && max(lb)==-Inf
    problem.bounded = false;
else
    if strcmpi(options.DataType,'custom')
        problem.bounded = false;
        if options.Verbosity > 0
            warning(message('globaloptim:emalgorithm:boundsWithCustom'));
        end
    else
        problem.bounded = true;
    end
end

% Determine problemtype
if problem.bounded
    output.problemtype = 'boundconstraints';
else
    output.problemtype = 'unconstrained';
end


% Additional fields for solver parameters need initialization
solverData.currentfval(1:options.NumberPopulation)=0.0;% 
solverData.running = true;
solverData.stopPlot = false;
solverData.stopOutput = false;
solverData.message = '';
solverData.acceptanceCounter = 1;
solverData.funccount = 0;
solverData.iteration = 0;
solverData.bestfvals=[];
solverData.meanf=0;




