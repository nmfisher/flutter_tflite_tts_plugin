#pragma once
#include <iostream>
#include <iterator>
#include <vector>
#include "VoxCommon.h"
#include "TTSFrontend.h"
#include "TTSBackend.h"

using namespace std;

TTSBackend *ttsbackend;
int initialize(istream* const melgen, istream* const  vocoder, streamsize melgen_length, streamsize vocoder_length) {
    std::cout << "Creating TTS backend." << std::endl;
    ttsbackend = new TTSBackend(melgen, vocoder,melgen_length, vocoder_length);
    if(!ttsbackend)
        return -1;
    return 0;
}

int synthesize(int numPhoneIds, int* phoneIds, const char* outfile) {

    vector<int32_t> phonesIds = vector<int32_t>(phoneIds, phoneIds + numPhoneIds);

    ttsbackend->inference(phonesIds);
    MelGenData mel = ttsbackend->getMel();
    std::vector<float> audio = ttsbackend->getAudio();

    std::cout << "********* AUDIO LEN **********" << std::endl;
    std::cout << audio.size() << std::endl;

    VoxUtil::ExportWAV(outfile, audio, 24000);
    std::cout << "Wavfile: " << outfile << " created." << std::endl;

    return 0;
}
