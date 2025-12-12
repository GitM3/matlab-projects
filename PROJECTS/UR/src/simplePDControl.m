function tau = simplePDControl(robot, q, qdot, qd, qdot_d)
    Kp = 60;    % increase if sluggish
    Kd = 10;    % damping

    e  = qd - q;
    de = qdot_d - qdot;

    % Gravity compensation
    G = gravityTorque(robot, q);

    tau = Kp*e + Kd*de + G;
end
