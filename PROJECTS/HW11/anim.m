% Precompute joint circles
th = linspace(0,2*pi,50);
circle_x = 0.05*cos(th);
circle_y = 0.05*sin(th);

% Pre-allocate frames
F(length(simout.time)) = struct('cdata',[],'colormap',[]);

figure(1); clf;
axis equal; axis([-1 3 -1 3]); grid on; hold on;
xlabel('X [m]'); ylabel('Y [m]');

for i = 1:length(simout.time)
    theta1 = simout.data(i,1);
    theta2 = simout.data(i,2);

    % Forward kinematics (your matrices unchanged)
        A0=[cos(theta1),-sin(theta1),0,0; sin(theta1),cos(theta1),0,0; 0,0,1,0; 0,0,0,1];
    A1=[cos(theta1),-sin(theta1),0,a1*cos(theta1); 
        sin(theta1),cos(theta1),0,a1*sin(theta1); 0,0,1,0; 0,0,0,1];
    A2=[cos(theta2),-sin(theta2),0,a2*cos(theta2); 
        sin(theta2),cos(theta2),0,a2*sin(theta2); 0,0,1,0; 0,0,0,1];


    npB1 = A1*pB0;
    npT  = A1*A2*pB0;

    cla; hold on;

    % Plot arm segments
    plot([0 npB1(1) npT(1)], [0 npB1(2) npT(2)], 'b-', 'LineWidth', 3);

    % Joint circles
    plot(circle_x, circle_y, 'r', 'LineWidth', 2);
    plot(npB1(1) + circle_x, npB1(2) + circle_y, 'r', 'LineWidth', 2);

    % End effector
    plot(npT(1), npT(2), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k');

    drawnow;
    F(i) = getframe(gcf);
end

% Play animation
figure; movie(F,1,30);
