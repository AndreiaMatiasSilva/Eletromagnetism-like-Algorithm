function stop = emplotbestf(options,optimvalues,flag)
%EMPLOTBESTF PlotFcn to plot best function value.
%   STOP = EMPLOTBESTF(OPTIONS,OPTIMVALUES,FLAG) where OPTIMVALUES is a
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
%    Create an options structure that will use EMPLOTBESTF
%    as the plot function
%     options = emoptimset('PlotFcns',@emplotbestf);

stop = false;
switch flag
    case 'init'
        plotBest = plot(optimvalues.iteration,optimvalues.bestfval, '.b');
        set(plotBest,'Tag','emplotbestf');
        xlabel('Iteration','interp','none');
        ylabel('Function value','interp','none')
        title(sprintf('Best Function Value: %g',optimvalues.bestfval),'interp','none');
    case 'iter'
        plotBest = findobj(get(gca,'Children'),'Tag','emplotbestf');
        newX = [get(plotBest,'Xdata') optimvalues.iteration];
        newY = [get(plotBest,'Ydata') optimvalues.bestfval];
        set(plotBest,'Xdata',newX, 'Ydata',newY);
        set(get(gca,'Title'),'String',sprintf('Best Function Value: %g',optimvalues.bestfval));
end
