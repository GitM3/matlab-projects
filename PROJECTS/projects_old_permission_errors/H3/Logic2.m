clear; close all; clc;

%% --- Base physical / model params (SI units)
h       = 10;                 % W/(m^2*K)
L       = 10;                 % m (only used to build a baseline volume)
A_env   = 4*L^2;              % m^2  (keep envelope area fixed in sweeps)
rho     = 1.225;              % kg/m^3
cp      = 1005;               % J/(kg*K)

V0      = L^3;                % m^3  (baseline volume)
C0      = rho*V0*cp;          % J/K  (baseline thermal capacitance)

To      = 32;                 % degC
Ti0     = 32;                 % degC initial indoor temp
Qint    = 300;                % W

COP     = 3.5;                % -
Pe0     = 15000;              % W electrical (baseline)
Qac0    = COP*Pe0;            % W cooling

% Relay thermostat
Tset     = 22;                % degC
deadband = 0.8;               % K  (relay uses +/- deadband/2)

% Simulation setup
simTime  = 60*15;             % s  (15 minutes)
mdl      = 'Sim';
open(mdl);

%% --- Helper to set derived gains from (C, Qac)
gainsFrom = @(C, Qac) struct( ...
    'k1', h*A_env/C, ...
    'k2', Qint/C, ...
    'k3', Qac/C );

%% --- Sweep 1: AC electrical power (hold C, A, etc. fixed)
Pe_list  = [6000 9000 12000 15000 18000];     % W
Qac_list = COP .* Pe_list;                    % W

colors = lines(max(numel(Qac_list),5));       % color set

figure('Name','HVAC sweeps'); 
tiledlayout(1,2, 'Padding','compact', 'TileSpacing','compact');

% LEFT subplot: AC power sweep
nexttile; hold on; grid on; box on;
leg1 = strings(1,numel(Qac_list));

for i = 1:numel(Qac_list)
    Qac = Qac_list(i);
    g   = gainsFrom(C0, Qac);

    si = Simulink.SimulationInput(mdl);
    si = si.setModelParameter('StopTime', num2str(simTime));
    si = si.setVariable('To', To);
    si = si.setVariable('Tset', Tset);
    si = si.setVariable('deadband', deadband);
    si = si.setVariable('k1', g.k1);
    si = si.setVariable('k2', g.k2);
    si = si.setVariable('k3', g.k3);
    si = si.setVariable('Ti0', Ti0);

    out = sim(si);

    % Pull Ti from logsout (make sure Ti is logged in the model)
    Ti_sig = out.logsout.get('Ti');      % timeseries
    t  = Ti_sig.Values.Time;
    Ti = Ti_sig.Values.Data;

    plot(t/60, Ti, 'LineWidth', 1.7, 'Color', colors(i,:));
    leg1(i) = sprintf('P_e = %.0f kW (Q_{ac}=%.1f kW)', Pe0*(Pe_list(i)/Pe0)/1000*0 + Pe_list(i)/1000, Qac/1000); %#ok<NASGU>
    leg1(i) = sprintf('P_e = %.0f kW', Pe_list(i)/1000);
end

xlabel('Time (min)');
ylabel('Indoor temp T_i (°C)');
title('Sweep: AC electrical power');
legend(leg1, 'Location', 'best');

%% --- Sweep 2: Room volume / thermal capacitance (hold Qac constant)
V_scale = [0.5 1 2 3];                     % multiples of baseline volume
C_list  = (rho*cp) .* (V0*V_scale);        % J/K

nexttile; hold on; grid on; box on;
leg2 = strings(1,numel(C_list));

for i = 1:numel(C_list)
    C = C_list(i);
    g = gainsFrom(C, Qac0);

    si = Simulink.SimulationInput(mdl);
    si = si.setModelParameter('StopTime', num2str(simTime));
    si = si.setVariable('To', To);
    si = si.setVariable('Tset', Tset);
    si = si.setVariable('deadband', deadband);
    si = si.setVariable('k1', g.k1);
    si = si.setVariable('k2', g.k2);
    si = si.setVariable('k3', g.k3);
    si = si.setVariable('Ti0', Ti0);

    out = sim(si);

    Ti_sig = out.logsout.get('Ti');
    t  = Ti_sig.Values.Time;
    Ti = Ti_sig.Values.Data;

    plot(t/60, Ti, 'LineWidth', 1.7, 'Color', colors(i,:));
    leg2(i) = sprintf('V = %.1fx', V_scale(i));
end

xlabel('Time (min)');
ylabel('Indoor temp T_i (°C)');
title('Sweep: Room volume (thermal capacitance)');
legend(leg2, 'Location', 'best');

