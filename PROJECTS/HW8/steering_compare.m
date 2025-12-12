%% Comparison of 3rd-order vs 4th-order Polynomial Trajectories
clear; close all; clc;

%% Robot / motion setup
x0 = 0;          % start x
y0 = 0;          % start y
theta0 = 1*pi/180;

xf = 1;          % goal x
yf = 1.5;        % goal y
thetaf = 10*pi/180;

%% ==============================================================
%                       3rd-ORDER POLYNOMIAL
% ==============================================================

% 4 constraints (start/end position + start/end slope)
A3 = [ x0^3, x0^2, x0, 1;
       3*x0^2, 2*x0, 1, 0;
       xf^3, xf^2, xf, 1;
       3*xf^2, 2*xf, 1, 0 ];

b3 = [ y0;
       tan(theta0);
       yf;
       tan(thetaf) ];

a3p = A3 \ b3;

a3_3 = a3p(1);
a3_2 = a3p(2);
a3_1 = a3p(3);
a3_0 = a3p(4);

%% ==============================================================
%                       4th-ORDER POLYNOMIAL
% ==============================================================

% 5 constraints (position, slope, zero curvature)
A4 = [ ...
    x0^4,        x0^3,        x0^2,   x0, 1;   % y(0)
    4*x0^3,      3*x0^2,      2*x0,   1,  0;   % y'(0)
    12*x0^2,     6*x0,        2,      0,  0;   % y''(0)=0
    xf^4,        xf^3,        xf^2,   xf, 1;   % y(xf)
    4*xf^3,      3*xf^2,      2*xf,   1,  0 ]; % y'(xf)

b4 = [ y0;
       tan(theta0);
       0;              % curvature at start
       yf;
       tan(thetaf) ];

a4p = A4 \ b4;

a4_4 = a4p(1);
a4_3 = a4p(2);
a4_2 = a4p(3);
a4_1 = a4p(4);
a4_0 = a4p(5);

%% ==============================================================
%                  Evaluate both trajectories
% ==============================================================

x = linspace(x0, xf, 200);

% Cubic polynomial
y_cubic = a3_3*x.^3 + a3_2*x.^2 + a3_1*x + a3_0;
y2_cubic = 6*a3_3*x + 2*a3_2;   % second derivative

% Quartic polynomial
y_quartic = a4_4*x.^4 + a4_3*x.^3 + a4_2*x.^2 + a4_1*x + a4_0;
y2_quartic = 12*a4_4*x.^2 + 6*a4_3*x + 2*a4_2;

%% ==============================================================
%                           Plot results
% ==============================================================

figure;

% ------------------ TOP PLOT: Trajectories ---------------------
subplot(2,1,1);
plot(x, y_cubic, 'b-', 'LineWidth', 2); hold on;
plot(x, y_quartic, 'r--', 'LineWidth', 2);
legend('3rd-order (cubic)', '4th-order (quartic)');
title('Trajectory Comparison');
xlabel('x'); ylabel('y');
grid on;

% ------------------ BOTTOM PLOT: y''''(x) -----------------------
subplot(2,1,2);
plot(x, y2_cubic, 'b-', 'LineWidth', 2); hold on;
plot(x, y2_quartic, 'r--', 'LineWidth', 2);
legend('3rd-order acceleration / curvature', ...
       '4th-order acceleration / curvature');
title('Second Derivative y''''(x) Comparison');
xlabel('x'); ylabel('y''''(x)');
grid on;

