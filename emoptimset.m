function options = emoptimset(varargin)
%EMOPTIMSET Create/alter EM OPTIONS structure.
%   EMOPTIMSET returns a listing of the fields in the options structure as
%   well as valid parameters and the default parameter.
%   
%   OPTIONS = EMOPTIMSET('PARAM',VALUE) creates a structure with the
%   default parameters used for all PARAM not specified, and will use the
%   passed argument VALUE for the specified PARAM.
%
%   OPTIONS = EMOPTIMSET('PARAM1',VALUE1,'PARAM2',VALUE2,....) will create a
%   structure with the default parameters used for all fields not specified.
%   Those FIELDS specified will be assigned the corresponding VALUE passed,
%   PARAM and VALUE should be passed as pairs.
%
%
%EMOPTIMSET PARAMETERS
%   
%   NumberPopulation    - Define Population Size
%                       [ positive scalar | 10* numberOfVariables]
%   MaxIter             - Number of Function Evaluations
%                       [ positive scalar | 30* numberOfVariables  ]
%   MaxLocalIterations  - Maximum number of local iterations
%                       [ positive scalar | 10*numberOfVariables ]
%   Delta               - A positive scalar that defines the local refinement
%                       [ positive scalar | 1e-3 ]
%   PrecisionTolerance  - Precision Tolerance Value is a positive value
%                        used as a stop criteria
%                       [ positive scalar | 1e-6 ]
%   MaxFunEvals         - Maximum number of function evaluations.        
%                       [ positive scalar | 3000*numberOfVariables ]
%   TolFun              - Termination tolerance on function value
%                       [ positive scalar  ]
%   TimeLimit           - Total time (in seconds) allowed for optimization
%                       [ positive scalar | {Inf} ]
%   StallIterLimit      - Number of iterations over which average
%                       change in objective function value at current
%                       point is less than options.TolFun 
%                       [ positive scalar | {500*numberOfVariables} 
%   ObjectiveLimit      - Minimum objective function value desired 
%                       [ scalar | {-Inf} ]
%   HybridFcn           - Automatically run HybridFcn (another 
%                       optimization function) during or at the end of
%                       iterations of the solver
%                       [ @fminsearch | @patternsearch | @fminunc |
%                       @fmincon | {[]} ]
%   HybridInterval      - Interval (if not 'end' or 'never') at which
%                       HybridFcn is called 
%                       [ positive integer | 'never' | {'end'} ]
%   Display             - Controls the level of display 
%                       [ 'off' | 'iter' | 'diagnose' | {'final'} ]
%   DisplayInterval     - Interval for iterative display 
%                       [ positive integer | {10} ]
%   OutputFcns          - Function(s) gets iterative data and can change
%                       options at run time
%                       [ function handle or cell array of function 
%                       handles | {[]} ]
%   PlotFcns            - Plot function(s) called during iterations 
%                       [ function handle or cell array of function 
%                       handles | @emplotbestf | @emplotbestx | 
%                       | @emplotstopping |  | 
%                       | {[]} ]
%   PlotInterval        - Interval at which PlotFcns are called
%                       [ positive integer {1} ]
%
%   Copyright 2013 Ana Rocha e Andreia Silva, Inc.
%   $Revision: 30.06.2013 $  $Date: 2012/05/08 20:25:58 $

numberargs = nargin; 

if (nargin == 0) && (nargout == 0)
    fprintf('        NumberPopulation:        [ positive scalar     | {10*numberOfVariables} ]\n');
    fprintf('                   TolFun:       [ non-negative scalar | {1e-6} ]\n');
    fprintf('          StallIterLimit:        [ positive integer    | {500*numberOfVariables} ]\n');
    fprintf('\n')
    fprintf('             MaxFunEvals:        [ positive integer    | {3000*numberOfVariables} ]\n');
    fprintf('      MaxLocalIterations:        [ positive integer    | {5} ]\n');
    fprintf('               TimeLimit:        [ positive scalar     | {Inf} ]\n');
    fprintf('                 MaxIter:        [ positive integer    | {Inf} ]\n');
    fprintf('          ObjectiveLimit:        [ scalar              | {-Inf} ]\n');
    fprintf('\n')
    fprintf('                   Delta:        [ positive scalar     | {10*numberOfVariables} ]\n');
    fprintf('      PrecisionTolerance:        [ non-negative scalar | {1e-6} ]\n');
    fprintf('\n')
    fprintf('                 Display:        [ positive integer    | {10} ]\n');
    fprintf('\n')
    fprintf('               HybridFcn:        [ function_handle     | @fminsearch | @patternsearch | \n');
    fprintf('                                 @fminunc | @fmincon   | {[]} ]\n');
    fprintf('          HybridInterval:        [ positive integer    | ''never''     | {''end''} ]\n');
    fprintf('\n')
    fprintf('                PlotFcns:        [ function_handle | @emplotbestf | @emplotbestx | \n');
    fprintf('                                 @emplotstopping  | @emplotx | @emplotf | {[]} ]\n');
    fprintf('            PlotInterval:        [ positive integer    | {1} ]\n');
    fprintf('\n')
    fprintf('              OutputFcns:        [ function_handle     | {[]} ]\n');
    return; 
end     

options=struct( 'NumberPopulation',[], ...
                'MaxIter',[], ...
                'MaxLocalIterations', [], ...
                'Delta', [],...
                'PrecisionTolerance',[],...
                'MaxFunEvals',[],...
                'ObjectiveLimit',[],...
                'TolFun',[],...
                'TimeLimit',[],...
                'StallIterLimit',[],...
                'Display',[],...
                'DisplayInterval',[],...
                'HybridFcn',[],...
                'HybridInterval',[],...
                'PlotFcns',[],...
                'PlotInterval',[],...
                'OutputFcns',[],...
                'DataType',[]);
          
% If we pass in a function name then return the defaults.
if (numberargs==3) && (ischar(varargin{1}) || isa(varargin{1},'function_handle') )
    if ischar(varargin{1})
        funcname = lower(varargin{1});
        if ~exist(funcname)
            error(message('globaloptim:emoptimset:functionNotFound',funcname));
        end
    elseif isa(varargin{1},'function_handle')
        funcname = func2str(varargin{1});
    end
    try 
        optionsfcn = feval(varargin{1},'defaults');
    catch
        error(message('globaloptim:emoptimset:noDefaultOptions',funcname))
    end
    % To get output, run the rest of psoptimset as if called with psoptimset(options, optionsfcn)
    varargin{1} = options;
    varargin{2} = optionsfcn;
    numberargs = 2;
end            
            
Names = fieldnames(options);
m = size(Names,1);
names = lower(Names);


i = 1;
while i <= numberargs
    arg = varargin{i};
    if ischar(arg) % arg is an option name
        break;
    end
    if ~isempty(arg) % [] is a valid options argument
        if ~isa(arg,'struct')
            error(message('globaloptim:emoptimset:invalidArgument', i));
        end
        argFieldnames = fieldnames(arg);
        
        for j = 1:m
            if any(strcmp(argFieldnames,Names{j,:}))
                val = arg.(Names{j,:});
            else
                val = [];
            end
            if ~isempty(val)
                if ischar(val)
                    val = lower(deblank(val));
                end
                checkfield(Names{j,:},val);
                options.(Names{j,:}) = val;
            end
        end
    end
    i = i + 1;
end


% A finite state machine to parse name-value pairs.
if rem(numberargs-i+1,2) ~= 0
    error(message('globaloptim:saoptimset:invalidArgPair'));
end
expectval = 0;  % start expecting a name, not a value
while i <= numberargs
    arg = varargin{i};
    
    if ~expectval
        if ~ischar(arg)
            error(message('globaloptim:emoptimset:invalidArgFormat', i));
        end
        
        lowArg = lower(arg);
        
        j = strmatch(lowArg,names);
        if isempty(j) % if no matches
            error(message('globaloptim:emoptimset:invalidParamName', arg));
        elseif length(j) > 1 % if more than one match
            % Check for any exact matches (in case any names are subsets of others)
            k = strmatch(lowArg,names,'exact');
            if length(k) == 1
                j = k;
            else
                allNames = ['(' Names{j(1),:}];
                for k = j(2:length(j))'
                    allNames = [allNames ', ' Names{k,:}];
                end
                allNames = sprintf('%s).', allNames);
                error(message('globaloptim:emoptimset:AmbiguousParamName',arg,allNames));
            end
        end
        expectval = 1;                      % we expect a value next
        
    else           
        if ischar(arg)
            arg = lower(deblank(arg));
        end
        checkfield(Names{j,:},arg);
        options.(Names{j,:}) = arg;
        expectval = 0;
    end
    i = i + 1;
end

if expectval
    error(message('globaloptim:emoptimset:invalidParamVal', arg));
end



%-------------------------------------------------
function checkfield(field,value)
%CHECKFIELD Check validity of structure field contents.
%   CHECKFIELD('field',V) checks the contents of the specified
%   value V to be valid for the field 'field'. 
%

% empty matrix is always valid
if isempty(value)
    return
end

switch field
    %Functions    
    case {'MaxIter', 'DisplayInterval', 'PlotInterval','TimeLimit','ObjectiveLimit','TolFun','Delta'}
        valid = isa(value,'double');
        if ~valid
            error(message('globaloptim:emoptimset:checkfield:NotAPosDouble',field));  
        end
    case {'StallIterLimit'}
        valid = (isnumeric(value) && (1 == length(value)) && (value > 0) && (value == floor(value))) || strcmpi(value,'500*numberOfVariables');
        if ~valid
            error(message('globaloptim:emoptimset:checkfield:NotAPosInteger',field));
        end   
      case {'NumberPopulation'}
        valid = (isnumeric(value) && (1 == length(value)) && (value > 0) && (value == floor(value))) || strcmpi(value,'10*numberOfVariables');
        if ~valid
            error(message('globaloptim:emoptimset:checkfield:NotAPosInteger',field));
        end 
      case {'MaxLocalIterations'}
        valid = (isnumeric(value) && (1 == length(value)) && (value == floor(value))) || strcmpi(value,'5');
        if ~valid
            error(message('globaloptim:emoptimset:checkfield:NotAPosInteger',field));
        end 
      case {'MaxFunEvals'}
        valid = (isnumeric(value) && (1 == length(value)) && (value > 0) && (value == floor(value))) || strcmpi(value,'3000*numberOfVariables');
        if ~valid
            error(message('globaloptim:emoptimset:checkfield:NotAPosInteger',field));
        end     
    case {'HybridInterval'}
        valid = isa(value,'double') || (ischar(value) && any(strcmpi(value,{'end','never'})));
        if  ~valid
            error(message('globaloptim:emoptimset:checkfield:NotAPosIntEndOrNever',field,'end','never'));  
        end
     case {'Display'}
        valid = ischar(value) && any(strcmpi(value,{'off', 'none', 'final', 'iter', 'diagnose'}));
        if ~valid
            error(message('globaloptim:emoptimset:checkfield:NotADisplayType','OPTIONS',field,'off','final','iter','diagnose'));
        end

    case {'DataType'}
        valid = ischar(value) && any(strcmpi(value,{'custom', 'double'}));
        if ~valid
            error(message('globaloptim:emoptimset:checkfield:NotCustomOrDouble','OPTIONS',field,'custom','double'));
        end

end    
