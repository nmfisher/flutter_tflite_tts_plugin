package com.avinium.tflite_tts

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

import android.content.res.AssetManager
import android.content.Context;

/** IncredibleTtsPlugin */
class TfliteTtsPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context


  companion object {
    init {
      System.loadLibrary("tts");
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.avinium.tflite_tts")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

    if (call.method == "initialize") {
      var am = context.getAssets();                
      var melgenAssetPath = call.argument<String>("melgenAssetPath")!!;        // assets/fastspeech2_quan.tflite"
      var vocoderAssetPath = call.argument<String>("vocoderAssetPath")!!;       // assets/mb_melgan.tflite
      
      var retCode = initialize(am, "flutter_assets/" + melgenAssetPath, "flutter_assets/" + vocoderAssetPath);
      result.success(retCode);
    } else if(call.method == "synthesize") {
      var symbolIds = call.argument<List<Int>>("symbolIds")!!;
      var retCode = synthesize(symbolIds.toIntArray(), call.argument<String>("outfile")!!);
      result.success(retCode);
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
  
  external fun initialize(mgr: AssetManager, melgenAssetPath: String, vocoderAssetPath: String) : Int;
  external fun synthesize(tokenIds: IntArray, outfile:String) : Int;
}
