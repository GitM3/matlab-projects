clear      % ワークスペースからすべての変数を消去
close all  % すべてのFigureを消去
clc        % コマンド ウィンドウのクリア

%シミュレーションパラメータ
Endtime = 3600; %シミュレーション時間
u = 30;         %入力熱量[W]
d0 = 25.0;      %外気温[℃]
K = 1.15;       %システムゲイン
T = 1115;       %時定数[s]
L = 15;         %むだ時間[s]

%Simulinkの実行
filename = 'Ex4_1_sim'; %ファイル名（拡張子なし）
open(filename);         %Simulinkファイルを開く
sim(filename);          %Simulinkの実行

%Figureによる結果の表示
t = simout.time;                %時間
y_tilde = simout.Data(:, 1);    %水温度
u = simout.Data(:, 2);          %流入流量
%yの表示
subplot(2,1,1)      %Figureを(2行1列に分割した1行1列目)
plot(t, y_tilde)    %y_tildeの表示
grid on             %グリッドラインの追加
xlim([0, Endtime])  %x軸の表示範囲を指定
ylim([25, 65])      %y軸の表示範囲を指定
ylabel('y\_tilde')  %y軸ラベル
%uの表示
subplot(2,1,2)      %Figureを(2行1列に分割した2行1列目)
plot(t, u)          %y2の表示
grid on             %グリッドラインの追加
xlim([0, Endtime])  %x軸の表示範囲を指定
ylim([0, 350])      %y軸の表示範囲を指定
xlabel('t')         %x軸ラベル
ylabel('u')         %y軸ラベル