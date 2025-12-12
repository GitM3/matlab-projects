function flippedNormals = helperROS2FlipNormalsTowardsSensor(normals,sensorCenter,xyz)
%helperROS2FlipNormalsTowardsSensor Utility function to flip normals towards
%sensor

%   Copyright 2024 The MathWorks, Inc.

    u = normals(1:end,1);
    v = normals(1:end,2);
    w = normals(1:end,3);

    for k = 1:size(xyz,1) 
       p1 = sensorCenter - [xyz(k,1),xyz(k,2),xyz(k,3)];
       p2 = [u(k),v(k),w(k)];
       % Flip the normal vector if it is not pointing towards the sensor.
       angle = atan2(norm(cross(p1,p2)),p1*p2');
       if angle > pi/2 || angle < -pi/2
           u(k) = -u(k);
           v(k) = -v(k);
           w(k) = -w(k);
       end
    end

    flippedNormals = [u,v,w];

end
