**Overview**
- **Scope:** Summary of two example projects under `examples/` with emphasis on Simulink structure, component interactions, helper functions, and required toolboxes.
- **Projects:**
  - `shared_robotics_ros/DesignControllerThroughSimulinkAndUnrealEngineCosimExample` — Simulink + Unreal Engine co-sim of UR5e tracing shapes from a scanned scene.
  - `urseries/SimulateUR5MATLABAndGazeboGlueDispensingWindshieldExample` — MATLAB + Gazebo workflow for UR5 glue dispensing.

**Repository Layout**
- `shared_robotics_ros/DesignControllerThroughSimulinkAndUnrealEngineCosimExample/ShapeTracingSimExample.slx`: Simulink model.
- `shared_robotics_ros/DesignControllerThroughSimulinkAndUnrealEngineCosimExample/*.m`: helper scripts for scene setup and processing.
- `urseries/SimulateUR5MATLABAndGazeboGlueDispensingWindshieldExample/*.m`: helper functions for waypoints, orientations, trajectory, and ROS launch.
- `urseries/SimulateUR5MATLABAndGazeboGlueDispensingWindshieldExample/*.STL`: visuals for dispenser and windshield.
- `urseries/.../SimulateUR5MATLABAndGazeboGlueDispensingWindshieldExample.mlx`: Live Script workflow.

**Shape Tracing (Simulink + Unreal)**
- **Model:** `shared_robotics_ros/DesignControllerThroughSimulinkAndUnrealEngineCosimExample/ShapeTracingSimExample.slx`
- **Goal:** Simulate a UR5e robot in an Unreal scene; acquire scene geometry via on-robot camera + lidar; extract a surface path; generate a joint-space trajectory (minimum-jerk); execute the motion in the Unreal environment.

**Key Data Flow**
- **Scene & Robot Setup:**
  - `InitFcn` of the model imports the robot RBT: `robotMesh = importrobot('ur5e_with_gripper.urdf');` (used by the Simulation 3D Robot block).
  - Optional prebuilt scene assets are loaded by the Simulink “Simulation 3D Actor” block from `robotComponents.mat` (created by `helperSetupSim3DScene.m`).
- **Sensors → Point Cloud:**
  - `Simulation 3D Camera Get`: streams RGB frames to `To Video Display`.
  - `Simulation 3D Lidar`: streams 3D points to `Point Cloud Viewer` and to a MATLAB Function block.
- **Point Cloud → Joint Segments:**
  - `MATLAB Function` (Stateflow EML): function `fcn(pcloudXYZ)`
    - If `jointConfigs` not in base workspace, calls `helperGenerateJointConfig(pcloudXYZ)` to compute joint-space waypoints from the scanned cylindrical fuselage. Else, reuses base `jointConfigs`.
    - Output: matrix `[6 x N]` joint configurations.
- **Joint Segments → Timed Waypoints:**
  - `MATLAB Function2` (Stateflow EML): function `processJointSegments(jointSegments,isNew,currTime,release,speed)`
    - Slices/advances through the columns of `jointSegments`, generating `[wayPoints, timePoints]` for the next segment based on the current simulation time, a release toggle, and a speed factor.
    - Maintains internal `persistent` index and timing (`del = 0.5/speed`). Supports reversing at segment ends.
- **Waypoints → Trajectory:**
  - `Minimum Jerk Polynomial Trajectory` (`robotutilslib`/`shareduavrstlib`): produces joint positions, velocities, and accelerations for the provided `[wayPoints, timePoints]` with configured time allocation and limits.
- **Trajectory → Actuation:**
  - The 6 joint trajectories are demuxed and concatenated with auxiliary joints to form an 8‑element vector for the UR5e robot actor (matches `Simulation 3D Robot` expecting 8 inputs, including tool joints).
  - A `Switch` selects between a `HomeConfiguration` (8×1 constant) and the live trajectory based on an `Enable Motion` control.
  - `Simulation 3D Robot` drives the actor named `ur5e` with sample time `0.01`.

**Simulink Block Highlights**
- `Simulation 3D Scene Configuration` (`sim3dlib/robotsim3dlib`): launches the Unreal scene (Empty scene) with viewpoint and timing (`Ts = 0.01`).
- `Simulation 3D Robot` (`robotsim3dlib`):
  - Input type: `RigidBodyTree Object` = `robotMesh` from model init.
  - Actor name: `ur5e`; End effector: `epick_end_effector`; Initial 8‑DoF configuration zeros.
