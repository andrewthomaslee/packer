{
  self,
  inputs,
  customLib,
}: {
  meta = {
    name = "packer";
    description = "NixOS Packer Images";
    domain = "pkr.ccc";
  };

  # --- Clan Services --- #
  instances = {
    # --- Root Users --- #
    users.roles.default = {
      tags = ["nixos"];
      settings = {
        user = "root";
        share = true;
        prompt = false;
      };
    };
  };
}
