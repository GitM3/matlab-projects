clear      % ワークスペースからすべての変数を消去
close all  % すべてのFigureを消去
clc        % コマンド ウィンドウのクリア

%タンクシステム物理パラメータ
A = 10.0;   %タンクの断面積[m^2]
R = 0.8;    %出口抵抗[s/m^2]
q1 = 0.5;   %流入流量[m^3/s]

%１次遅れシステムパラメータ
K = R;      %システムゲイン
T = A*R;    %時定数

%Simulinkの実行
Endtime = 60;           %シミュレーション実行時間          
filename = 'Ex3_1_sim'; %ファイル名（拡張子なし）
open(filename);         %Simulinkファイルを開く
sim(filename);          %Simulinkの実行

%Figureによる結果の表示
t = simout.time;        %時間
y = simout.Data(:, 1);  %水位
u = simout.Data(:, 2);  %流入流量
%yの表示
subplot(2,1,1)      %Figureを(2行1列に分割した1行1列目)
plot(t, y)          %y1の表示
grid on             %グリッドラインの追加
ylim([0, 0.5])      %y軸の表示範囲を指定
ylabel('y')         %y軸ラベル
%uの表示
subplot(2,1,2)      %Figureを(2行1列に分割した2行1列目)
plot(t, u)          %y2の表示
grid on             %グリッドラインの追加
ylim([0, 1.0])      %y軸の表示範囲を指定
xlabel('t')         %x軸ラベル
ylabel('u')         %y軸ラベル