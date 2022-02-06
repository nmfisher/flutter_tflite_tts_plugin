cmake_minimum_required(VERSION 3.4.1)  # for example

string(REPLACE "build\\flutter_tflite_tts_plugin" "build\\flutter_mmap_stream" FLUTTER_MMAP_BUILD_DIR ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
string(REPLACE "build\\flutter_tflite_tts_plugin" "build\\flutter_tflite" FLUTTER_TFLITE_BUILD_DIR ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
string(REPLACE "cmake" "library_jni" FLUTTER_TFLITE_JNI_DIR ${FLUTTER_TFLITE_BUILD_DIR})
string(REPLACE "obj" "jni" FLUTTER_TFLITE_JNI_DIR ${FLUTTER_TFLITE_JNI_DIR})

get_cmake_property(_variableNames VARIABLES)
list (SORT _variableNames)
foreach (_variableName ${_variableNames})
    message(STATUS "${_variableName}=${${_variableName}}")
endforeach()

include_directories(../ios/src)
include_directories(../ios/src/tensorflowtts)
include_directories(../ios/src/include)

link_directories(src/main/jniLibs/${ANDROID_ABI})

link_directories(${FLUTTER_MMAP_BUILD_DIR})
link_directories(${FLUTTER_TFLITE_JNI_DIR})

add_library( libmmap_stream_android SHARED IMPORTED )
add_library( libtflite SHARED IMPORTED )
add_library( libtensorflowlite SHARED IMPORTED )

add_library( 
            tflite_tts
            SHARED
            ../ios/src/TextToSpeech.cpp
            ../ios/src/android/TextToSpeechAndroid.cpp
            ../ios/src/tensorflowtts/MelGenerateTF.cpp
            ../ios/src/tensorflowtts/TTSBackend.cpp
            ../ios/src/tensorflowtts/VocoderTF.cpp
            ../ios/src/tensorflowtts/VoxCommon.cpp
        )


target_link_libraries(tflite_tts -landroid -llog -ltflite -ltensorflowlite -lmmap_stream_android  )
