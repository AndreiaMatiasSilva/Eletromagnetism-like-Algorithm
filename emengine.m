function solverData = emengine(solverData,problem,options)
% EMENGINE does the following
%    - check to see if the algorithm is done
%    - call the hybrid search
%    - update solver data
%    - call output and plot functions
%  Until solverData.running is set to false

fname = 'eletromagnetism-like algorithm';


for i=1:options.NumberPopulation
    %randomly generate point
    solverData.x0(i,:)=problem.lb + (problem.ub - problem.lb).*rand(1,problem.nvar);
end;

if  options.Verbosity > 1
    fprintf('\n                            Best          ');
    fprintf('\nIteration   f-count         f(x)          \n');
end

  %compute objective function and best point of population
   ind_best=1;
   for i=1: 1.0: options.NumberPopulation
         % compute objective function 
            solverData.Fobj(i)=problem.objective(solverData.x0(i,:));   
            solverData.funccount = solverData.funccount + 1;         
     % compute index of best point 
        if (solverData.Fobj(i) < solverData.Fobj(ind_best))
            ind_best=i;  
        end
   end   
   
   solverData.currentbestfval=solverData.Fobj(ind_best);
   solverData.currentbestx=solverData.x0(ind_best,:);
   solverData.bestfval= solverData.currentbestfval;
   solverData.bestx=solverData.currentbestx;
   solverData.meanf=solverData.bestfval;
   optimvalues.meanf=solverData.bestfval;

while solverData.running 
    
    % compute charges, forces and move points
    [solverData.x0] = Calc_Force_Move(solverData.x0, solverData.Fobj, options.NumberPopulation, problem.nvar, ind_best, problem.ub,problem.lb);

   %compute objective function and best point of population
   old_best=ind_best;
   ind_best=1;
   for i=1: 1.0: options.NumberPopulation
       % compute objective function 
            solverData.Fobj(i)=problem.objective(solverData.x0(i,:));   
            if (i~= old_best)
                solverData.funccount = solverData.funccount + 1;    
            end
     % compute index of best point 
        if (solverData.Fobj(i) < solverData.Fobj(ind_best))
            ind_best=i;  
        end
   end

   % ana
   solverData.currentbestfval=solverData.Fobj(ind_best);
   solverData.currentbestx=solverData.x0(ind_best,:);
   
   %CALCULO DO LOCAL DO BEST
   [solverData] = local_to_best(options,solverData,problem);
   
   solverData.Fobj(ind_best)=solverData.currentbestfval;
   solverData.x0(ind_best,:)=solverData.currentbestx;
   optimvalues.currentbestx=solverData.currentbestx;
   optimvalues.currentbestfval=solverData.currentbestfval;
    solverData.bestx=solverData.currentbestx;
    solverData.bestfval=solverData.currentbestfval;
    optimvalues.bestx=solverData.bestx;
    optimvalues.bestfval=solverData.bestfval;
    
 
   if(solverData.currentbestfval < solverData.bestfval)
%         optimvalues.bestx=solverData.bestx;
%         optimvalues.bestfval=solverData.bestfval;
        % ana
        solverData.bestx=solverData.currentbestx;
        solverData.bestfval=solverData.currentbestfval;
        optimvalues.bestx=solverData.bestx;
        optimvalues.bestfval=solverData.bestfval;
   end
   solverData.meanf=solverData.bestfval;
   
   
   if(solverData.iteration==1)
     % Call output/plot functions with 'init' state
     callOutputPlotFunctions('init');
   end
   

       if ~solverData.running, break; end
         % Call hybrid functions if any
          solverData = emhybrid(solverData,problem,options);
          solverData = emupdates(solverData,options);
          
        % Check termination criteria and print iterative display
         solverData = emcheckexit(solverData,problem,options);

        % Call output/plot functions with 'iter' state
        callOutputPlotFunctions('iter');
   
end

  
   

% Call hybrid functions at the end if any
if isempty(options.HybridInterval)
    options.HybridInterval = solverData.iteration;
    solverData = emhybrid(solverData,problem,options);
end

% Call output/plot functions with 'done' state
   callOutputPlotFunctions('done');

% If verbosity > 0 then print termination message
if options.Verbosity > 0
    fprintf('%s\n',solverData.message)
end
% Print diagnostic information if asked
if options.Verbosity > 2
    emdiagnose(user_options,problem);
end

%-----------------------------------------------------------------
% Nested function to call output/plot functions
    function callOutputPlotFunctions(state)
% Prepare data to be sent over to plot/output functions
        optimvalues = emoptimStruct(solverData);
        switch state    
            case {'init','iter'}
                 options.OutputFcnArgs=10;
                [solverData.stopOutput,options,optchanged] = emoutput(options.OutputFcns,options.OutputFcnArgs, ...
                    optimvalues,options,state);
                
                solverData.stopPlot = gadsplot(options,optimvalues,state,fname);
                if optchanged % Check options
                    options = emvalidate(options,problem);
                end
            case 'done'
            emoutput(options.OutputFcns,options.OutputFcnsArgs,optimvalues,options,state);
            solverData.stopPlot = gadsplot(options,optimvalues,state,fname);
        end
    end
end

