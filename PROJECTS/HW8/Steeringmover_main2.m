clear
close all
clc
L=0.2; %前輪軸中心から後輪軸中心までの距離
dt=0.1;
%ロボットの初期位置
pRobot=[0.2,0.1,-0.1,-0.1,0.1,0.2;...
    0,-0.1,-0.1,0.1,0.1,0;...
    1,1,1,1,1,1];
figure(1);
plot(pRobot(1,:),pRobot(2,:),':');
axis equal;
axis([-2 2 -2 2]);
xlabel('X [m]');
ylabel('Y [m]');
grid on;
%ロボットの初期中心位置(0,0)を設定
x0=0;
y0=0;
%ロボットの初期進行方位角を設定
theta0=0*pi/180; %角度->ラジアン
%ロボットの目標位置と進行方位角を設定
xf=1;
yf=1;
thetaf=10*pi/180; %角度（-90< <90）の範囲->ラジアン
%軌道のパラメータ
A = [ ...
    x0^4,        x0^3,        x0^2,   x0, 1;  % y(x0) = y0
    4*x0^3,      3*x0^2,      2*x0,   1,  0;  % y'(x0) = tan(theta0)
    12*x0^2,     6*x0,        2,      0,  0;  % y''(x0) = 0 (smooth curvature at start)
    xf^4,        xf^3,        xf^2,   xf, 1;  % y(xf) = yf
    4*xf^3,      3*xf^2,      2*xf,   1,  0]; % y'(xf) = tan(thetaf)

b = [ ...
    y0; ...
    tan(theta0); ...
    0; ...          % desired start curvature
    yf; ...
    tan(thetaf) ];

apara = A \ b;      % Solve for [a4 a3 a2 a1 a0]^T

a4 = apara(1)
a3 = apara(2)
a2 = apara(3)
a1 = apara(4)
a0 = apara(5)

%% ---- Trajectory generation ----------------------------------------
% Sample x along the path
Trajx = [0:0.05:xf, xf];

% Position
Trajy = a4*Trajx.^4 + a3*Trajx.^3 + a2*Trajx.^2 + a1*Trajx + a0;
%並進速度
Trajv=hypot(diff(Trajy),diff(Trajx))/dt;
%進行方位角
Trajtheta=atan2(diff(Trajy),diff(Trajx));
Trajtheta=Trajtheta([1,1:end]);
%前輪ステアリング角
TrajsteeringAngle=atan(diff(Trajtheta)*L./(Trajv*dt));
%ロボットの現在中心位置
x=Trajx(1);
y=Trajy(1);
%ロボットの現在進行方位角
theta=Trajtheta(1);
outp=zeros(size(Trajv,2),2); %ロボットの位置記録用
for i=1:length(Trajv)
   %ロボットの進行方位角を更新
   theta=theta+Trajv(i)/L*tan(TrajsteeringAngle(i))*dt;
   %ロボットの位置を更新
   x=x+Trajv(i)*cos(theta)*dt;
   y=y+Trajv(i)*sin(theta)*dt;
   %ロボットの位置を記録
   outp(i,1)=x;
   outp(i,2)=y;
   T=[cos(theta),-sin(theta),x;...
       sin(theta),cos(theta),y;...
       0,0,1];
   npRobot=T*pRobot;
   figure(1);
   %軌道を円マーカー付の黒い点線で表す
   plot(Trajx,Trajy,':ko',npRobot(1,:),npRobot(2,:));
   hold on;
   %ロボットの中心位置を赤い点線で表す
   plot(outp(1:i,1),outp(1:i,2),':r','LineWidth',2);
   hold off;
   axis equal;
   axis([-2 2 -2 2]);
   xlabel('X [m]');
   ylabel('Y [m]');
   grid on;
end