- `Simulation 3D Actor` (`sim3dlib`): loads `robotComponents.mat` which populates the world (UR5e actor, fuselage, stand, planes) created by `helperSetupSim3DScene.m`.
- `Simulation 3D Camera Get` and `Simulation 3D Lidar` (`sim3dlib/sim3dphyssensorlib`): sensors mounted on `ur5e` with specified offsets and FOV/resolution; feed visualization and processing.
- `Point Cloud Viewer` and `To Video Display` (Computer Vision Toolbox): visualize sensor outputs during sim.
- `Stateflow MATLAB Function` blocks: implement the EML logic for joint path generation and timed segmenting.
- `robotutilslib` Minimum Jerk: generates smooth joint trajectories.

**Helper MATLAB Files**
- `helperSetupSim3DScene.m`
  - Builds a `sim3d.World` with actors: `ur5e` (URDF `ur5e_with_gripper.urdf`), `fuselage` (mesh `fuselage_link.mat`), and a scaled stand STL.
  - Adds planes, lights, and saves the world to `robotComponents.mat` (consumed by the Simulink “Simulation 3D Actor” block).
  - Requires Unreal Engine Simulation support (Simulink 3D) to access `sim3d.*` APIs.
- `helperGenerateJointConfig.m`
  - Pipeline: transform lidar cloud to camera frame → segment dominant cylindrical surface (fuselage) via `pcsegdist` → fit cylinder (`pcfitcylinder`) → downsample → compute normals (`pcnormals`) → flip towards sensor → compute [yaw,pitch,roll] from normals → order waypoints via `helperROS2CreatePathFromWaypoints` → build end-effector poses → solve IK (BFGS GP) for a UR5e model with gripper (`inverseKinematics`) → return `[6×N]` joint configs and assign to base `jointConfigs`.
- `helperROS2CreatePathFromWaypoints.m`
  - Filters waypoints by height and width, then sorts by Z bands and alternates X order to create a raster-like path across the cylindrical surface.
- `helperROS2FlipNormalsTowardsSensor.m`
  - Ensures each normal vector points towards the sensor by checking angle w.r.t. sensor center and flipping as needed.
- `helperROS2AddGripper.m`
  - Augments a `rigidBodyTree` with an IO coupling, Robotiq EPick-like gripper, an extension tube, and a bellow; used in MATLAB-side IK workflows.

**How Components Interact**
- Unreal scene is configured by the Simulink Scene block; additional actors are injected via the “Simulation 3D Actor” block using the saved `robotComponents.mat` from `helperSetupSim3DScene.m`.
- The on-robot `Simulation 3D Lidar` provides point clouds to generate joint-space path (`MATLAB Function` → `helperGenerateJointConfig`).
- The joint path is segmented over simulation time by `MATLAB Function2`, feeding the minimum-jerk block to yield smooth joint trajectories.
- The `Switch` and `Enable Motion` gate motion execution; the 8‑element vector drives the UR5e via `Simulation 3D Robot`.
- Camera and Lidar outputs are visualized via Computer Vision scopes.

**Toolboxes and Requirements (Simulink + Unreal)**
- **Simulink:** base simulation environment.
- **Stateflow:** MATLAB Function (EML) blocks compiled as Stateflow charts.
- **Robotics System Toolbox:** `rigidBodyTree`, `inverseKinematics`, URDF import, `robotutilslib` trajectory block.
- **Computer Vision Toolbox:** point cloud types and ops (`pointCloud`, `pcsegdist`, `pcfitcylinder`, `pcnormals`, `removeInvalidPoints`, `Point Cloud Viewer` block, `To Video Display`).
- **Unreal Engine Simulation (Simulink 3D):** `sim3d.*` APIs and `Simulation 3D` blocks for scene, actor, camera, and lidar.
- Optional content assets under `Actors/meshes/...` referenced by `helperSetupSim3DScene.m`.

**Run Notes (Simulink + Unreal)**
- Ensure Unreal support is installed (Simulation 3D support package) and assets in `Actors/` are present (UR5e meshes).
- Run `helperSetupSim3DScene.m` to regenerate `robotComponents.mat` if needed.
- Open `ShapeTracingSimExample.slx`, set `Enable Motion`, and start simulation; view scopes for camera and point cloud.

