set(ui1,'string','0'); %ui1の値をリセット
set(ui2,'string','0'); %ui2の値をリセット
set(ui5,'string','0'); %ui5の値をリセット
set(ui6,'string','0'); %ui6の値をリセット
set(ui7,'string','0'); %ui7の値をリセット
figure(1);
plot(pRobot0(1,:),pRobot0(2,:),':');
axis equal;
axis([-1 1 -1 1]);
xlabel('X [m]');
ylabel('Y [m]');
grid on;
