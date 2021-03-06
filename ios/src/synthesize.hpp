#pragma once
#include <iostream>
#include <iterator>
#include <vector>
#include "VoxCommon.h"
#include "TTSFrontend.h"
#include "TTSBackend.h"

using namespace std;

int initialize(istream* const melgen, istream* const  vocoder, streamsize melgen_size, streamsize vocoder_size);

int synthesize(int numPhoneIds, int* phoneIds, const char* outfile);
