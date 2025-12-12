if flag==0 %順運動学
    %関節１の値をui1から読み込み
    %角度->ラジアン
    theta1=str2double(get(ui1,'string'))*pi/180;
    %関節２の値をui2から読み込み
    %角度->ラジアン
    theta2=str2double(get(ui2,'string'))*pi/180;
    theta3=str2double(get(ui13,'string'))*pi/180; %角度->ラジアン（関節３） 
end
if flag==1 %逆運動学 ケース１
    %先端位置xの値をui6から読み込み
    x=str2double(get(ui6,'string'));
    %先端位置yの値をui7から読み込み
    y=str2double(get(ui7,'string'));
    phi_des=str2double(get(ui9,'string'))*pi/180; %先端姿勢phiの目標値[rad]  
    xe = x - a3*cos(phi_des); %有効先端位置x（2リンク用） 
    ye = y - a3*sin(phi_des); %有効先端位置y（2リンク用） 
    %関節１の回転角度を計算
    theta1=atan2((xe^2+ye^2+a1^2-a2^2)/(2*a1*sqrt(xe^2+ye^2)),... 
        sqrt(1-((xe^2+ye^2+a1^2-a2^2)/(2*a1*sqrt(xe^2+ye^2)))^2))... 
        -atan2(xe,ye); % //<----
    %関節２の回転角度を計算
    theta2=atan2(sqrt(1-((xe^2+ye^2-a1^2-a2^2)/(2*a1*a2))^2),... 
        (xe^2+ye^2-a1^2-a2^2)/(2*a1*a2)); 
    theta3 = phi_des - (theta1 + theta2); %関節３の回転角度を計算 
    set(ui12,'Visible','on'); %ui12（'Next'ボタン）を可視
end
if flag==2 %逆運動学 ケース２
    x=str2double(get(ui6,'string'));
    y=str2double(get(ui7,'string'));
    phi_des=str2double(get(ui9,'string'))*pi/180; %先端姿勢phiの目標値[rad]
    xe = x - a3*cos(phi_des); %有効先端位置x（2リンク用） 
    ye = y - a3*sin(phi_des); %有効先端位置y（2リンク用） 
    theta1=atan2((xe^2+ye^2+a1^2-a2^2)/(2*a1*sqrt(xe^2+ye^2)),... 
        -sqrt(1-((xe^2+ye^2+a1^2-a2^2)/(2*a1*sqrt(xe^2+ye^2)))^2))... 
        -atan2(xe,ye); % //<----
    theta2=atan2(-sqrt(1-((xe^2+ye^2-a1^2-a2^2)/(2*a1*a2))^2),... 
        (xe^2+ye^2-a1^2-a2^2)/(2*a1*a2)); 
    theta3 = phi_des - (theta1 + theta2); %関節３の回転角度を計算 % 
    set(ui12,'Visible','off');
end
A0=[cos(theta1),-sin(theta1),0,0;...
    sin(theta1),cos(theta1),0,0;...
    0,0,1,0;...
    0,0,0,1]; %座標系１から基準座標系への同次変換行列
A1=[cos(theta1),-sin(theta1),0,a1*cos(theta1);...
    sin(theta1),cos(theta1),0,a1*sin(theta1);...
    0,0,1,0;...
    0,0,0,1]; %座標系２から座標系１への同次変換行列
A2=[cos(theta2),-sin(theta2),0,a2*cos(theta2);...
    sin(theta2),cos(theta2),0,a2*sin(theta2);...
    0,0,1,0;...
    0,0,0,1]; %先端座標系から座標系２への同次変換行列
A3 = [cos(theta3),-sin(theta3),0,a3*cos(theta3); ... 
      sin(theta3), cos(theta3),0,a3*sin(theta3); ... 
      0,          0,           1,0; ...
      0,          0,           0,1]; 
