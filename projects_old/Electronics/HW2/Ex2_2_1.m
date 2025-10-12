clear      % ワークスペースからすべての変数を消去
close all  % すべてのFigureを消去
clc        % コマンド ウィンドウのクリア

%回路素子のパラメータ
R = 100;         %抵抗[Ω]
C = 1e-6;        %静電容量[C]
L = 5e-3;        %インダクタンス[H]
f_h = 2000;      % Hz
f_w = f_h * 2 *pi; % Rad/s
V = 1;           % Input V 

% Landmarks
wn  = 1/sqrt(L*C);            % rad/s
Rcrit = 2*sqrt(L/C);          % critical damping (zeta = 1)

% Choose representative cases
R_under = 0.3*Rcrit;          % underdamped (zeta<1)
R_crit  = Rcrit;              % critically damped (zeta=1)
R_over  = 2.0*Rcrit;          % overdamped (zeta>1)
Rlist   = [R_under, R_crit, R_over];

%Simulinkの実行
Endtime = 1.0e-3;           %シミュレーション実行時間
mdl = '../Ex2_2_sim_1';     %ファイル名（拡張子なし）
open(mdl);             %Simulinkファイルを開く

tstop = 8/wn;   % enough time for settling
colors = lines(3);
figure('Name','Simulink step: damping cases'); hold on

labels = strings(1,3);
for k = 1:3
    R = Rlist(k);
    zeta = (R/2)*sqrt(C/L);

    % Provide parameters to the model via SimulationInput
    si = Simulink.SimulationInput(mdl);
    si = si.setVariable('R',R);
    si = si.setVariable('L',L);
    si = si.setVariable('C',C);
    si = si.setVariable('V',V);
    si = si.setModelParameter('StopTime', num2str(tstop));

    out = sim(si);
    t = out.simout.time;
    y = out.simout.Data(:,1);   % assuming simout = [y u]

    plot(t, y, 'LineWidth',1.5, 'Color', colors(k,:));
    if k==1, tag="Underdamped"; elseif k==2, tag="Critical"; else, tag="Overdamped"; end
    labels(k) = sprintf("%s  (R=%.1fΩ,  ζ=%.3f)", tag, R, zeta);
end
grid on; xlabel('t (s)'); ylabel('v_C (V)');
title(sprintf('RLC Step Responses from Simulink  (\\omega_n = %.1f rad/s,  R_{crit}=%.1fΩ)', wn, Rcrit));
legend(labels, 'Location','best');