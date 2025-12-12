clear         % ワークスペースからすべての変数を消去
close all     %すべてのFigureを消去
clc           %コマンド　ウィンドウのクリア
r=0.05;       %車輪の半径[m]
L=0.2;        %ロボットの幅[m]
dt=1;         %サンプリング間隔
%ロボットの初期位置
pRobot0=[0.2,0.1,-0.1,-0.1,0.1,0.2;...
    0,-0.1,-0.1,0.1,0.1,0;...
    1,1,1,1,1,1];     %ロボットの初期位置
pRobot=pRobot0;       %ロボットの現在位置
figure(1);
%ロボットの初期状態の表示
plot(pRobot0(1,:),pRobot0(2,:),':');
axis equal;        %x,y方向のデータ単位が等しくなる
%x,y軸の表示範囲を指定（最小値 -1，最大値 1）
axis([-1 1 -1 1]);
xlabel('X [m]');   %x軸ラベル
ylabel('Y [m]');   %y軸ラベル
grid on;           %グリッドラインを追加
%右車輪の回転速度
ptext1=[10 50 30 20];  %文字列'w_l'の位置
uicontrol('style','text','position',ptext1,'string','w_l');
ui1=uicontrol(1,'style','edit','string','0');%単位 [degree/s]
set(ui1, 'position', [50 50 40 20]); %ui1の位置を設定
%左車輪の回転速度
ptext2=[10 75 30 20];  %文字列'w_r'の位置
uicontrol('style','text','position',ptext2,'string','w_r');
ui2=uicontrol(1,'style','edit','string','0');%単位 [degree/s]
set(ui2, 'position', [50 75 40 20]); %ui2の位置を設定
%'Draw'ボタン
ui3=uicontrol(1,'style','pushbutton','string', 'Draw');
%'drawRobot'を実行
set(ui3,'position',[10 100 80 20],'callback', 'drawRobot');
%'Reset'ボタン
ui4=uicontrol(1,'style','pushbutton','string', 'Reset');
%'resetValue'を実行
set(ui4,'position',[10 25 80 20],'callback', 'resetValue');
%ロボットの進行方位角
ptext3=[470 325 30 20];  %文字列'theta'の位置
uicontrol('style','text','position',ptext3,'string','theta');
ui5=uicontrol(1,'style','edit','string','0');%単位 [degree]
set(ui5, 'position', [500 325 50 20]); %ui5の位置を設定
%ロボットのyの値
ptext4=[470 350 30 20];  %文字列'y'の位置
uicontrol('style','text','position',ptext4,'string','y');
ui6=uicontrol(1,'style','edit','string','0');%単位 [m]
set(ui6, 'position', [500 350 50 20]); %ui6の位置を設定
%ロボットのxの値
ptext5=[470 375 30 20];  %文字列'x'の位置
uicontrol('style','text','position',ptext5,'string','x');
ui7=uicontrol(1,'style','edit','string','0');%単位 [m]
set(ui7, 'position', [500 375 50 20]); %ui7の位置を設定