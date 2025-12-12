function traj = generateTaskTrajectory(robot, q0, targetPos, T)
%GENERATETASKTRAJECTORY Simple min-jerk trajectory in task space (x,y,z).
%   traj = generateTaskTrajectory(robot, q0, targetPos, T)
%   - robot: rigidBodyTree
%   - q0: 1xN initial joint configuration
%   - targetPos: 1x3 desired [x y z] in base frame
%   - T: 1xK time vector
% Returns struct fields: xd (Kx3), vd (Kx3), ad (Kx3)
    
    eeName = robot.BodyNames{end};
    T0 = getTransform(robot, q0, eeName);
    p0 = T0(1:3,4)';

    pT = targetPos(:)';
    dp = pT - p0;

    K = numel(T);
    Tend = T(end) - T(1);
    if Tend <= 0
        error('Time vector must have positive duration');
    end

    xd = zeros(K,3); vd = zeros(K,3); ad = zeros(K,3);

    for k = 1:K
        tau = (T(k) - T(1)) / Tend; % normalized time [0,1]
        if tau < 0, tau = 0; end
        if tau > 1, tau = 1; end
        % Min-jerk scalar profile s(t)
        s   = 10*tau^3 - 15*tau^4 + 6*tau^5;
        ds  = (30*tau^2 - 60*tau^3 + 30*tau^4) / Tend;
        dds = (60*tau - 180*tau^2 + 120*tau^3) / (Tend^2);

        xd(k,:) = p0 + s   * dp;
        vd(k,:) =       ds  * dp;
        ad(k,:) =       dds * dp;
    end

    traj.xd = xd;
    traj.vd = vd;
    traj.ad = ad;
end

