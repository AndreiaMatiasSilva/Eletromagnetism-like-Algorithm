function stop = emplotstopping(options,optimvalues,flag)
%EMPLOTSTOPPING PlotFcn to plot stopping criteria satisfaction.
%   STOP = EMPLOTSTOPPING(OPTIONS,OPTIMVALUES,FLAG) where OPTIMVALUES is a
%   structure with the following fields:
%              x: current point 
%           fval: function value at x
%          bestx: best point found so far
%       bestfval: function value at bestx
%      iteration: current iteration
%      funccount: number of function evaluations
%             t0: start time
%
%   OPTIONS: The options structure created by using EMOPTIMSET
%
%   FLAG: Current state in which PlotFcn is called. Possible values are:
%           init: initialization state
%           iter: iteration state
%           done: final state
%
%   STOP: A boolean to stop the algorithm.
%
%   Example:
%    Create an options structure that will use EMPLOTSTOPPING
%    as the plot function
%    options = emoptimset('PlotFcns',@emplotstopping);

stop = false;
% Calculate fraction of 'doneness' for each criterion
iter = optimvalues.iteration / options.MaxIter;
time = (cputime-optimvalues.t0) / options.TimeLimit;
func = optimvalues.funccount / options.MaxFunEvals;


% Multiply ratios by 100 to get percentages
ydata = 100 * [time, iter, func];

switch flag
    case 'init'
        barh(ydata,'Tag','emplotstopping')
        set(gca,'xlim',[0,100],'yticklabel', ...
            {'Time','Iteration', 'f-count'},'climmode','manual')
        xlabel('% of criteria met','interp','none')
        title('Stopping Criteria','interp','none')
    case 'iter'
        ch = findobj(get(gca,'Children'),'Tag','emplotstopping');
        set(ch,'YData',ydata);
end
