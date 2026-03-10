import 'dart:ffi';
import 'package:ffi/ffi.dart';

final DynamicLibrary _vconfLib = DynamicLibrary.open('libvconf.so.0');

class Vconf {
  // int vconf_set_int(const char* in_key, const int intval)
  static final int Function(Pointer<Utf8> in_key, int intval) _vconfSetInt = _vconfLib
      .lookupFunction<Int32 Function(Pointer<Utf8>, Int32), int Function(Pointer<Utf8>, int)>('vconf_set_int');

  // int vconf_get_int(const char *in_key, int *intval)
  static final int Function(Pointer<Utf8> in_key, Pointer<Int32> intval) _vconfGetInt = _vconfLib
      .lookupFunction<Int32 Function(Pointer<Utf8>, Pointer<Int32>), int Function(Pointer<Utf8>, Pointer<Int32>)>('vconf_get_int');

  // int vconf_set_bool(const char* in_key, const int boolval)
  static final int Function(Pointer<Utf8> in_key, int boolval) _vconfSetBool = _vconfLib
      .lookupFunction<Int32 Function(Pointer<Utf8>, Int32), int Function(Pointer<Utf8>, int)>('vconf_set_bool');

  // int vconf_get_bool(const char *in_key, int *boolval)
  static final int Function(Pointer<Utf8> in_key, Pointer<Int32> boolval) _vconfGetBool = _vconfLib
      .lookupFunction<Int32 Function(Pointer<Utf8>, Pointer<Int32>), int Function(Pointer<Utf8>, Pointer<Int32>)>('vconf_get_bool');

  // int vconf_set_dbl(const char* in_key, const double dblval)
  static final int Function(Pointer<Utf8> in_key, double dblval) _vconfSetDbl = _vconfLib
      .lookupFunction<Int32 Function(Pointer<Utf8>, Double), int Function(Pointer<Utf8>, double)>('vconf_set_dbl');

  // int vconf_get_dbl(const char *in_key, double *dblval)
  static final int Function(Pointer<Utf8> in_key, Pointer<Double> dblval) _vconfGetDbl = _vconfLib
      .lookupFunction<Int32 Function(Pointer<Utf8>, Pointer<Double>), int Function(Pointer<Utf8>, Pointer<Double>)>('vconf_get_dbl');

  // int vconf_set_str(const char* in_key, const char* strval)
  static final int Function(Pointer<Utf8> in_key, Pointer<Utf8> strval) _vconfSetStr = _vconfLib
      .lookupFunction<Int32 Function(Pointer<Utf8>, Pointer<Utf8>), int Function(Pointer<Utf8>, Pointer<Utf8>)>('vconf_set_str');

  // char *vconf_get_str(const char *in_key)
  static final Pointer<Utf8> Function(Pointer<Utf8> in_key) _vconfGetStr = _vconfLib
      .lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>), Pointer<Utf8> Function(Pointer<Utf8>)>('vconf_get_str');

  static bool setBool(String key, bool value) {
    final keyPtr = key.toNativeUtf8();
    final result = _vconfSetBool(keyPtr, value ? 1 : 0);
    calloc.free(keyPtr);
    return result == 0;
  }

  static bool setInt(String key, int value) {
    final keyPtr = key.toNativeUtf8();
    final result = _vconfSetInt(keyPtr, value);
    calloc.free(keyPtr);
    return result == 0;
  }

  static bool setDouble(String key, double value) {
    final keyPtr = key.toNativeUtf8();
    final result = _vconfSetDbl(keyPtr, value);
    calloc.free(keyPtr);
    return result == 0;
  }

  static bool setString(String key, String value) {
    final keyPtr = key.toNativeUtf8();
    final valuePtr = value.toNativeUtf8();
    final result = _vconfSetStr(keyPtr, valuePtr);
    calloc.free(keyPtr);
    calloc.free(valuePtr);
    return result == 0;
  }

  static bool? getBool(String key) {
    final keyPtr = key.toNativeUtf8();
    final valuePtr = calloc<Int32>();
    final result = _vconfGetBool(keyPtr, valuePtr);
    final value = valuePtr.value;
    calloc.free(keyPtr);
    calloc.free(valuePtr);
    if (result != 0) return null;
    return value == 1;
  }

  static int? getInt(String key) {
    final keyPtr = key.toNativeUtf8();
    final valuePtr = calloc<Int32>();
    final result = _vconfGetInt(keyPtr, valuePtr);
    final value = valuePtr.value;
    calloc.free(keyPtr);
    calloc.free(valuePtr);
    if (result != 0) return null;
    return value;
  }

  static double? getDouble(String key) {
    final keyPtr = key.toNativeUtf8();
    final valuePtr = calloc<Double>();
    final result = _vconfGetDbl(keyPtr, valuePtr);
    final value = valuePtr.value;
    calloc.free(keyPtr);
    calloc.free(valuePtr);
    if (result != 0) return null;
    return value;
  }

  static String? getString(String key) {
    final keyPtr = key.toNativeUtf8();
    final resultPtr = _vconfGetStr(keyPtr);
    calloc.free(keyPtr);
    if (resultPtr == nullptr) return null;
    final result = resultPtr.toDartString();
    return result;
  }
}
