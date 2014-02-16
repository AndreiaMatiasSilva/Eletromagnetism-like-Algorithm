function solverData = emupdates(solverData,options)
%EMUPDATES is used to update values during runs of ELETROMAGNETISM_LIKE. It updates
%   the counters
%   (used with TolX/TolFun) and the global best values.
%   This function is private to ELETROMAGNETISM_LIKE ALGORITHM.
  
    
   % Update the global best point and value if appropriate
    if  solverData.bestfval > solverData.currentbestfval
        solverData.bestx = solverData.currentbestx;
        solverData.bestfval = solverData.currentbestfval;  
    end
    solverData.bestfvals(end+1) = solverData.currentbestfval;
    % Restrict the length of solverData.bestfvals to StallIterLimit
    if solverData.iteration > options.StallIterLimit
     solverData.bestfvals(1) = [];
    end


% Increment solverData.iter counter
solverData.iteration = solverData.iteration+1;
solverData.meanf = solverData.meanf + (solverData.bestfval - solverData.meanf/(solverData.iteration));

