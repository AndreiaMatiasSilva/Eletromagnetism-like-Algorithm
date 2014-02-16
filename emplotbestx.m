function stop = emplotbestx(options,optimvalues,flag)
%EMPLOTBESTX PlotFcn to plot current best X value.
%   STOP = EMPLOTBESTX(OPTIONS,OPTIMVALUES,FLAG) where OPTIMVALUES is a
%   structure with the following fields:
%           currentfval: function value at x
%          currentbestx: best point found so far
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
%    Create an options structure that will use EMPLOTBESTX as the plot
%    function
%     options = emoptimset('PlotFcns',@emplotbestx);

stop = false;
switch flag
    case 'init'
        set(gca,'xlimmode','manual','zlimmode','manual', ...
            'alimmode','manual')
        title('Best point','interp','none')
        Xlength = numel(optimvalues.bestx);
        xlabel(sprintf('Number of variables (%i)',Xlength),'interp','none');
        ylabel('Best point','interp','none');
        plotBestX = bar(optimvalues.bestx(:));
        set(plotBestX,'Tag','emplotbestx');
        set(plotBestX,'edgecolor','none')
        set(gca,'xlim',[0,1 + Xlength])
    case 'iter'
        plotBestX = findobj(get(gca,'Children'),'Tag','emplotbestx');
        set(plotBestX,'Ydata',optimvalues.bestx(:))
end