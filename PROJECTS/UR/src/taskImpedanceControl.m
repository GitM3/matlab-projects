function [tau, out] = taskImpedanceControl(robot, q, qdot, des, params)
%TASKIMPEDANCECONTROL Cartesian impedance with force limiting near target.
%   [tau, out] = taskImpedanceControl(robot, q, qdot, des, params)
%   des: struct with fields xd(1x3), vd(1x3), ad(1x3), target(1x3)
%   params: struct with fields K(3x1), D(3x1), M(3x1),
%           bbox(1x3) half-widths, Fmax scalar (norm cap)
% Returns joint torques and diagnostics in out.

    eeName = robot.BodyNames{end};

    % Forward kinematics and Jacobian
    T_ee = getTransform(robot, q, eeName);
    p    = T_ee(1:3,4); % 3x1
    J    = geometricJacobian(robot, q, eeName); % 6xN, [ang; lin]

    % Linear velocity from Jacobian
    v = J(4:6,:) * qdot(:); % 3x1

    xd = des.xd(:); vd = des.vd(:); ad = des.ad(:);

    % Task-space impedance wrench (force only)
    K = diag(params.K(:));
    D = diag(params.D(:));
    M = diag(params.M(:));

    e  = xd - p;      % position error
    ev = vd - v;      % velocity error

    F = K*e + D*ev + M*ad; % 3x1

    % Limit force within bounding box around target
    inBox = all(abs(p(:) - des.target(:)) <= params.bbox(:));
    F_unsat = F;
    if inBox
        nF = norm(F);
        if nF > params.Fmax
            F = F * (params.Fmax / nF);
        end
    end

    % Map to joint torques, gravity compensation
    G = gravityTorque(robot, q);
    tau = J(4:6,:)' * F + G(:);

    % Diagnostics
    out.p     = p(:)';
    out.v     = v(:)';
    out.F     = F(:)';
    out.Fraw  = F_unsat(:)';
    out.inBox = inBox;
end

