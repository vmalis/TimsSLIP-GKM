function mz = mzBloch(T1,t,pulse_times)
%--------------------------------------------------------------------------
%
%   Function to simulate the longitudinal magnetization (Mz) over time
%   using the Bloch equations with T1 relaxation and optional RF pulses.
%   The simulation is performed for two cases: with and without an RF pulse.
%
%   INPUT:
%       double      T1          -   Longitudinal relaxation time [ms]
%       [double]    t           -   Array of time points [ms]
%       [double]    pulse_times -   Array of RF pulse times [ms]
%
%   OUTPUT:
%       [double]    mz          -   Array of simulated longitudinal
%                                   magnetization values at each time point 
%                                   for both pulse conditions (2 columns)
%__________________________________________________________________________
% VM (vmalis@ucsd.edu)
%--------------------------------------------------------------------------    

    % Preallocate arrays to store results
    mz  = zeros(numel(t), 2);
    
    % Bloch simulation for NonSelective pulse
    mz(1,1:2) = -1;                % Initialize magnetization 
    dMz_dt    = 0;                 % Initialize deltas
    for p=1:2
        Mz=-1;
        for i = 2:numel(t)
            
            % Calculate relaxation
            dMz_dt = (1 - Mz) / T1;
            dt=t(i)-t(i-1);
            
            % Apply RF pulse for 1 pulse
            if any(abs(t(i) - pulse_times) < dt/2) && p==2
                Mz = -Mz; % Flip magnetization by -1
            end

            % Update spin states using Euler's method
            Mz= Mz + dMz_dt * dt;
            % Store results for 1 pulse
            mz(i,p) = Mz;

        end
    end

end