{ pkgs, inputs, ... }:
{
  packages =
    with pkgs;
    [
      nss
      openssl
      dbus
      pam
    ]
    # This unfortunatly does not work because the matlab license server keeps failing
    ++ (with inputs.nix-matlab.packages.${pkgs.system}; [
      matlab
      matlab-mlint
      matlab-mex
    ]);
  # Build docker image: https://github.com/mathworks-ref-arch/matlab-dockerfile/tree/main/alternates/building-on-matlab-docker-image
  scripts.build-matlab.exec = ''
    git clone https://github.com/mathworks-ref-arch/matlab-dockerfile.git
    podman build \
      --build-arg ADDITIONAL_PRODUCTS="Simulink Control_System_Toolbox ROS_Toolbox Robotics_System_Toolbox Robotics_System_Toolbox_Support_Package_for_Universal_Robots_UR_Series_Manipulators " \
      -t matlab:R2025b \
      matlab-dockerfile/alternates/building-on-matlab-docker-image
  '';
  # Run docker
  scripts.run-matlab.exec = ''
    podman run --rm -it \
        -p 8888:8888 \
        --shm-size=512M \
        --userns=keep-id \
        --group-add sudo \
        --security-opt label=disable \
        -u "$(id -u)":"$(id -g)" \
        -v "$PWD:/workspace:rw" \
        -w /workspace \
        matlab:R2025b \
        -browser
  ''; # docker run -it --rm -p 8888:8888 --shm-size=512M mathworks/matlab:r2025b -browser

  enterShell = ''
    ${inputs.nix-matlab.shellHooksCommon}
  '';
}
