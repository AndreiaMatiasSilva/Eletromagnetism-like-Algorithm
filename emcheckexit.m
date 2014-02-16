function solverData = emcheckexit(solverData,problem,options)
%EMCHECKEXIT is used to determine whether or not Eletromagnetism-like algorithm should
%   terminate its run.  The function iterates through each stopping
%   criterion and if it has been met then the appropriate  exitflag and
%   message are set.
%   This function is private to ELETROMAGNETISM-LIKE AlGORITHM.
% Iterate through the exit criteria and check to see if any of them have
% been met.
% If an exit criterion has been met then set the appropriate exit flag and
% exit message and set data.running to false.
% If the display is on iterative mode or higher and it is time to do so,
% display relevant data
%
% Setup display header every thirty iterations


if options.Verbosity > 1 
   if mod(solverData.iteration,options.DisplayInterval)==0 || ...
            solverData.iteration == options.MaxIter 
  fprintf('%s %5.0f %5.0f   %12.6g   \n',' ', ...
          solverData.iteration,solverData.funccount,solverData.bestfval);
   end
end

if  solverData.stopPlot || solverData.stopOutput
    solverData.running = false;
    solverData.exitflag = -1;
    solverData.message = sprintf('Stop requested.');
    return;
end

% Compute change in bestfval and individuals in last options.StallIterLimit
% iterations
funChange = Inf;
if solverData.iteration >= options.StallIterLimit
    bestfvals =  solverData.bestfvals;
    funChange = sum(abs(diff(bestfvals)));
end

if funChange <= options.TolFun
        solverData.running = false;
        msg =  sprintf('%s', 'Optimization terminated: ');
        solverData.message = [msg,sprintf('%s', 'change in best function value less than options.TolFun.')];
        solverData.exitflag = 1;
    return;
end

if solverData.iteration > options.MaxIter
    solverData.running = false;
    solverData.exitflag = 0;
    msg =  sprintf('%s', 'Maximum number of iterations exceeded: ');
    solverData.message = [msg,sprintf('%s', 'increase options.MaxIter.')];
    return;
end

if solverData.funccount > options.MaxFunEvals
    solverData.running = false;
    solverData.exitflag = 0;
    msg = sprintf('%s', 'Maximum number of function evaluations exceeded:');
    solverData.message = [msg, sprintf('%s', 'increase options.MaxFunEvals.')];
    return;
end

if cputime - solverData.t0 > options.TimeLimit
    solverData.running = false;
    solverData.exitflag = 5;
    msg = sprintf('%s', 'Time limit exceeded: ');
    solverData.message = [msg, sprintf('%s', 'increase options.TimeLimit.')];
    return;
end

if solverData.bestfval <= options.ObjectiveLimit
    solverData.running = false;
        solverData.exitflag = 5;
        msg =  sprintf('%s', 'Optimization terminated: ');
        solverData.message = [msg,sprintf('%s','best function value reached options.ObjectiveLimit.')];
    return;
end

if options.Verbosity > 1 && mod(solverData.iteration,options.DisplayInterval*30)==0 && ...
        solverData.iteration >0 && solverData.iteration < options.MaxIter
    fprintf('\n                           Best     ');
    fprintf('\nIteration   f-count         f(x)     \n' );
end
