// //////////////////////////////////////////////////////////
// digest.cpp
// Copyright (c) 2014,2015 Stephan Brumme. All rights reserved.
// see http://create.stephan-brumme.com/disclaimer.html
//

// g++ -O3 digest.cpp crc32.cpp md5.cpp sha1.cpp sha256.cpp keccak.cpp sha3.cpp -o digest


#include "keccak.h"


#include <stdio.h>

int __cdecl keccak256(unsigned char *output, unsigned char *input, int length)
{
  Keccak digestKeccak(Keccak::Keccak256);
  digestKeccak.add(input, length);
  unsigned char *hash = digestKeccak.getHash();
  memcpy(output, hash, 32);
  return 0;
}


int main(int argc, char** argv)
{
  char* buffer = (char *)"hello";
  unsigned char* out = new unsigned char[32];
  keccak256(out, (unsigned char*)buffer, 5);
  for(int j = 0; j < 32; j++)
    printf("%X ", out[j]);
  return 0;
}
