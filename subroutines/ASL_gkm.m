function GKM = ASL_gkm(T1,Delta_t,tau,dt,t_max,m,f)
%--------------------------------------------------------------------------
%   Function to calculate the generalized kinetic model (GKM) for ASL signal
%   dynamics using convolution of a piecewise-defined bolus input function 
%   with an exponential tissue response function.
%
%   INPUT:
%       double      T1        -  Tissue T1 relaxation time [ms]
%       double      Delta_t   -  Transit delay [ms]
%       double      tau       -  Perfusion duration [ms]
%       double      dt        -  Time step for the simulation [ms]
%       double      t_max     -  Maximum time for the simulation [ms]
%       [double]    m         -  Magnetization vector
%       double      f         -  Cerebral Blood Flow (CBF) in ml of 
%                                perfusive substance per ml tissue per sec
%
%   OUTPUT:
%       [double]    GKM       -  Array of ASL signal over time, computed 
%                                using the generalized kinetic model
%__________________________________________________________________________
% VM (vmalis@ucsd.edu)
%--------------------------------------------------------------------------

lambda=1;
t = 0:dt:t_max; % Time vector
t(end)=[];
% Define the piecewise function c(t) for the pulsed state
c = zeros(size(t));
c(t >= Delta_t & t < tau + Delta_t) = exp(-t(t >= Delta_t & t < tau + Delta_t)/T1);

% Define r(t) and m(t)
r  = exp(-f*t/lambda);

% r(t) and m(t)
rm = r.*m'; % Multiplying

% Convolve c(t) with rm_conv
Delta_M_conv = f * conv(c, rm, 'full')*dt; % Multiply by dt to approximate the integral

% Truncate the convolution result to match the time vector length
GKM = Delta_M_conv(1:length(t));
GKM(1:ceil(Delta_t/dt)) = 0;

end

