function [stop,optold,optchanged] = emoutput(OutputFcns,OutputFcnArgs,optimvalues,optold,flag)
%EMOUTPUT Helper function that manages the output functions.
%
%   [STATE, OPTNEW,OPTCHANGED] = EMOUTPUT(OPTIMVAL,OPTOLD,FLAG) runs each of
%   the output functions in the options.OutputFcn cell array.
%

% Initialize
stop   = false;
optchanged = false;

% Get the functions and return if there are none
if(isempty(OutputFcns))
    return
end

% Call each output function
for i = 1:length(OutputFcns)
   
    [stop ,optnew , changed ] = feval(OutputFcns{i},optold,optimvalues, ...
        flag,OutputFcnArgs{i}{:});
    if changed  % If changes are not duplicates, we will get all the changes
        optold = optnew;
        optchanged = true;
    end
end
% If any stop(i) is true we set the stop to true
stop = any(stop);