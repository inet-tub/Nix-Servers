self: super: {
  urbackup-client = with super; super.urbackup-client.overrideAttrs (oldAttrs: {
    configureFlags = oldAttrs.configureFlags ++ [
      "--with-crypto-prefix=${cryptopp.dev}"
      "--localstatedir=/data/UrBackup"
    ];

    nativeBuildInputs = [
      autoreconfHook
      pkg-config
    ];

    buildInputs = oldAttrs.buildInputs ++ [
      wxGTK32
      curl
      cryptopp
    ];

    patches = [ ./urbackup-fix.patch ];
    enableParallelBuilding = true;
  });
}