clear      % ワークスペースからすべての変数を消去
close all  % すべてのFigureを消去
clc        % コマンド ウィンドウのクリア

%シミュレーションパラメータ
Endtime = 1000; %シミュレーション時間
u = 30;         %入力熱量[W]
d0 = 25.0;      %外気温[℃]
K = 1.15;       %システムゲイン
T = 1115;       %時定数[s]
L = 15*10;         %むだ時間[s]

%制御器パラメータ
r = 50;
%CHR法
kc = 0.7*T/(K*L);
Ti = T;
Td = 0.5*L;
p   = [0.7*T/(K*L),   1,      0     ];  % [Kc, DONT CARE, Td]
pi  = [0.6*T/(K*L),   T,      0     ];  % [Kc, Ti, Td]
pid = [0.95*T/(K*L),  1.36*T, 0.47*L];  % [Kc, Ti, Td]
P = [p; pi; pid];

%Simulinkの実行
filename = 'pid_sim'; %ファイル名（拡張子なし）
results = struct;

% ==== Simulation Loop ====
figure('Name','PID Comparison','NumberTitle','off');
tiledlayout(2,1);

nexttile(1); hold on; grid on;
title('Output Response (y)');
xlabel('Time [s]'); ylabel('Temperature [°C]');
xlim([0 Endtime]); ylim([25 65]);

nexttile(2); hold on; grid on;
title('Control Signal (u)');
xlabel('Time [s]'); ylabel('Flow rate [u]');
xlim([0 Endtime]); ylim([0 350]);

for i = 1:size(P,1)
    % Select which parameters to vary
    kc = P(i,1); 
    Ti = P(i,2);
    Td = P(i,3);
    Tswitch = (i > 1)*1 ;

    % Run Simulink
    simOut = sim(filename, 'ReturnWorkspaceOutputs', 'on');

    % Extract signals
    t = simOut.simout.time;
    y_tilde = simOut.simout.Data(:,1);
    u_data = simOut.simout.Data(:,3);

    % Plot
    labels = ["P","PI","PID"];
    nexttile(1);
    plot(t, y_tilde, 'DisplayName', labels(i),'LineWidth',1.5);

    nexttile(2);
    plot(t, u_data, 'DisplayName', labels(i),'LineWidth',1.5);

    % Store results
    results(i).Kc = kc;
    results(i).time = t;
    results(i).y = y_tilde;
    results(i).u = u_data;
end

% Add legends
nexttile(1); legend show;
nexttile(2); legend show;