# NOTE: this is rakshava's version of libtorrent, used mainly by rtorrent
# This is NOT libtorrent-rasterbar, used by Deluge, qbitttorent, and others
{ stdenv, fetchFromGitHub, fetchpatch, pkgconfig
, libtool, autoconf, automake, cppunit
, openssl, libsigcxx, zlib }:

stdenv.mkDerivation rec {
  name = "libtorrent-${version}";
  version = "0.13.7";

  src = fetchFromGitHub {
    owner = "rakshasa";
    repo = "libtorrent";
    rev = "v${version}";
    sha256 = "027qanwcisxhx0bq8dn8cpg8563q0k2pm8ls278f04n7jqvvwkp0";
  };

  patches = [
    (fetchpatch {
      name = "openssl_1_1.patch";
      url = https://github.com/rakshasa/libtorrent/commit/7b29b6bd2547e72e22b9b7981df27092842d2a10.patch;
      sha256 = "0nrh2f9bvi1p0gnsck2gzkgd5dd91yk26gcrhrj2f7wh1d4m0pdd";
    })
  ];

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libtool autoconf automake cppunit openssl libsigcxx zlib ];

  preConfigure = "./autogen.sh";

  meta = with stdenv.lib; {
    inherit (src.meta) homepage;
    description = "A BitTorrent library written in C++ for *nix, with focus on high performance and good code";

    platforms = platforms.unix;
    maintainers = with maintainers; [ ebzzry codyopel ];
  };
}
