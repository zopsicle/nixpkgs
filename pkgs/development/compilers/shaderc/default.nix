{ lib, stdenv, fetchFromGitHub, cmake, python3, autoSignDarwinBinariesHook, cctools }:
# Like many google projects, shaderc doesn't gracefully support separately compiled dependencies, so we can't easily use
# the versions of glslang and spirv-tools used by vulkan-loader. Exact revisions are taken from
# https://github.com/google/shaderc/blob/known-good/known_good.json

# Future work: extract and fetch all revisions automatically based on a revision of shaderc's known-good branch.
let
  glslang = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "glslang";
    rev = "89db4e1caa273a057ea46deba709c6e50001b314";
    sha256 = "sha256-Vjyb0PNnUHjqniPUdsTl5Ut2If7j0bZaxJVl+5S9ZTY=";
  };
  spirv-tools = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Tools";
    rev = "eb0a36633d2acf4de82588504f951ad0f2cecacb";
    sha256 = "sha256-sqjQoz9v9alSPc0ujEcWZxDAWh2S6oAPP1+JZmNCpA0=";
  };
  spirv-headers = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Headers";
    rev = "85a1ed200d50660786c1a88d9166e871123cce39";
    sha256 = "sha256-lUWgZYGPu+IaLUrbtyC7R0o3Hq/q7C7BE8r7DAsiC30=";
  };
in
stdenv.mkDerivation rec {
  pname = "shaderc";
  version = "2022.3";

  outputs = [ "out" "lib" "bin" "dev" "static" ];

  src = fetchFromGitHub {
    owner = "google";
    repo = "shaderc";
    rev = "v${version}";
    sha256 = "sha256-DS3Y5oH4SU8dr2L29/0p5fi82f5i+4ILAxLXb0x0q2k=";
  };

  patchPhase = ''
    cp -r --no-preserve=mode ${glslang} third_party/glslang
    cp -r --no-preserve=mode ${spirv-tools} third_party/spirv-tools
    ln -s ${spirv-headers} third_party/spirv-tools/external/spirv-headers
  '';

  nativeBuildInputs = [ cmake python3 ]
    ++ lib.optionals stdenv.isDarwin [ cctools ]
    ++ lib.optionals (stdenv.isDarwin && stdenv.isAarch64) [ autoSignDarwinBinariesHook ];

  postInstall = ''
    moveToOutput "lib/*.a" $static
  '';

  cmakeFlags = [ "-DSHADERC_SKIP_TESTS=ON" ];

  # Fix the paths in .pc, even though it's unclear if all these .pc are really useful.
  postFixup = ''
    substituteInPlace "$dev"/lib/pkgconfig/*.pc \
      --replace '=''${prefix}//' '=/' \
      --replace "$dev/$dev/" "$dev/"
  '';

  meta = with lib; {
    inherit (src.meta) homepage;
    description = "A collection of tools, libraries and tests for shader compilation";
    platforms = platforms.all;
    license = [ licenses.asl20 ];
  };
}
