{ mkDerivation, base, bytestring, directory, filepath, lib, microlens-platform
, optparse-applicative, raw-strings-qq, terminal-progress-bar, text
, typed-process }:
mkDerivation {
  pname = "marketing";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base
    bytestring
    directory
    filepath
    microlens-platform
    optparse-applicative
    raw-strings-qq
    terminal-progress-bar
    typed-process
  ];
  executableHaskellDepends =
    [ base bytestring directory terminal-progress-bar text ];
  license = "unknown";
  mainProgram = "imgocr";
}
