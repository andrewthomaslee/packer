{
  inputs,
  self,
}: final: prev: {
  # --- Git --- #
  git = prev.git.override {
    perlSupport = false;
    pythonSupport = false;
    withManual = false;
  };
  # --- k3s --- #
  k3s = inputs.nixpkgs.legacyPackages.${final.stdenv.hostPlatform.system}.k3s_1_34;
}
