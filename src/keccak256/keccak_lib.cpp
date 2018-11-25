// //////////////////////////////////////////////////////////
// digest.cpp
// Copyright (c) 2014,2015 Stephan Brumme. All rights reserved.
// see http://create.stephan-brumme.com/disclaimer.html
//

// g++ -O3 digest.cpp crc32.cpp md5.cpp sha1.cpp sha256.cpp keccak.cpp sha3.cpp -o digest


#include "keccak.h"
#include <cstring>

extern "C" __declspec(dllexport) int __cdecl keccak256(unsigned char *output, unsigned char *input, int length)
{
  Keccak digestKeccak(Keccak::Keccak256);
  digestKeccak.add(input, length);
  unsigned char *hash = digestKeccak.getHash();
  memcpy(output, hash, 32);
  delete [] hash;
  return 0;
}
