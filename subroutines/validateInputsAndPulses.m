function validateInputsAndPulses(T1, type, alpha, pulses, gkmParam)
%--------------------------------------------------------------------------
%
%   Function to validate inputs and check pulses array:
%   - T1 must be a positive double.
%   - type must be a string and either "dark" or "bright".
%   - alpha must be a positive double between 0 and 1.
%   - pulses array:
%       - All elements must be positive.
%       - The first element must be greater than 0.
%       - The array must be in strictly ascending order.
%   - gkmParam must be an array of 3 positive elements.
%
%   INPUT: 
%       double      T1          -   T1 [ms]
%       string      type        -   'dark' or 'bright'
%       double      alpha       -   Labeling efficiency
%       [double]    pulses      -   Array of numeric values to be checked
%       [double]    gkmParam    -   Array of 3 numeric values to be checked
%   
%   OUTPUT:
%       None
%
%__________________________________________________________________________
% VM (vmalis@ucsd.edu)
%--------------------------------------------------------------------------

    % Validate T1
    if ~isnumeric(T1) || ~isscalar(T1) || T1 <= 0
        error('T1 must be a positive double.');
    end
    
    % Validate type
    if ~ischar(type) && ~isstring(type)
        error('Type must be a string.');
    end
    
    if ~strcmp(type, 'dark') && ~strcmp(type, 'bright')
        error('Type must be either "dark" or "bright".');
    end
    
    % Validate alpha
    if ~isnumeric(alpha) || ~isscalar(alpha) || alpha <= 0 || alpha > 1
        error('Alpha must be a positive double between 0 and 1.');
    end
    
    % Validate pulses array
    if isempty(pulses)
        error('The pulses array is empty.');
    end

    if any(pulses <= 0)
        error('All elements of the pulses array must be positive.');
    end

    if pulses(1) <= 0
        error('The first element of the pulses array must be greater than 0.');
    end

    if any(diff(pulses) <= 0)
        error('The elements of the pulses array must be in strictly ascending order.');
    end

    % Validate gkmParam array
    if ~isnumeric(gkmParam) || numel(gkmParam) ~= 3
        error('gkmParam must be an array of exactly 3 numeric elements.');
    end

    if any(gkmParam <= 0)
        error('All elements of the gkmParam array must be positive.');
    end

end