%アーム位置の更新
T01 = A1; %リンク１終端（関節２）への同次変換行列 
T02 = A1*A2; %リンク２終端（関節３）への同次変換行列 
T03 = A1*A2*A3; %先端座標系への同次変換行列 
npB0_1=A0*pB0_1; 
npB0_2=A0*pB0_2; 
npB1=T01*pB0; 
npB1_1=T01*pB0_1; 
npB1_2=T01*pB0_2; 
npB2=T02*pB0; %関節３の位置 
npB2_1=T02*pB0_1; 
npB2_2=T02*pB0_2; 
npT=T03*pB0; 
npT_1=T03*pB0_1; 
npT_2=T03*pB0_2; 
if flag==0 %順運動学
    x=npT(1); %先端位置xの値
    y=npT(2); %先端位置yの値
    z=npT(3); %先端位置zの値
    R=A1(1:3,1:3)*A2(1:3,1:3); %回転行列
    R=R*A3(1:3,1:3); %先端までの回転行列に更新
    %先端姿勢phi
    phi=atan2(R(2,1),R(1,1));
    %先端姿勢theta
    theta=atan2(R(3,1),sqrt(R(1,1)^2+R(2,1)^2));
    %先端姿勢psi
    psi=atan2(R(3,2),R(3,3));
    %ui6の値を更新
    set(ui6,'string',num2str(x));
    %ui7の値を更新
    set(ui7,'string',num2str(y));
    %ui8の値を更新
    set(ui8,'string',num2str(z));
    %ui9の値を更新
    set(ui9,'string',num2str(phi*180/pi));
    %ui10の値を更新
    set(ui10,'string',num2str(theta*180/pi));
    %ui11の値を更新
    set(ui11,'string',num2str(psi*180/pi));
else %逆運動学
    %ui1の値を更新
    set(ui1,'string',num2str(theta1*180/pi));
    %ui2の値を更新
    set(ui2,'string',num2str(theta2*180/pi));
    set(ui13,'string',num2str(theta3*180/pi)); 
    %ui9の値を更新
    set(ui9,'string',num2str((theta1+theta2+theta3)*180/pi));
    if flag==2
        figure(1);
        hold on
    end
end
figure(1);
dcirA=0:0.01:2*pi;
dcirR=0.05;
dcir=[dcirR*cos(dcirA);dcirR*sin(dcirA)];
figure(1);
plot([npB0_1(1),npB1_1(1)],[npB0_1(2),npB1_1(2)],...
    'LineWidth',3);
hold on;
plot([npB0_2(1),npB1_2(1)],[npB0_2(2),npB1_2(2)],...
    'LineWidth',3);
plot([npB1_1(1),npB2_1(1)],[npB1_1(2),npB2_1(2)],... 
    'LineWidth',3); 
plot([npB1_2(1),npB2_2(1)],[npB1_2(2),npB2_2(2)],... 
    'LineWidth',3); 
plot([npB2_1(1),npT_1(1),npT_2(1),npB2_2(1)],... 
    [npB2_1(2),npT_1(2),npT_2(2),npB2_2(2)],'LineWidth',3); 
pDraw=pB0;
plot(dcir(1,:)+pDraw(1)*ones(size(dcir(1,:))),...
    dcir(2,:)+pDraw(2)*ones(size(dcir(2,:))),'r',...
'LineWidth',3);
pDraw=npB1;
plot(dcir(1,:)+pDraw(1)*ones(size(dcir(1,:))),...
    dcir(2,:)+pDraw(2)*ones(size(dcir(2,:))),'r',...
    'LineWidth',3);
pDraw=npB2; %関節３の表示 
plot(dcir(1,:)+pDraw(1)*ones(size(dcir(1,:))),... 
    dcir(2,:)+pDraw(2)*ones(size(dcir(2,:))),'r',...
    'LineWidth',3); 
hold off;
axis equal;
axis([-0.5 1.5 -0.5 1.5]);
xlabel('X [m]');
ylabel('Y [m]');
grid on;
hold on;
xline(x, ':k', 'LineWidth', 1.5);
yline(y, ':k', 'LineWidth', 1.5);
hold off;