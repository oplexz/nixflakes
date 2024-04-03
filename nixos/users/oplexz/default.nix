{pkgs, ...}: {
  users.users.oplexz = {
    description = "Daniil Isakov";
    shell = pkgs.bash;
    isNormalUser = true;
    initialHashedPassword = "$y$j9T$xM5Xhp5QPVfZedqYXl8Oi1$6KsTEMtN77jhB4F/.RIoYCNfiC0/WBs5RJ4K9jW5bK.";
    extraGroups = ["wheel" "input" "networkmanager" "audio"];
  };
}
