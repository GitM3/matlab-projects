clear      % ƒ[ƒNƒXƒy[ƒX‚©‚ç‚·‚×‚Ä‚Ì•Ï”‚ðÁ‹Ž
close all  % ‚·‚×‚Ä‚ÌFigure‚ðÁ‹Ž
clc        % ƒRƒ}ƒ“ƒh ƒEƒBƒ“ƒhƒE‚ÌƒNƒŠƒA

% --- ƒVƒXƒeƒ€‚Ì•¨—ƒpƒ‰ƒ[ƒ^ ---
u      = 1.0;    % “ü—Í“dˆ³ [V]
R      = 5.0;    % “d‹CŽq’ïR [ƒ¶]
L      = 1e-3;   % ƒCƒ“ƒ_ƒNƒ^ƒ“ƒX [H]
K_e    = 5e-2;   % ‹t‹N“d—Í’è” [Vs/rad]
K_t    = 5e-2;   % ƒgƒ‹ƒN’è” [Nm/A]
D      = 1e-5;   % ”S«–€ŽCŒW” [Nmüüs/rad]
J      = 1e-5;   % Šµ«ƒ‚[ƒƒ“ƒg [kgüüm^2]

% --- ƒpƒ‰ƒ[ƒ^‘|ˆøF•‰‰×ƒgƒ‹ƒN ---
tl_load = [0.001 0.005 0.010 0.015];  % [Nm]
colors  = lines(numel(tl_load));

% --- Simulink ŽÀsÝ’è ---
Endtime  = 0.2;              % ƒVƒ~ƒ…ƒŒ[ƒVƒ‡ƒ“ŽžŠÔ [s]
filename = 'Ex3_3_a_sim';    % Simulink ƒ‚ƒfƒ‹–¼iŠg’£Žq‚È‚µj

% --- }‚Ì€”õ ---
tiledlayout(2,1,'Padding','compact','TileSpacing','compact');
ax1 = nexttile(1); hold(ax1,'on'); grid(ax1,'on');
title(ax1,'Angular speed \omega(t) for different load torques');
ylabel(ax1,'\omega(t) [rad/s]');

ax2 = nexttile(2); hold(ax2,'on'); grid(ax2,'on');
title(ax2,'Input voltage u(t) and load torque \tau_L(t)');
ylabel(ax2,'u(t) [V]');
xlabel(ax2,'t [s]');
yyaxis(ax2,'left');   % return left axis active

leg = strings(1,numel(tl_load));
u_plotted = false;    % so we don't plot identical u(t) multiple times

for i = 1:numel(tl_load)
    tL = tl_load(i);
    leg(i) = sprintf('\\tau_L = %.3f Nm', tL);

    % Prepare simulation input and set the load torque variable used in the model
    si = Simulink.SimulationInput(filename);
    si = si.setVariable('t_load', tL);
    si = si.setModelParameter('StopTime', num2str(Endtime));

    % Run
    out = sim(si);

    % Retrieve logged signals
    % Assumes 'simout' is a timeseries/bus with columns:
    %   col1: omega(t), col2: u(t), (optional) col3: tau_L(t)
    simout = out.get('simout');
    ts = simout.time;
    data = simout.Data;

    omega = data(:,1);
    u_sig = data(:,min(2,size(data,2)));  
    tau_sig = data(:,3) /tL;              % external
    

    % Plot omega on the top axes (one curve per load)
    plot(ax1, ts, omega, 'LineWidth', 1.5, 'Color', colors(i,:), ...
         'DisplayName', leg(i));

    % Bottom axes: left y-axis = u(t), right y-axis = tau_L(t)
    % Plot u(t) only once (it's the same for all loads unless your model changes it)
    if ~u_plotted
        plot(ax2, ts, u_sig, 'LineWidth', 1.5, 'DisplayName','u(t)');
        u_plotted = true;
    end
    
    plot(ax2, ts, tau_sig,'-', 'LineWidth', 1.2, 'Color', colors(i,:), ...
         'DisplayName', sprintf('\\tau_L(t) for %.3f', tL));
end

% Finalize legends/limits
legend(ax1,'Location','best'); ylim(ax1,[0 25]);
yyaxis(ax2,'left');  ylim(ax2,[0 2.0]);
legend(ax2,'Location','best');

sgtitle('DC Motor Simulation');
