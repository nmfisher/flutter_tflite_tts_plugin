#include "TfliteBase.h"

TfliteBase::TfliteBase(const char *modelFilename)
{
    interpreterBuild(modelFilename);
}

TfliteBase::TfliteBase(const char *buffer, size_t bufferSize)
{
    model = tflite::FlatBufferModel::BuildFromBuffer(buffer, bufferSize);
    TFLITE_MINIMAL_CHECK(model != nullptr);
    __android_log_print(ANDROID_LOG_VERBOSE, "asrbridge", "not nullptr", bufferSize);

    tflite::InterpreterBuilder builder(*model, resolver);
    builder(&interpreter);
    TFLITE_MINIMAL_CHECK(interpreter != nullptr);
}

TfliteBase::~TfliteBase()
{
    ;
}

void TfliteBase::interpreterBuild(const char *modelFilename)
{
    model = tflite::FlatBufferModel::BuildFromFile(modelFilename);

    TFLITE_MINIMAL_CHECK(model != nullptr);

    tflite::InterpreterBuilder builder(*model, resolver);

    builder(&interpreter);

    TFLITE_MINIMAL_CHECK(interpreter != nullptr);
}
