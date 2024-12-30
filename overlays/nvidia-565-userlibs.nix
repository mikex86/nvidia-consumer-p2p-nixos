self: super: {
  linuxPackages_6_6 = super.linuxPackages_6_6.extend (final: prev: {
    nvidia_x11 = prev.nvidia_x11.overrideAttrs (old: rec {
      driverVersion = "565.57.01";
      version = "${driverVersion}-${prev.kernel.version}";
       
      src = super.fetchurl {
        url    = "https://us.download.nvidia.com/XFree86/Linux-x86_64/565.57.01/NVIDIA-Linux-x86_64-565.57.01.run";
        sha256 = "6eebe94e585e385e8804f5a74152df414887bf819cc21bd95b72acd0fb182c7a";
      };

      enableKernelModule = false;

      installPhase = ''
        # Run the original installPhase (if it exists)
        ${old.installPhase or ""}

        echo "Copying GSP firmware into $firmware/lib/firmware/nvidia/${driverVersion} ..."
        mkdir -p $firmware/lib/firmware/nvidia/${driverVersion}
        cp -v firmware/gsp_ga10x.bin \
               firmware/gsp_tu10x.bin \
               $firmware/lib/firmware/nvidia/${driverVersion}/
        
        echo "Copying nvidia-565 32-bit libs to $lib32/lib ..."
        mkdir -p $lib32/lib
        cp -vr 32/* $lib32/lib/
        
        echo "Copying nvidia-565 libs to $out/lib ... "
        mkdir -p $out/lib
        cp -vr *.so* $out/lib/
        
        echo "Copying nvidia-565 binaries to $bin/bin ..."
        mkdir -p $bin/bin
        cp -v nvidia-smi $bin/bin
        cp -v nvidia-settings $bin/bin
        cp -v nvidia-debugdump $bin/bin
  
        echo "Creating symlinks for libraries ..."
        for lib in $out/lib/lib*.so.*; do
          base=$(basename $lib)
          # Extract the library name without the version suffix
          libname=$(echo $base | sed -E 's/\.so\..*$//')
          # Get the major version number
          major=$(echo $base | sed -E 's/.*\.so\.([0-9]+).*/\1/')
          # Create symlinks
          ln -sf $base $out/lib/$libname.so.$major
          ln -sf $base $out/lib/$libname.so.1
          ln -sf $libname.so.$major $out/lib/$libname.so
        done
        
        echo ">>> Patching nvidia-565 binaries with patchelf ..."
        for binary in $bin/bin/*; do
          # Check if the file is an executable ELF binary
          if [[ -x "$binary" && -f "$binary" ]]; then
            patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
                     --set-rpath $out/lib \
                     "$binary" || echo "Failed to patch $binary"
          fi
        done
      '';
      
    });
  });
}

