% Copyright 2024 The MathWorks, Inc.

% Inspect "Actor" and its subfolders
if ~exist('Actors/meshes/ur5e/collision/base.stl','file') || ...
        ~exist('Actors/meshes/ur5e/visual/base.dae','file')
    error('Missing mesh files for UR5e, please download from Github repository and place into Actors/meshes folder.');
end

% Add "Actor" and its subfolders to the search path
addpath(genpath('Actors'));

% Create Simulation 3D world
world = sim3d.World();
viewport = createViewport(world);
viewport.Translation = [2 -3 1];
viewport.Rotation = [0 -pi/10 pi/5];

lights = sim3d.Light(ActorName='Lights',NumberofLights=3,Translation=[4,-3,3; 4,-1,3; 4,1,3]);

% Load and configure UR5e robot
robotMesh = importrobot('ur5e_with_gripper.urdf');
robot = sim3d.Actor('ActorName','ur5e','Mobility',sim3d.utils.MobilityTypes.Movable);
world.add(robot);
robot.Shadows = 1;
robot.Shininess = 1;
robot.Metallic = 1;
robot.Flat = 1;
robot.Color = [.255 .255 .255];       
robot.Translation = [ 4 -2 0.55];
robot.Rotation = [0 0 pi/2];
robot.load(robotMesh);
propagate(world.Actors.('ur5e'),'Shininess',1,'all')
propagate(world.Actors.('ur5e'),'Metallic',1,'all')
propagate(world.Actors.('ur5e'),'Flat',1,'all')
propagate(world.Actors.('ur5e'),'Color',[.255 .255 .255],'all')
propagate(world.Actors.('ur5e'),'Shadows',1,'all')
propagate(world.Actors.('ur5e'),'Mobility',sim3d.utils.MobilityTypes.Movable)

% Load and configure fuselage
fuselage = sim3d.Actor('ActorName','fuselage','Mobility',sim3d.utils.MobilityTypes.Static);
world.add(fuselage);
fuselage.Shadows = 1;
fuselage.Shininess = 0;
fuselage.Metallic = 0.1;
fuselage.Flat = 1;
fuselage.Color = [2.55, 2.55, 2.55];
fuselage.Translation = [6.8 -2.2 -.45];
fuselage.Rotation = [0 0 pi/2];
fuselage.load('fuselage_link.mat');

% Load and configure scaled stand
standMesh = "binPickingStand_scaled.stl";
stand = sim3d.Actor('ActorName','stand','Mobility',sim3d.utils.MobilityTypes.Static);
world.add(stand);
stand.Shadows = 1;
stand.Shininess = 1;
stand.Metallic = 0;
stand.Flat = 1;
stand.Color = [1, 1, 1];
stand.Translation = [4 -2 0];
stand.Rotation = [0 0 pi];
stand.load(standMesh);

% Add planes to the world
plane = sim3d.Actor('ActorName','plane');
createShape(plane,'plane', [15, 15, 2]);
plane.Color = [1, 1, 1];
plane.Shininess = 0.8;
plane.Metallic = 1;
plane.TwoSided = 0; 
world.add(plane);
plane.Translation = [4 -1.5 0];
plane.Rotation = [0, 0, 0];
plane.Scale = [1, 1, 1];

plane = sim3d.Actor('ActorName','plane');
createShape(plane,'plane', [6, 15, 2]);
plane.Color = [1, 1, 1];
plane.Transparency = 0.115;
plane.Shininess = 1;
plane.Metallic = 1;
plane.TwoSided = 1;      
world.add(plane);
plane.Translation = [11.5 -1.5 3];
plane.Rotation = [0, pi/2, 0];
plane.Scale = [1, 1, 1];

plane = sim3d.Actor('ActorName','plane');
createShape(plane,'plane', [15, 6, 2]);
plane.Color = [1, 1, 1];
plane.Transparency = 0.115;
plane.Shininess = 1;
plane.Metallic = 1;
plane.TwoSided = 1;   
world.add(plane);
plane.Translation = [4 6 3];
plane.Rotation = [pi/2, 0, 0];
plane.Scale = [1, 1, 1];

plane = sim3d.Actor('ActorName','plane');
createShape(plane,'plane', [15, 6, 2]);
plane.Color = [1, 1, 1];
plane.Transparency = 0.115;
plane.Shininess = 1;
plane.Metallic = 1;
plane.TwoSided = 1;   
world.add(plane);
plane.Translation = [4 -9 3];
plane.Rotation = [pi/2, 0, 0];
plane.Scale = [1, 1, 1];

%run(world,0.01,500)
save(world,'robotComponents');