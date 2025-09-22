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
    ++ (with inputs.nix-matlab.packages.${pkgs.system}; [
      matlab
      matlab-mlint
      matlab-mex
    ]);
  # Build docker image
  scripts.build-matlab.exec = ''
    podman build \
      --build-arg ADDITIONAL_PRODUCTS="Simulink" \
      -t matlab_with_simulink:R2024b \
      https://github.com/mathworks-ref-arch/matlab-dockerfile.git#alternates/building-on-matlab-docker-image
  '';
  # Run docker
  scripts.run-matlab.exec = ''
    podman run --rm -it \
      -p 8888:8888 \
      --shm-size=512M \
      -v $PWD:/workspace \
      -w /workspace \
      matlab_with_simulink:R2024b \
      -browser
  ''; # docker run -it --rm -p 8888:8888 --shm-size=512M mathworks/matlab:r2025b -browser

  enterShell = ''
    ${inputs.nix-matlab.shellHooksCommon}
  '';
}
