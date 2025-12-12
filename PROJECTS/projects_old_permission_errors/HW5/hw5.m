y = load('data.txt');          % measured temperature data

Ts = 60;                       % sampling time [s]
t = (0:length(y)-1)' * Ts;     % time vector
kW = 2.5;                      % heater power (kW)

delay = 2;
u = double(t >= Ts*delay) * kW;

pad = 5;                      % 10 Ts before and after

u_pad = [zeros(pad,1); u; kW*ones(pad,1)];       % 0s before, 1s (kW) after
y_pad = [repmat(y(1), pad, 1); y; repmat(y(end), pad, 1)];  % pad start/end with steady values

t_pad = (0:length(u_pad)-1)' * Ts;

figure;
subplot(2,1,1);
stairs(t_pad, u_pad, 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Input u(t) [kW]');
title('Heater Input (Step)');
grid on;

subplot(2,1,2);
plot(t_pad, y_pad, 'o', 'MarkerFaceColor','b', 'MarkerEdgeColor','b');
xlabel('Time [s]');
ylabel('Temperature [°C]');
title('Room Temperature Response');
grid on;

data = iddata(y_pad, u_pad, Ts);
sys = tfest(data, 1, 0, NaN, 'Ts', Ts);
K_id   = dcgain(sys)
a      = pole(sys)      ;         % discrete pole
tau_id = -Ts / log(a(1))

disp(sys)
figure; compare(data, sys), grid on;
