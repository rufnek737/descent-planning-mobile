#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Registers the Swift NativeOcrPlugin with Capacitor under the JS-side name
// "NativeOcr" — matches the Android @CapacitorPlugin(name = "NativeOcr") so
// JS code (Capacitor.Plugins.NativeOcr.recognize) works identically on both.
CAP_PLUGIN(NativeOcrPlugin, "NativeOcr",
    CAP_PLUGIN_METHOD(recognize, CAPPluginReturnPromise);
)
