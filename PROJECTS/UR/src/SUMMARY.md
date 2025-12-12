# Summary: Task-Space Impedance Control Demo

This project adds a simple, modular task-space impedance controller and a min-jerk trajectory generator to the base UR5 example. The simulation runs in joint space with a dynamics plant, while the controller operates in the Cartesian task space for the end-effector position (x, y, z). A configurable bounding box around the target limits the task-space force near the goal. The demo logs and plots task-space tracking and force limiting, and animates the robot.

## Files
- `run.m`: Main script. Sets target, generates trajectory, runs simulation loop, logs data, plots, and animates.
- `setupUR5.m`: Loads the UR5 (`loadrobot("universalUR5")`), sets gravity and data format.
- `simpleUR5Plant.m`: Continuous-time forward dynamics for the UR5 and Euler integration hookup.
- `generateTaskTrajectory.m`: Min-jerk task-space trajectory from current EE position to target.
- `taskImpedanceControl.m`: Cartesian impedance controller with bounding-box force limiting and gravity compensation.
- `simplePDControl.m`: Original joint-space PD (unused in the new run; retained for reference).

## Trajectory Generation (min-jerk in task space)
Let the initial end-effector position be \(\mathbf{p}_0\in\mathbb{R}^3\) and the target be \(\mathbf{p}_T\in\mathbb{R}^3\). Define \(\Delta\mathbf{p}=\mathbf{p}_T-\mathbf{p}_0\). Over time \(t\in[0,T]\), with normalized time \(\tau= t/T\), use the standard min-jerk scalar profile:

$$
\begin{aligned}
 s(\tau) &= 10\tau^3 - 15\tau^4 + 6\tau^5,\\
 \dot{s}(\tau) &= \frac{30\tau^2 - 60\tau^3 + 30\tau^4}{T},\\
 \ddot{s}(\tau) &= \frac{60\tau - 180\tau^2 + 120\tau^3}{T^2}.
\end{aligned}
$$

The desired task-space trajectory is

$$
\begin{aligned}
 \mathbf{x}_d(t) &= \mathbf{p}_0 + s(\tau)\,\Delta\mathbf{p},\\
 \dot{\mathbf{x}}_d(t) &= \dot{s}(\tau)\,\Delta\mathbf{p},\\
 \ddot{\mathbf{x}}_d(t) &= \ddot{s}(\tau)\,\Delta\mathbf{p}.
\end{aligned}
$$

(Implemented in `generateTaskTrajectory.m`.)

## Task-Space Impedance Control
Let the measured EE position and linear velocity be \(\mathbf{x}\in\mathbb{R}^3\) and \(\mathbf{v}\in\mathbb{R}^3\). Define errors

$$
\mathbf{e} = \mathbf{x}_d - \mathbf{x}, \qquad \mathbf{e}_v = \dot{\mathbf{x}}_d - \mathbf{v}.
$$

With diagonal gains \(\mathbf{K}=\mathrm{diag}(K_x,K_y,K_z)\), \(\mathbf{D}=\mathrm{diag}(D_x,D_y,D_z)\), and virtual mass \(\mathbf{M}=\mathrm{diag}(M_x,M_y,M_z)\), the raw task-space force is

$$
\mathbf{F}_{\text{raw}} = \mathbf{K}\,\mathbf{e} + \mathbf{D}\,\mathbf{e}_v + \mathbf{M}\,\ddot{\mathbf{x}}_d.
$$

(Implemented in `taskImpedanceControl.m`.)

## Force Limiting in Target Bounding Box
Let the target be \(\mathbf{x}_T\) and the axis-aligned half-widths be \(\mathbf{b} = [b_x, b_y, b_z]^\top\). The controller checks if the current EE position is inside the box:

$$
\text{inBox} \iff |x_i - x_{T,i}| \le b_i \quad \forall i \in \{x,y,z\}.
$$

If inside, the applied force is capped by a maximum norm \(F_{\max}\):

$$
\mathbf{F} = \begin{cases}
\mathbf{F}_{\text{raw}}, & \|\mathbf{F}_{\text{raw}}\| \le F_{\max} \\
\dfrac{F_{\max}}{\|\mathbf{F}_{\text{raw}}\|}\,\mathbf{F}_{\text{raw}}, & \text{otherwise}
\end{cases}
\quad \text{if inBox, else } \mathbf{F}=\mathbf{F}_{\text{raw}}.
$$

This implements a simple saturation of the task-space force vector near the target.

## Torque Mapping and Gravity Compensation
Let \(\mathbf{J}_v\in\mathbb{R}^{3\times n}\) be the linear-velocity part of the geometric Jacobian (rows 4–6 of the 6×n Jacobian). The commanded joint torques are

$$
\boldsymbol{\tau} = \mathbf{J}_v^\top\,\mathbf{F} + \mathbf{G}(\mathbf{q}),
$$

where \(\mathbf{G}(\mathbf{q})\) are the gravity torques (gravity compensation).

## Plant Dynamics and Integration
The robot dynamics are

$$
\mathbf{M}(\mathbf{q})\,\ddot{\mathbf{q}} + \mathbf{C}(\mathbf{q},\dot{\mathbf{q}}) + \mathbf{G}(\mathbf{q}) = \boldsymbol{\tau}.
$$

Forward dynamics used by the plant:

$$
\ddot{\mathbf{q}} = \mathbf{M}^{-1}(\mathbf{q})\,\big(\boldsymbol{\tau} - \mathbf{C}(\mathbf{q},\dot{\mathbf{q}}) - \mathbf{G}(\mathbf{q})\big).
$$

State integration (simple explicit Euler in the demo):

$$
\begin{aligned}
\dot{\mathbf{x}}_{\text{state}} &= \begin{bmatrix} \dot{\mathbf{q}} \\ \ddot{\mathbf{q}} \end{bmatrix},\\
\mathbf{x}_{\text{state}}(t+\Delta t) &= \mathbf{x}_{\text{state}}(t) + \dot{\mathbf{x}}_{\text{state}}\,\Delta t.
\end{aligned}
$$

(Implemented in `simpleUR5Plant.m`.)

## Key Parameters (set in `run.m`)
- `target`: Desired EE position `[x y z]` (m) in the base frame.
- `params.K`, `params.D`, `params.M`: Cartesian impedance gains and virtual mass (diagonal).
- `params.bbox`: Half-widths of the target bounding box (m).
- `params.Fmax`: Maximum task-space force norm (N) inside the box.
- `dt`, `Tend`: Simulation step and duration.

## Outputs and Plots
- Task-space position tracking: actual vs. desired for x, y, z.
- Force magnitude: raw vs. applied, with \(F_{\max}\) reference line.
- Animation: UR5 motion with target marker and bounding-box wireframe.

## Assumptions and Notes
- Control is position-only in task space (orientation is not controlled); only linear Jacobian rows are used.
- Near singular configurations, mapping \(\mathbf{J}_v^\top\,\mathbf{F}\) may produce large torques; choose targets and gains accordingly.
- Force limiting is a norm cap (isotropic) applied only inside the specified bounding box.
- Euler integration is used for simplicity; more accurate integrators can be substituted if needed.
