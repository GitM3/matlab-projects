
a1=1;
a2=1;
pB0=[0;0;0;1]; 
pB0_1=pB0+[0;0.05;0;0];
pB0_2=pB0+[0;-0.05;0;0];
pB1=[a1;0;0;1];
pB1_1=pB1+[0;0.05;0;0];
pB1_2=pB1+[0;-0.05;0;0];
pB2_1=pB1+[0;0.05;0;0];
pB2_2=pB1+[0;-0.05;0;0];
pT=[a1+a2;0;0;1];
pT_1=pT+[0;0.05;0;0];
pT_2=pT+[0;-0.05;0;0];
Nframes = 25;
T1 = length(simout.time) /3;
T2 = 2*T1;
for i=1:length(simout.time)
    theta1=simout.data(i,1);
    theta2=simout.data(i,2);
    A0=[cos(theta1),-sin(theta1),0,0;...
        sin(theta1),cos(theta1),0,0;...
        0,0,1,0;...
        0,0,0,1];
    A1=[cos(theta1),-sin(theta1),0,a1*cos(theta1);...
        sin(theta1),cos(theta1),0,a1*sin(theta1);...
        0,0,1,0;...
        0,0,0,1];
    A2=[cos(theta2),-sin(theta2),0,a2*cos(theta2);...
        sin(theta2),cos(theta2),0,a2*sin(theta2);...
        0,0,1,0;...
        0,0,0,1];
    npB0_1=A0*pB0_1;
    npB0_2=A0*pB0_2;
    npB1=A1*pB0;
    npB1_1=A1*pB0_1;
    npB1_2=A1*pB0_2;
    npB2_1=A1*[A2(1:3,1:3),zeros(3,1);zeros(1,3),1]*pB0_1;
    npB2_2=A1*[A2(1:3,1:3),zeros(3,1);zeros(1,3),1]*pB0_2;
    npT=A1*A2*pB0;
    npT_1=A1*A2*pB0_1;
    npT_2=A1*A2*pB0_2;
    figure(1);
    dcirA=0:0.01:2*pi;
    dcirR=0.05;
    dcir=[dcirR*cos(dcirA);dcirR*sin(dcirA)];
    figure(1);
    mycolor1='b';    %アームを描く線の設定（青い実線）
    mycolor2='r';    %関節を描く線の設定（赤い実線）
    flg_draw=0;      %図を描くかどうかのフラグ
    %毎周期に図を描くかどうかのフラグ
    % 0：最初，中間，最終の周期の結果を描く
    % 1：毎周期の結果を描く
    flg_drawCont=0;
    if flg_drawCont~=1
        flg_draw=0;
        if mod(i,Nframes)==0
            flg_draw=1;
            if i<= T1 %最初と中間の周期
                mycolor1='g:';
                mycolor2='g:';
              
            elseif i<= T2 %最初と中間の周期
                mycolor1='y:';
                mycolor2='y:';
               
           
            else
                mycolor1='b:';
                mycolor2='r:';
            end
        end
        if i==length(simout.time) %最終の周期
            mycolor1='b';
            mycolor2='r';
            flg_draw=1;
        end
    end
    if flg_draw==1
        plot([npB0_1(1),npB1_1(1)],[npB0_1(2),npB1_1(2)],...
            mycolor1,'LineWidth',3);
        hold on;
        plot([npB0_2(1),npB1_2(1)],[npB0_2(2),npB1_2(2)],...
            mycolor1,'LineWidth',3);
        plot([npB2_1(1),npT_1(1),npT_2(1),npB2_2(1)],...
            [npB2_1(2),npT_1(2),npT_2(2),npB2_2(2)],...
            mycolor1,'LineWidth',3);
        pDraw=pB0;
        plot(dcir(1,:)+pDraw(1)*ones(size(dcir(1,:))),...
            dcir(2,:)+pDraw(2)*ones(size(dcir(2,:))),...
            mycolor2,'LineWidth',3);
        pDraw=npB1;
        plot(dcir(1,:)+pDraw(1)*ones(size(dcir(1,:))),...
            dcir(2,:)+pDraw(2)*ones(size(dcir(2,:))),...
            mycolor2,'LineWidth',3);
        if flg_drawCont==1
            hold off;
        end
    end
    axis equal;
    axis([-1 3 -1 3]);
    xlabel('X [m]');
    ylabel('Y [m]');
    grid on;
end 
