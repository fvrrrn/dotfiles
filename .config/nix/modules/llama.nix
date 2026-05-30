{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (llama-cpp.override {cudaSupport = true;})
    llama-swap
  ];
}
