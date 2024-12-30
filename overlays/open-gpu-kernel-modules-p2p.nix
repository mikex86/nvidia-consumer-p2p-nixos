self: super: {
  open-gpu-kernel-modules-p2p = super.linuxPackages_6_6.stdenv.mkDerivation {
    pname   = "open-gpu-kernel-modules-p2p";
    version = "1.0";
    
    src = super.fetchFromGitHub {
      owner = "tinygrad";
      repo  = "open-gpu-kernel-modules";
      rev   = "9e39420bc4cb50cd7f8033ac6dd5c5583fd07567";
      sha256 = "18g1d36j7d8jyfh6cbpvl4psm9j467shpsmn5b7m6gwiycnqrhxw";
    };
    
    buildInputs = [
      super.gcc
      super.gnumake
      super.nettools
      super.linuxPackages_6_6.kernel.dev
    ];
    
    patchPhase = ''
    # 1) Replace "$(KERNEL_UNAME)" with "6.6.67"
    substituteInPlace kernel-open/Makefile \
    --replace "\$(KERNEL_UNAME)" "6.6.67"

    # 2) Replace "/lib/modules" with the kernel store path
    substituteInPlace kernel-open/Makefile \
    --replace "/lib/modules" "${super.linuxPackages_6_6.kernel.dev}/lib/modules"
    '';

    buildPhase = ''
      make modules -j$(nproc)
    '';

    installPhase = ''
      make modules_install INSTALL_MOD_PATH=$out -j$(nproc)
    '';

    meta = with super.lib; {
      description = "Custom NVIDIA kernel module with P2P support";
      license     = licenses.unfree;
      maintainers = [ "Michael Keiblinger" ];
      platforms   = platforms.linux;
    };
  };
}
