function robot = setupUR5()
    % Load a URDF version of UR5
    robot = loadrobot("universalUR5");
    robot.DataFormat = 'row';
    robot.Gravity = [0 0 -9.81];
    %writeAsFunction(robot, "robot_for_simulink")
end
