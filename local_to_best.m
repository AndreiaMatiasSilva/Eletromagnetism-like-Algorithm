%% procedure LOCAL to make a refinement arounf best point
%%% Local algorithm applied only to the best point
function [solverData]=local_to_best(options,solverData,problem)

    length_local=options.Delta*max(problem.ub - problem.lb); 
             
    for k=1:length(problem.lb)     % for all dimensions 
       iter_local=1;
       lambda1=rand(1);
       flag=1;
  
       while (iter_local < options.MaxLocalIterations) 
           trial_best=solverData.currentbestx;
           lambda2=rand(1);
          
           if (lambda1 > 0.5) 
               if (trial_best(k)+lambda2*length_local < problem.ub(k))	
                   trial_best(k)=trial_best(k)+lambda2*length_local;
               else 
                 flag=0;
               end
           else  
               if (trial_best(k)-lambda2*length_local > problem.lb(k))	
                   trial_best(k)=trial_best(k)-lambda2*length_local;
               else
                 flag=0;
               end
           end
         
           if(flag==1)
                 F_trial=problem.objective(trial_best);   
                 solverData.funccount = solverData.funccount + 1;
               %%% selection mechanism - test trial e best
                 if (F_trial < solverData.currentbestfval)  
                       solverData.currentbestx = trial_best;
                       solverData.currentbestfval = F_trial;
                  else
                       iter_local=options.MaxLocalIterations-1;
                  end
              
               %end of selection mechanism //////////////
           end;
        
           iter_local=iter_local+1;

         end
    end
        
       
end