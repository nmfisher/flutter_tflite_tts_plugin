#ifndef TTSBACKEND_H
#define TTSBACKEND_H
#include <iostream>
#include <vector>
#include "MelGenerateTF.h"
#include "VocoderTF.h"

using namespace std;

class TTSBackend
{
public:
    TTSBackend(istream *const melgen_s, istream *const vocoder_s, streamsize melgen_size, streamsize vocoder_size)
    {
        std::vector<char> melgen_b(melgen_size);

        if (!melgen_s->read(melgen_b.data(), melgen_size))
            return;
        std::vector<char> vocoder_b(vocoder_size);
        if (!vocoder_s->read(vocoder_b.data(), vocoder_size))
            return;
        melgen = new MelGenerateTF(melgen_b.data(), melgen_size);
        vocoder = new VocoderTF(vocoder_b.data(), vocoder_size);
    };

    void inference(std::vector<int32_t> phonesIds);

    MelGenData getMel() const { return _mel; }
    std::vector<float> getAudio() const { return _audio; }

private:
    MelGenerateTF *melgen;
    VocoderTF *vocoder;

    MelGenData _mel;
    std::vector<float> _audio;
};

#endif // TTSBACKEND_H
