function optimvalues = emoptimStruct(solverData)
%emoptimStruct create a structure to be passed to user functions
%   OPTIMVALUES = emoptimStruct(solverData,problem) creates a structure
%   OPTIMVALUES with the following fields:
%   currentbestx: current best point 
%currentbestfval: current best function value at x
%          bestx: best point found so far
%       bestfval: function value at bestx
%      iteration: current iteration
%      funccount: number of function evaluations
%             t0: start time
%
%   PROBLEM is a structure with the following fields:
%      objective: function handle to the objective function
%             lb: lower bound on decision variables
%             ub: upper bound on decision variables
%

%   This function is private to EMALGORITHM.


optimvalues.currentbestx = solverData.currentbestx;
optimvalues.currentbestfval = solverData.currentbestfval;

if(solverData.iteration == 1)
    optimvalues.bestx=  solverData.currentbestx;
    optimvalues.bestfval=  solverData.currentbestfval;
else    
    optimvalues.bestx=  solverData.bestx;
    optimvalues.bestfval=  solverData.bestfval;
end

optimvalues.iteration = solverData.iteration;
optimvalues.funccount = solverData.funccount;
optimvalues.t0 = solverData.t0;
optimvalues.meanf = solverData.meanf;
