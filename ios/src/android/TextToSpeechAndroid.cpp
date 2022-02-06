#include <android/asset_manager.h>
#include <android/asset_manager_jni.h>
#include <android/log.h>
#include <iostream>
#include <iterator>
#include <vector>
#include "VoxCommon.h"
#include "TTSBackend.h"
#include "mmap/mmap_stream.hpp"
#include "mmap/mmap_stream_android.hpp"
#include "TextToSpeech.hpp"
#include <iostream>
#include <jni.h>

using namespace std;

TTSBackend *backend;
istream *melgen;
istream *vocoder;
extern "C"
{

  JNIEXPORT jint JNICALL Java_com_avinium_tflite_1tts_TfliteTtsPlugin_initialize(JNIEnv *env, jobject obj, jobject assetManager, jstring jmelgenFile, jstring jvocoderFile)
  {

    const char *melgenFilename_c = env->GetStringUTFChars(jmelgenFile, 0);
    
    const char *vocoderFilename_c = env->GetStringUTFChars(jvocoderFile, 0);

    AAssetManager *mgr = AAssetManager_fromJava(env, assetManager);

    if(!mgr) {
      __android_log_print(ANDROID_LOG_VERBOSE, "flutter_tflite_tts_plugin", "Error retrieving asset manager");
      return -1;
    }

    mmap_stream* melgen_s = map_file(melgenFilename_c, mgr);
    if (!melgen_s)
    {
      return -1;
    }
    melgen = new istream(melgen_s);

    mmap_stream* vocoder_s = map_file(vocoderFilename_c, mgr);
    if (!vocoder_s)
    {
      return -1;
    }
    vocoder = new istream(vocoder_s);

   
    initialize(melgen, vocoder, melgen_s->size(), vocoder_s->size());

    env->ReleaseStringUTFChars(jmelgenFile, melgenFilename_c);
    env->ReleaseStringUTFChars(jvocoderFile, vocoderFilename_c);
    return 0;
  }

  JNIEXPORT jint JNICALL Java_com_avinium_tflite_1tts_TfliteTtsPlugin_synthesize(JNIEnv *env, jobject obj, jintArray jtokenIds, jstring joutfile)
  {
    const char *outfile_c = env->GetStringUTFChars(joutfile, 0);
    jint numTokens = env->GetArrayLength(jtokenIds);
    __android_log_print(ANDROID_LOG_VERBOSE, "flutter_tflite_tts_plugin", "Num tokens %d", numTokens);
    int tokenIds[numTokens];
    jint *body = env->GetIntArrayElements(jtokenIds, 0);
    for (int i = 0; i < numTokens; i++) {
      tokenIds[i] = body[i];
      __android_log_print(ANDROID_LOG_VERBOSE, "flutter_tflite_tts_plugin", "Got token id %d", tokenIds[i]);
    }

    int retCode = synthesize(numTokens, tokenIds, outfile_c);
    env->ReleaseIntArrayElements(jtokenIds, body, 0);

    return retCode;
  }
}
