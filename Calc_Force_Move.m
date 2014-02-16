%% Calc_Force_Move procedure - Electromagnetic Algoritm
%%% 
%%% First compute charges of points, then compute forces and then the
%%% movement of each point
%%% input:
%%% Point --> vector of variables with dimension N  
%%% Fobj --> objective function value of  point
%%% viol --> vector with violation of each point
%%% NUMBER_POP --> number of points in the population
%%% N --> dimension of vector point
%%% fbest --> best objective function value 
%%% ind_best --> index of the Point with best objective function value
%%% Upper ---> Upper bound values - vector dimension N
%%% Lower ---> Lower bound values
%%% out:
%%% Point --> new vector of variables with dimension N  (after moving)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%% compute charge of the Point
function [Point] = Calc_Force_Move(Point, F_Best, NUMBER_POP, N, ind_best, Upper, Lower)

%%% initializing each Force to zero
Force(1:NUMBER_POP,1:N)=0;    

% calc of Sum(abs(f(x)-fbest))
aux_sum = sum(abs(F_Best - F_Best(ind_best)));

%% compute charges
aux_exp = -N*abs(F_Best-F_Best(ind_best))/aux_sum;
q = exp(aux_exp);     

%%%%%%%%%%%%%%%%
%% compute Total Force of each Point
for i=1: 1.0: NUMBER_POP   
    for j=1: 1.0: NUMBER_POP        
        if(i~=j)
            aux_norm = norm(Point(j,:)-Point(i,:),2);%(xj-xi);
            if (aux_norm > 1e-20)
                if (F_Best(j)<F_Best(i))    
                    %%% attraction force
                    Force(i,:) = Force(i,:) + (Point(j,1:N)-Point(i,1:N))*(q(i)*q(j)/(aux_norm^3));               
                else
                    %%% repulsion force
                    Force(i,:) = Force(i,:) - (Point(j,1:N)-Point(i,1:N))*(q(i)*q(j)/(aux_norm^3));
                end %if
            end
        end %if
    end %for
 end  %for
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Moves each Point towards the direction of the best point 
% according to the Force calculated for each point 

for i=1 : NUMBER_POP
    if (i~=ind_best)    % move all points except best point
        normaF = norm(Force(i,:),2);  
        if (normaF > 1e-20)
            for k=1: N
                aux_lamb = rand(1);
                if (Force(i,k)>0)
                     Point(i,k) = Point(i,k) + aux_lamb* (Force(i,k)/normaF)*(Upper(k) - Point(i,k));
                 else
                     Point(i,k) = Point(i,k) + aux_lamb* (Force(i,k)/normaF)*(Point(i,k) - Lower(k));
                end
            end        
        end
   end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%