
#include <iostream>
#include <iterator>
#include <vector>
#include "TfliteBase.h"

#include "VoxCommon.h"
#include "TTSBackend.h"

using namespace std;

static TTSBackend *backend;

int initialize(istream* const melgen, istream* const  vocoder, streamsize melgen_length, streamsize vocoder_length) {
    if(backend) {
        delete backend;
    }
    std::cout << "Creating TTS backend." << std::endl;
    backend = new TTSBackend(melgen, vocoder,melgen_length, vocoder_length);
    if(!backend)
        return -1;
    return 0;
}

int synthesize(int numPhoneIds, int* phoneIds, const char* outfile) {

    vector<int32_t> phonesIds = vector<int32_t>(phoneIds, phoneIds + numPhoneIds);

    backend->inference(phonesIds);
    MelGenData mel = backend->getMel();
    std::vector<float> audio = backend->getAudio();

    VoxUtil::ExportWAV(outfile, audio, 24000);
    std::cout << "Wavfile: " << outfile << " created." << std::endl;

    return 0;
}

