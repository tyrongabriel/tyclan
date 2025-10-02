{ lib, ... }:
{
  clan.core.networking.zerotier.settings = {
    # 👇 1. ADD THE IP ASSIGNMENT POOL
    ipAssignmentPools = [
      {
        ipRangeStart = "10.147.17.1";
        ipRangeEnd = "10.147.17.254";
      }
    ];

    routes = [
      # Optional: Add a route for the local subnet so nodes know how to reach each other.
      # The 'via' is typically null for the network's primary subnet.
      {
        target = "10.147.17.0/24";
        via = null;
      }
    ];
    # 👇 2. ENABLE MANAGED IP ASSIGNMENT
    v4AssignMode = lib.mkForce {
      zt = true; # <--- CHANGE THIS TO TRUE
    };

    # ... (v6AssignMode and other settings remain the same)
  };
}
