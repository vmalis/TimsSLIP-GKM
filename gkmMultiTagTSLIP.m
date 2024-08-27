function ratio = gkmMultiTagTSLIP(T1,pulses,type,alpha, gkmParam, showplot)
%--------------------------------------------------------------------------
%
%   Function to calculate signal ratio between dark Time-SLIP and multi-tag
%   bright or dark
%
%   dark:    first tag is at t=0  provide tn of next pulses
%   bright:  first tag is Non-Selective at t=0 provide tn of next pulses
%
%   INPUT: 
%       double      T1       -  T1 [ms]
%       [double]    pulses   -  tag pulses timing [t1, t2 ... tn]  [ms]
%       string      type     -  dark (select) or bright (nselect + select)
%       double      alpha    -  labeling efficiency
%       [double]    gkmParam -  [f, delta_t, tau]
%       boolean     showplot -  if true shows plot
% 
%   OUTPUT: 
%       double      ratio    -   signal ratio vs dark single tag
%
%__________________________________________________________________________
% VM (vmalis@ucsd.edu)
%--------------------------------------------------------------------------

% check inputs
validateInputsAndPulses(T1, type, alpha, pulses, gkmParam)

% tag lables
switch type
    case 'bright'
        Npulses=numel(pulses);
    case 'dark'
        Npulses=numel(pulses)+1;
end

if Npulses>1
    tagStr='tags';
else
    tagStr='tag';
end

% prepare pulses timing, append NS to bright
if isscalar(pulses) && strcmp(type,'dark')
    disp('ratio = 1');
    return
end

t_total = 5000;      % simulation total time
dt = 0.1;               % time step [ms]
t0=(0:dt:t_total)';      % time vector

% ratio doesnt depend on GKM parameters so set up typical
% is used for plotting of expected SIR
f       = gkmParam(1);
delta_t = gkmParam(2);
tau     = gkmParam(3);


%% numeric
lastPulseIdx=pulses(end)/dt;
t_total = t_total+lastPulseIdx*dt;
t=0:dt:t_total;
    
% Bloch
mz=mzBloch(T1,t,pulses);
control=ones(size(mz,1),1);
    
% GKM
m = control - mz(:,1);
m = m(1:(t_total-lastPulseIdx*dt)/dt+1);
GKM0 = ASL_gkm(T1,delta_t,tau,dt,t_total-lastPulseIdx*dt+dt,m,f);
switch type
    case 'bright'
        m = alpha^(numel(pulses)+1)*abs(mz(:,1) - mz(:,2));
        m = m(lastPulseIdx+1:t_total/dt+1);
        GKM = ASL_gkm(T1,delta_t,tau,dt,t_total-lastPulseIdx*dt+dt,m,f);
    case 'dark'
        m = control - mz(:,2);
        m = alpha^(numel(pulses)+1)*m(lastPulseIdx+1:t_total/dt+1);
        GKM = ASL_gkm(T1,delta_t,tau,dt,t_total-lastPulseIdx*dt+dt,m,f);
end

%% plot

    % to account for the bolus delay where ratio not defiend
    if std(GKM./GKM0,0,'omitnan')>0.01
        ratio=GKM./GKM0; 
        ymax=105*max(ratio,[],'omitnan');
        ymin=95*min(ratio,[],'omitnan');
    else
        ratio=mean(GKM./GKM0,'omitnan'); 
        ymax=105*ratio;
        ymin=95*ratio;
    end

    % plotting
    if showplot
        % Get the screen size
        ScrSz = get(0, 'ScreenSize');
        
        % Create a figure with the height of the screen and full width
        figure('Color', 'white', 'Position', [0 0 ScrSz(4)/2 ScrSz(4)]);
        
        % Create a tiled layout with two rows, one column
        tiledlayout(2, 1);
        
        % First plot
        nexttile; % Move to the first tile
        p1 = plot(t0/1000, GKM0*100, 'LineWidth', 2);
        hold on
        p2 = plot(t0/1000, GKM*100, 'LineWidth', 2);
        str1 = '1-tag dark';
        str2 = sprintf('%d-%s %s', Npulses, tagStr, type);
        grid on
        box on
        set(gca, 'TickLabelInterpreter', 'latex'); 
        ylim([0, 110*(max([GKM, GKM0]))])
        xlim([0, t_total/1000])
        axis square
        ylabel('Signal Increase [\% $M_0$]', 'FontSize', 14, 'Interpreter', ...
            'latex');
        xlabel('time [s]', 'FontSize', 14, 'Interpreter', 'latex')
        set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 16);
        legend([p1, p2], {str1, str2}, 'Interpreter', 'latex');
        
        % Second plot
        nexttile; % Move to the second tile
        plot(t0/1000, 100*GKM./GKM0, 'LineStyle', '-', 'LineWidth', 2,...
            'Color', 'k');
        axis square
        set(gca, 'TickLabelInterpreter', 'latex'); 
        ylim([ymin,ymax]);
        xlim([0, t_total/1000])
        grid on
        box on
        ylabel('Ratio [\%] 1-tag dark', 'FontSize', 14, 'Interpreter', 'latex');
        xlabel('time [ms]', 'FontSize', 14, 'Interpreter', 'latex')
        set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 16);
    end
end