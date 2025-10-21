clear      % ワークスペースからすべての変数を消去
close all  % すべてのFigureを消去
clc        % コマンド ウィンドウのクリア


%システムの物理パラメータ
u = 1.0;    %入力電圧[V]
R = 5.0;    %電気子抵抗[Ω]
L = 1e-3;   %インダクタンス[H]
K_e = 5e-2; %逆起電力定数[Vs/rad]
K_t = 5e-2; %トルク定数[Nm/A]
D = 1e-5;   %粘性摩擦係数[Nmrad/s]
J = 1e-5;   %慣性モーメント[kgm^2]


%Simulinkの実行
Endtime = 0.2;          %シミュレーション実行時間          
filename = 'Ex3_3_a_sim'; %ファイル名（拡張子なし）
open(filename);         %Simulinkファイルを開く
sim(filename);          %Simulinkの実行

%Figureによる結果の表示
t = simout.time;        %時間
y = simout.Data(:, 1);  %回転角速度
u = simout.Data(:, 2);  %入力電圧
%yの表示
subplot(2,1,1)      %Figureを(2行1列に分割した1行1列目)
plot(t, y)          %y1の表示
grid on             %グリッドラインの追加
ylim([0, 25.0])      %y軸の表示範囲を指定
ylabel('y')         %y軸ラベル
%uの表示
subplot(2,1,2)      %Figureを(2行1列に分割した2行1列目)
plot(t, u)          %y2の表示
grid on             %グリッドラインの追加
ylim([0, 2.0])      %y軸の表示範囲を指定
xlabel('t')         %x軸ラベル
ylabel('u')         %y軸ラベル