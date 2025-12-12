clear; clc;

% Load robot
robot = setupUR5();

% Select DoF
n = numel(robot.homeConfiguration);

% Initial state
q0    = zeros(1,n);      % all joints at 0
qdot0 = zeros(1,n);
state = [q0 qdot0];

% Simulation parameters
dt   = 0.002;   % 2 ms
Tend = 3.0;     % a bit longer to reach target
T    = 0:dt:Tend;
K    = numel(T);

% Target in task space (x,y,z) in meters, base frame
% Adjust as desired; keep reachable
target = [0.45, -0.20, 0.35];

% Generate task-space trajectory
traj = generateTaskTrajectory(robot, q0, target, T);

% Impedance parameters
params.K    = [120; 120; 160];     % N/m
params.D    = [30;  30;  35 ];     % N·s/m
params.M    = [1.0; 1.0; 1.0];     % virtual mass (kg)
params.bbox = [0.05 0.05 0.05];    % half-widths [m]
params.Fmax = 30;                  % max force [N] inside bbox

% Logging arrays
Q     = zeros(K, n);
Tau   = zeros(K, n);
X     = zeros(K, 3);
Xd    = traj.xd;
V     = zeros(K, 3);
Ftask = zeros(K, 3);
Fraw  = zeros(K, 3);
InBox = false(K,1);

for k = 1:K
    q    = state(1:n);
    qdot = state(n+1:end);

    des.xd    = Xd(k,:);
    des.vd    = traj.vd(k,:);
    des.ad    = traj.ad(k,:);
    des.target= target;

    [tau, out] = taskImpedanceControl(robot, q, qdot, des, params);

    % Integrate plant
    dq = simpleUR5Plant(T(k), state, robot, tau);
    state = state + dq' * dt;

    % Log
    Q(k,:)     = q;
    Tau(k,:)   = tau;
    X(k,:)     = out.p;
    V(k,:)     = out.v;
    Ftask(k,:) = out.F;
    Fraw(k,:)  = out.Fraw;
    InBox(k)   = out.inBox;
end

% --- Plots: Task-space tracking ---
figure;
subplot(3,1,1); hold on; grid on;
plot(T, X(:,1), 'LineWidth', 1.8);
plot(T, Xd(:,1), '--', 'LineWidth', 1.6);
ylabel('x [m]'); legend('Actual','Desired'); title('Task-Space Position Tracking');
subplot(3,1,2); hold on; grid on;
plot(T, X(:,2), 'LineWidth', 1.8);
plot(T, Xd(:,2), '--', 'LineWidth', 1.6);
ylabel('y [m]');
subplot(3,1,3); hold on; grid on;
plot(T, X(:,3), 'LineWidth', 1.8);
plot(T, Xd(:,3), '--', 'LineWidth', 1.6);
ylabel('z [m]'); xlabel('Time [s]');

% --- Plot task-space force and limiting ---
Fn  = vecnorm(Ftask,2,2);
Fn0 = vecnorm(Fraw,2,2);
figure; hold on; grid on;
plot(T, Fn0, ':', 'LineWidth', 1.2);
plot(T, Fn,  '-', 'LineWidth', 1.8);
yline(params.Fmax, '--r', 'F_{max}');
xlabel('Time [s]'); ylabel('||F|| [N]');
legend('Raw','Applied','F_{max}');
title('Task-Space Force with Bounding-Box Limiter');

% --- Simple Animation ---
figure;
ax = show(robot, Q(1,:), 'Frames','off', 'PreservePlot', false);
view(135, 15);
hold on;
title('UR5 Animation (Task Impedance)');

% Plot desired final target and a small bounding box wireframe
plot3(target(1), target(2), target(3), 'rx', 'MarkerSize', 10, 'LineWidth', 2);
bx = params.bbox(1); by = params.bbox(2); bz = params.bbox(3);
boxPts = target + 0.5*[
    -2*bx -2*by -2*bz;
    -2*bx -2*by  2*bz;
    -2*bx  2*by -2*bz;
    -2*bx  2*by  2*bz;
     2*bx -2*by -2*bz;
     2*bx -2*by  2*bz;
     2*bx  2*by -2*bz;
     2*bx  2*by  2*bz];
% draw edges
edges = [1 2; 1 3; 1 5; 2 4; 2 6; 3 4; 3 7; 4 8; 5 6; 5 7; 6 8; 7 8];
for e = 1:size(edges,1)
    p1 = boxPts(edges(e,1),:); p2 = boxPts(edges(e,2),:);
    plot3([p1(1) p2(1)],[p1(2) p2(2)],[p1(3) p2(3)],'r-','LineWidth',0.5);
end

for k = 1:20:K  % skip frames for speed
    show(robot, Q(k,:), 'Frames','off', 'PreservePlot', false, 'Parent', ax);
    drawnow;
end
