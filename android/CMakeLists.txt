cmake_minimum_required(VERSION 3.4.1)  # for example

include_directories(../ios/src)
include_directories(../ios/src/tensorflowtts)
include_directories(../ios/include)
link_directories(src/main/jniLibs/${ANDROID_ABI})

string(REPLACE "build\\flutter_tflite_tts_plugin" "build\\flutter_mmap_stream" FLUTTER_MMAP_BUILD_DIR ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
link_directories(${FLUTTER_MMAP_BUILD_DIR})

add_library( libmmap_stream_android SHARED IMPORTED )

add_library( 
            tts
            SHARED
            ../ios/src/synthesize.cpp
            ../ios/src/synthesize_android.cpp
            ../ios/src/tensorflowtts/MelGenerateTF.cpp
            ../ios/src/tensorflowtts/TfliteBase.cpp
            ../ios/src/tensorflowtts/TTSBackend.cpp
            ../ios/src/tensorflowtts/TTSFrontend.cpp
            ../ios/src/tensorflowtts/VocoderTF.cpp
            ../ios/src/tensorflowtts/VoxCommon.cpp
        )


target_link_libraries(tts -landroid -llog -ltensorflowlite -lmmap_stream_android)
