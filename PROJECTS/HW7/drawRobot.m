for i=1:1:10
    %ロボットのx値をui7から読み込み
    x=str2double(get(ui7,'string'));
    %ロボットのy値をui6から読み込み
    y=str2double(get(ui6,'string'));
    %ロボットの進行方位角をui5から読み込み
    %角度->ラジアン
    theta=str2double(get(ui5,'string'))*pi/180;
    %左車輪の回転角度をui2から読み込み
    w_l=str2double(get(ui1,'string'))*pi/180;
    %右車輪の回転角度をui1から読み込み
    w_r=str2double(get(ui2,'string'))*pi/180;
    
    A=[cos(theta),0 ;sin(theta) ,0 ; 0,1 ];      %変換行列
    dotp=A*r*[0.5 , 0.5; -1/L,1/L ]*[w_r ;w_l ]; %速度
    
    dotx=dotp(1);        %x方向の速度
    doty=dotp(2);        %y方向の速度
    dottheta=dotp(3);    %ロボットの回転速度
    x=x+dotx*dt;               %x値の更新
    y=y+doty*dt;               %y値の更新
    theta=theta+dottheta*dt;   %theta値の更新
    %ui5の値の更新（ラジアン->角度）
    set(ui5,'string',num2str(theta*180/pi));
    %ui6の値の更新
    set(ui6,'string',num2str(y));
    %ui7の値の更新
    set(ui7,'string',num2str(x));
    %ロボットの同次変換行列
    T=[cos(theta),-sin(theta),x;...
        sin(theta),cos(theta),y;...
        0,0,1];
    npRobot=T*pRobot;%ロボットの新しい位置
    figure(1);
    plot(pRobot0(1,:),pRobot0(2,:),':'); %初期位置の表示
    hold on %現在のプロットを保持
    plot(npRobot(1,:),npRobot(2,:)); %新しい位置の表示
    hold off %ホールドを解除
    axis equal;
    axis([-1 1 -1 1]);
    xlabel('X [m]');
    ylabel('Y [m]');
    grid on;
end