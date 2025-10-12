clear      % ワークスペースからすべての変数を消去
close all  % すべてのFigureを消去
clc        % コマンド ウィンドウのクリア

%回路素子のパラメータ
R = 100;         %抵抗[Ω]
C = 1e-6;        %静電容量[C]
L = 5e-3;        %インダクタンス[H]

%Simulinkの実行
Endtime = 1.0e-3;           %シミュレーション実行時間
filename = 'Ex2_2_sim';     %ファイル名（拡張子なし）
open(filename);             %Simulinkファイルを開く
sim(filename);              %Simulinkの実行

%Figureによる結果の表示
t = simout.time;        %時間
y = simout.Data(:, 1);  %出力電圧[V]
u = simout.Data(:, 2);  %入力電圧[V]
subplot(2,1,1)          %Figureを(2行1列に分割した1行1列目)
plot(t, y, '-b')        %yの表示（青，実線）
ylabel('y[V]')          %y軸ラベル
grid on                 %グリッドラインの追加
ylim([0, 1.5])          %y軸の表示範囲を指定（最小値0，最大値1.5）
subplot(2,1,2)          %Figureを(2行1列に分割した2行1列目)
plot(t, u, '-b')        %uの表示（青，実線）
grid on                 %グリッドラインの追加
ylim([0, 1.5])          %y軸の表示範囲を指定（最小値0，最大値1.5）
xlabel('t[s]')          %x軸ラベル
ylabel('u[V]')          %y軸ラベル