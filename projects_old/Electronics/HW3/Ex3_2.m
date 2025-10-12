clear      % ワークスペースからすべての変数を消去
close all  % すべてのFigureを消去
clc        % コマンド ウィンドウのクリア

%マス-バネ-ダンパシステム物理パラメータ
k = 2.0;      %バネ定数[N/m]
M = 0.5;    %質量[kg]
D = 0.1;    %粘性係数[Ns/m]

%２次遅れシステムパラメータ
K = 1/k;                %システムゲイン
omega = sqrt(k/M);      %共振周波数
zeta = sqrt(D^2/(M*k)); %減衰係数

%Simulinkの実行
Endtime = 10;           %シミュレーション実行時間          
filename = 'Ex3_2_sim'; %ファイル名（拡張子なし）
open(filename);         %Simulinkファイルを開く
sim(filename);          %Simulinkの実行

%Figureによる結果の表示
t = simout.time;        %時間
y = simout.Data(:, 1);  %変位
u = simout.Data(:, 2);  %入力
%yの表示
subplot(2,1,1)      %Figureを(2行1列に分割した1行1列目)
plot(t, y)          %y1の表示
grid on             %グリッドラインの追加
ylim([0, 1.0])      %y軸の表示範囲を指定
ylabel('y')         %y軸ラベル
%uの表示
subplot(2,1,2)      %Figureを(2行1列に分割した2行1列目)
plot(t, u)          %y2の表示
grid on             %グリッドラインの追加
ylim([0, 2.0])      %y軸の表示範囲を指定
xlabel('t')         %x軸ラベル
ylabel('u')         %y軸ラベル