**UR5 Glue Dispensing (MATLAB + Gazebo)**
- **Workflow File:** `urseries/SimulateUR5MATLABAndGazeboGlueDispensingWindshieldExample/SimulateUR5MATLABAndGazeboGlueDispensingWindshieldExample.mlx`
- **Goal:** Plan and validate a glue-dispensing trajectory on a windshield using MATLAB (rigid body tree + IK + minimum-jerk) and then validate on a simulated UR5 in Gazebo via ROS.

**High-Level Workflow (from Live Script)**
- Load UR5 model (`loadrobot("universalUR5")`) and attach a dispenser tool and a marker body (`dispenserEdge`) via `addBody` and fixed transforms.
- Visualize and interactively pose the robot (`interactiveRigidBodyTree`) to set orientations and collect tool poses on the windshield mesh.
- Select waypoints (mouse) and adjust end-effector orientations (keyboard) using helpers.
- Generate a smooth, constant TCP linear-velocity task-space trajectory; solve IK along task waypoints and smooth with minimum-jerk (`minjerkpolytraj`).
- Launch Gazebo with UR5 glue-dispensing package on a ROS device and execute trajectory via ROS.

**Helper MATLAB Files (Gazebo workflow)**
- `exampleHelperSelectWaypoints.m`
  - Mouse callback that appends clicked 3D points (intersection points) and plots markers. When called with an output, returns accumulated waypoints and clears internal state.
- `exampleHelperSetOrientations.m`
  - Keypress-driven orientation adjuster around the current waypoint for `dispenserEdge` using IK; buffers saved orientations/waypoints when user presses `c`; handles next waypoint with `n`.
- `exampleHelperGetFinalWaypointData.m`
  - Accumulates orientation/waypoint pairs (persistent state) and returns them when requested with outputs.
- `exampleHelperURGenerateTrajectory.m`
  - For each waypoint pair: interpolates tool transforms, solves IK per step, collects joint configs, and produces smoothed minimum-jerk joint trajectories and TCP path given `vel` and `dt`.
- `generateAndTransferLaunchScript*.m`
  - Creates a shell script on the remote ROS device to source workspace and `roslaunch ur_glue_dispensing_gazebo ur_glue_dispensing_gazebo.launch`, transfers it, and marks executable.

**Files and Assets (Gazebo workflow)**
- `glueDispenserMesh.STL`, `windshieldv3.stl`: visuals used for rig + scene in MATLAB.
- `ur_glue_dispensing_gazebo.zip`: ROS package archive to be deployed to the ROS device/workspace.

**Toolboxes and Requirements (MATLAB + Gazebo)**
- **Robotics System Toolbox:** rigid body tree modeling, IK, trajectory generation, interactive visualization.
- **Robotics System Toolbox Support Package for Universal Robots UR Series Manipulators.**
- **ROS Toolbox:** ROS device connection, file transfer, remote execution; Live Script references `urROSNode` for control.
- Gazebo with the provided UR glue-dispensing package on the remote ROS machine.

**Interlinking Across Projects**
- Both examples use UR5/UR5e RBT models and IK to convert task-space paths to joint-space trajectories.
- The Simulink example focuses on perception-driven path extraction (point cloud → normals → rasterized tool path) and online segmenting for trajectory streaming to Unreal.
- The Gazebo example focuses on interactive waypoint/orientation collection and offline trajectory computation in MATLAB, followed by ROS execution.

**Practical Tips**
- Ensure consistent end-effector naming: Simulink robot actor expects `epick_end_effector`, while MATLAB helpers sometimes use a `Bellow` or `dispenserEdge` body for IK target—align the EE body and transforms when reusing code.
- The Simulink trajectory concatenates 8 joints; if reusing for a 6‑DoF RBT, adapt vector sizing and the robot block configuration.
- For consistent raster path generation on curved surfaces, tune point cloud thresholds (`maxHeight`, `maxWidth`, Z‑band tolerance) in `helperROS2CreatePathFromWaypoints.m` and the cylinder fitting parameters in `helperGenerateJointConfig.m`.

**Getting Started**
- Simulink + Unreal:
  - Verify `sim3d` support, run `helperSetupSim3DScene.m`, open `ShapeTracingSimExample.slx`, and simulate.
- MATLAB + Gazebo:
  - Open the `.mlx`, execute sections in order, deploy the ROS package/workspace, run the generated launch script on the device, then execute the trajectory via the Live Script.

