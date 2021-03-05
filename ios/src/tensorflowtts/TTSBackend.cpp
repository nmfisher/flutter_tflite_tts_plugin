#include "TTSBackend.h"

void TTSBackend::inference(std::vector<int32_t> phonesIds)
{
    _mel = melgen->infer(phonesIds);
    _audio = vocoder->infer(_mel);
}