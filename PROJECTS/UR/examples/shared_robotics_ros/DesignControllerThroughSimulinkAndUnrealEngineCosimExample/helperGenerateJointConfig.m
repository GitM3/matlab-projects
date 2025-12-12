function jointConfigs = helperGenerateJointConfig(pcloudXYZ)
%helperGenerateJointConfig Generate joint configurations based on point
%cloud coordinates

%   Copyright 2024 The MathWorks, Inc.

    camera_eul = [-pi/2 0 0];
    rotm = eul2rotm(camera_eul,"ZYX");
    camera_translations = [0.033 0.289 0.2];
    tform = rigid3d(rotm,camera_translations);
    pcloud = removeInvalidPoints(pointCloud(double(pcloudXYZ)));
    pcloud = pctransform(pcloud,tform);
    % Segment and retain points for the cylindrical section
    [labels,numClusters] = pcsegdist(pcloud,0.01);
    N = histcounts(labels,numClusters);
    [~,maxLabelIdx] = max(N);
    fuselageLabelIdxs = find(labels==maxLabelIdx);
    fuselagePCloud = select(pcloud,fuselageLabelIdxs);
    % Clip points below the cut off height 
    topThreshold = 0.3;
    botThreshold = 0;
    fuselagePCloud1 = pointCloud(fuselagePCloud.Location(fuselagePCloud.Location(:,3)<topThreshold,:));
    fuselagePCloud2 = pointCloud(fuselagePCloud1.Location(fuselagePCloud1.Location(:,3)>botThreshold,:));
    [cylModel,inlierIndices,~,meanError] = pcfitcylinder(fuselagePCloud2,0.1,MaxNumTrials=10000,Confidence=99.5);
    pcCyl = select(fuselagePCloud2,inlierIndices);
    pc = pcdownsample(pcCyl,"gridAverage",0.05);
    xyz = pc.Location;
    D = pdist2(pcCyl.Location,pc.Location);
    [~,closestIndices] = min(D,[],1);
    normals = pcnormals(pcCyl,200);
    normals = normals(closestIndices,:);
    normals = -helperROS2FlipNormalsTowardsSensor(normals,camera_translations,xyz);
    
    yaw = atan2(normals(:,2),normals(:,1));
    pitch = atan2(-normals(:,3),sqrt(normals(:,1).^2 + normals(:,2).^2));
    roll = zeros(size(yaw));
    rpy = [yaw pitch roll];
    [xyz,rpy,idx] = helperROS2CreatePathFromWaypoints(xyz,rpy);
    normals = normals(idx,:);
    
    robot = importrobot('universalUR5e.urdf',DataFormat='column');
    helperROS2AddGripper(robot);
    robot.Bodies{3}.Joint.PositionLimits = [0 pi];
    robot.Bodies{4}.Joint.PositionLimits = [-pi 0];
    homeConfig =  [pi/2 -pi/2 pi/2 0 pi/2 0]';
    
    clear temp
    numPoints = length(rpy);
    tfs = eul2tform(rpy,"ZYX");
    tfs = pagemtimes(eul2tform([0 0 -pi/2],"ZYX"),tfs); % Static transform between robot base and end effector
    temp(:,1,:) = xyz';
    tfs(1:3,4,:) = temp;
    tfs(4,4,:) = 1;
    
    ik = inverseKinematics(RigidBodyTree=robot,SolverAlgorithm='BFGSGradientProjection');
    initialGuess = homeConfig;
    weights = [0.01 1 1 1 1 1];
    eeName = 'Bellow';
    
    jointConfigs = [];
    
    for i = 1:numPoints
        pose = tfs(:,:,i);
        [currJConfig,solInfo] = ik(eeName,pose,weights,initialGuess);
        if solInfo.PoseErrorNorm>=0.01       
                fprintf("Pose error %.2f in index %d at coordinate %.2f %.2f %.2f\n",solInfo.PoseErrorNorm,i,pose(1:3,4)');
        else
                initialGuess = currJConfig;
        end
        jointConfigs = [jointConfigs,(currJConfig)]; %#ok<AGROW>
    end

    assignin('base','jointConfigs', jointConfigs);
end