% emalgorithm is the Electromagnetism-like algorithm  is a population based  
% metaheuristic to optimize bound-constrained optimization 
% problems, and it attempts to solve problems of the form:
%           
%            min F(X)  subject to  LB <= X <= UB
%
%
%    X =  emalgorithm(FUN,LB,UB) minimizes with the default
%    optimization parameters.
%    See EMOPTIMSET for details.  
%
%    X = emalgorithm(FUN,LB,UB,options) minimizes with the default
%    optimization parameters replaced by values in the structure OPTIONS.
%    OPTIONS can be created with the EMOPTIMSET function. See EMOPTIMSET for
%    details. 
%   
%    X =  emalgorithm(PROBLEM) finds the minimum for PROBLEM. PROBLEM is
%    a structure that has the following fields:
%       objective: <Objective function>
%              lb: <Lower bound on X>
%              ub: <Upper bound on X>
%         options: <options structure created with EMOPTIMSET>
%
%    [X, FVAL] =  emalgorithm(FUN,LB,UB,...) returns XBEST, which is
%    the point that has least objective function and FBEST is the
%    corresponding function value.
%
%    [X,FVAL, EXITFLAG] = emalgorithm(FUN, ...) returns EXITFLAG which
%    describes the exit condition of emalgorithm. Possible values of
%    EXITFLAG and the corresponding exit conditions are
% 
%    1 Average change in value of the objective function over
%     options.StallIterLimit iterations less than options.TolFun.
%     5 options.ObjectiveLimit limit reached.
%     0 Maximum number of function evaluations or iterations exceeded.
%    -1 Optimization terminated by the output or plot function.
%    -5 Time limit exceeded.
%
%   [X,FVAL,EXITFLAG,OUTPUT] = emalgorithm(FUN, ...) returns a
%   structure OUTPUT with the following information:
%      problemtype: Type of problem: unconstrained or bound constrained
%       iterations: Total iterations
%        funccount: Total function evaluations
%          message: Termination message of the solver
%        totaltime: Time taken by the solver
%
%
%    Examples:
%     Minimization of Dejong's fifth function 
% 
%      fun = @dejong5fcn;
%      lb = [-64 -64];
%      ub = [64 64];
%
%      [fbest,xbest]  = emalgorithm(fun,lb,ub)
%  
%     


function [x,fval,exitflag,output]=emalgorithm(FUN,lb,ub,options)


% Check number of input arguments
errmsg = nargchk(1,5,nargin);

if ~isempty(errmsg)
    error(message('globaloptim:emalgorithm:numberOfInputs', errmsg));
end

if nargin < 4
    options = [];
end


% One input argument is for problem structure
if nargin == 1
    if isa(FUN,'struct')
        [FUN,lb,ub,rngstate,options] = separateOptimStruct(FUN);
        % Reset the random number generators
        resetDfltRng(rngstate);
    else % Single input and non-structure.
       error(message('globaloptim:emalgorithm:invalidStructInput'));
    end
end

defaultopt=struct( 'NumberPopulation','10*numberOfVariables', ...
                'TolFun',1e-6,...
                'StallIterLimit','500*numberOfVariables',...
                'MaxFunEvals','3000*numberOfVariables',...
                'MaxIter',Inf, ...
                'MaxLocalIterations','5', ...
                'TimeLimit',Inf,...
                'ObjectiveLimit',-Inf,...
                'Delta', 1e-3,...
                'PrecisionTolerance',1e-3,...
                'Display', 'final', ...
                'DisplayInterval', 10, ...
                'HybridFcn', [], ...
                'HybridInterval', 'end', ...
                'PlotFcns', [], ...
                'PlotInterval', 1, ...
                'OutputFcns', {[]}, ...
                'DataType', 'double');


    % If just 'defaults' passed in, return the default options in X
    if nargin == 3 && nargout <= 1 && isequal(FUN,'defaults')
       x = defaultopt; % returns defaults for EM
       return
    end
    
    if(nargin<4)
        options=[];
    end


    % Preprocess all inputs, validate options, create solver data
    [output,solverData,problem,options] = ...
        empreprocess(FUN,lb,ub,options,defaultopt);
    
    % Call emengine to do the actual algorithm

    solverData = emengine(solverData,problem,options);
    
    
    % Prepare output arguments
    x = solverData.bestx;
    fval = solverData.bestfval;
    exitflag = solverData.exitflag;
    
    % Solver may terminate in preprocessing phase
    if exitflag < 0
     return;
    end 
    
    % Finish the output structure
    output.iterations = solverData.iteration;
    output.funccount = solverData.funccount;
    output.totaltime = cputime - solverData.t0;
    output.message = solverData.message;
end
