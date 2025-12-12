function [dq, stateOut] = simpleUR5Plant(t, state, robot, tau)

    n = length(robot.homeConfiguration);

    q    = state(1:n)';        % now n×1 column
    qdot = state(n+1:end)';    % now n×1 column

    % Compute dynamics
    M = massMatrix(robot, q');
    C = velocityProduct(robot, q', qdot');
    G = gravityTorque(robot, q');

    % Convert to column vectors
    C = C(:);
    G = G(:);

    % Forward dynamics  qdd = M^{-1} (tau - C - G)
    qddot = M \ (tau(:) - C - G);

    % Output derivative of state, must be a column
    dq = [qdot; qddot];

    % Return same for debugging
    stateOut = dq;
end
