function [sortedXYZ,sortedRPY,idx] = helperROS2CreatePathFromWaypoints(xyz,rpy)
%helperROS2CreatePathFromWaypoints Utility function to create path from given
% waypoints.

%   Copyright 2024 The MathWorks, Inc.

% Remove elements above a certain height
maxHeight = 0.25;
tidx = find(xyz(:,3)<maxHeight);
xyz = xyz(tidx,:);
rpy = rpy(tidx,:);

% Remove points beyond a certain width
maxWidth = 0.5;
tidx = find(xyz(:,1)<maxWidth);
xyz = xyz(tidx,:);
rpy = rpy(tidx,:);

% Sort the waypoints by Z coordinate
wps = sortrows(xyz,3,"descend");

% Initialize variables
sortedXYZ = [];
currentZ = wps(1, 3);
sameZWaypoints = [];
reverse = false;
tol = 0.02;

% Loop over waypoints
for i = 1:size(wps, 1)
    if wps(i, 3) <= currentZ - tol
        % Sort the waypoints with the same Z coordinate by X coordinate
        if reverse
            sameZWaypoints = sortrows(sameZWaypoints,1,"descend");
        else
            sameZWaypoints = sortrows(sameZWaypoints, 1);
        end
        sortedXYZ = [sortedXYZ; sameZWaypoints];
        
        % Start a new list of waypoints with the new Z coordinate
        sameZWaypoints = wps(i, :);
        currentZ = wps(i, 3);
        
        % Flip the reverse flag for the next row
        reverse = ~reverse;
    else
        sameZWaypoints = [sameZWaypoints; wps(i, :)];
    end
end

% Don't forget to sort and add the last group of waypoints
if reverse
    sameZWaypoints = sortrows(sameZWaypoints, 1,"descend");
else
    sameZWaypoints = sortrows(sameZWaypoints, 1);
end

sortedXYZ = [sortedXYZ; sameZWaypoints];

[~,idx] = ismember(sortedXYZ,xyz,'rows');

sortedRPY = rpy(idx,:);
end