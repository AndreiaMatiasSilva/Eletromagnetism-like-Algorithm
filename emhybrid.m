function solverData = emhybrid(solverData,problem,options)
%EMHYBRID is used to call the hybrid function (if there is one) every
%   options.HybridInterval iterations.  It also makes sure that
%   constrained or unconstrained problems do not get passed to solvers
%   that cannot handle them.
%
%   This function is private to ELETROMAGNETISM-LIKE ALGORITHM.
%   Copyright 2006-2010 The MathWorks, Inc.
%

if isempty(options.HybridFcn)
    return;
end

if isempty(options.HybridInterval) || ...
        ~(mod(solverData.iteration,options.HybridInterval)==0)
    return;
end

if isequal(options.HybridFcn,@patternsearch) && isempty(options.HybridFcnArgs)
    args = emptimset;
elseif isequal(options.HybridFcn,@fmincon) && isempty(options.HybridFcnArgs)
    args = emptimset('Algorithm','active-set');
elseif isequal(options.HybridFcn,@fminunc) && isempty(options.HybridFcnArgs)
    args = emptimset('LargeScale','off');
elseif  isempty(options.HybridFcnArgs)
    args = emptimset;
else
    args = options.HybridFcnArgs{:};
end

% Who is the hybrid function
hybridFcn = fcnchk(options.HybridFcn);
hfunc = func2str(hybridFcn);

% Inform about hybrid scheme
if  options.Verbosity > 1
    fprintf('%s%s%s\n','Switching to the hybrid optimization algorithm (',upper(hfunc),').');
end
fun = problem.objective;
lb = problem.lb;
ub = problem.ub;
% Determine which syntax to call
switch hfunc
    case 'fminsearch'
        if problem.bounded
            warning(message('globaloptim:emhybrid:unconstrainedHybridFcn', ... 
                upper(hfunc),'PATTERNSEARCH'));
            hybridFcn = @patternsearch;
            args = psoptimset;
            [xx,ff,~,o] = hybridFcn(fun,x0,[],[],[],[],lb,ub,[],args);
            solverData.funccount = solverData.funccount + o.funccount;
            solverData.message   = [solverData.message sprintf('\nPATTERNSEARCH: \n'), o.message];
            if isfield(o, 'maxconstraint')
                conviol = o.maxconstraint;
            else
                conviol = [];
            end
            hybridPointFeasible = isHybridPointFeasible(conviol, 'patternsearch', args);
        else
            [xx,ff,~,o] = hybridFcn(fun,x0,args);
            solverData.funccount = solverData.funccount + o.funcCount;
            solverData.message   = [solverData.message sprintf('\nFMINSEARCH:\n'), o.message];
            hybridPointFeasible = true;            
        end
    case 'patternsearch'
        [xx,ff,~,o] = hybridFcn(fun,x0,[],[],[],[],lb,ub,[],args);
        solverData.funccount = solverData.funccount + o.funccount;
        solverData.message   = [solverData.message sprintf('\nPATTERNSEARCH: \n'), o.message];
        % Since we are always calling bound-constrained patternsearch
        % solver, the output structure will always have 'maxconstraint'
        % field. 
        conviol = o.maxconstraint;
        hybridPointFeasible = isHybridPointFeasible(conviol, 'patternsearch', args);
    case 'fminunc'
        if problem.bounded
            warning(message('globaloptim:emhybrid:unconstrainedHybridFcn', ... 
                upper(hfunc),'FMINCON'));
            hybridFcn = @fmincon;
            args = optimset('Algorithm','active-set');
            [xx,ff,~,o] = hybridFcn(fun,x0,[],[],[],[],lb,ub,[],args);
            hybridPointFeasible = isHybridPointFeasible(o.constrviolation, 'fmincon', args);
        else
            [xx,ff,~,o] = hybridFcn(fun,x0,args);
            hybridPointFeasible = true;
        end
        solverData.funccount = solverData.funccount + o.funcCount;
        solverData.message   = [solverData.message sprintf('\nFMINUNC: \n'), o.message];
    case {'fmincon'}
        if ~problem.bounded
            warning(message('globaloptim:emhybrid:constrainedHybridFcn', ...
                upper(hfunc),'FMINUNC'));
            hybridFcn = @fminunc;
            args = optimset('LargeScale','off');
            [xx,ff,~,o] = hybridFcn(fun,x0,args);
            hybridPointFeasible = true;
        else
            [xx,ff,~,o] = hybridFcn(fun,x0,[],[],[],[],lb,ub,[],args);
            hybridPointFeasible = isHybridPointFeasible(o.constrviolation, 'fmincon', args);            
        end
        solverData.funccount = solverData.funccount + o.funcCount;
        solverData.message   = [solverData.message sprintf('\nFMINUNC: \n'), o.message];
    otherwise
        error(message('globaloptim:sahybrid:hybridFcnError','@FMINSEARCH, @FMINUNC, @FMINCON, @PATTERNSEARCH'))
end

% Determine feasibility of point returned from simulated annealing. The
% point should always be feasible if the built in operators are used, but
% could be infeasible if a user specifies their own.
emPointFeasible = isTrialFeasible(solverData.bestx(:), [], [], [], [], lb, ub);

% Test whether hybrid point should be used
if hybridPointFeasible && (~emPointFeasible || ff < solverData.bestfval)
    solverData.bestfval = ff;
    solverData.bestx = xx;
end
% Inform about hybrid scheme termination
if  options.Verbosity > 0 && strcmpi(args.Display,'off')
    fprintf('%s%s\n',upper(hfunc), ' terminated.');
end