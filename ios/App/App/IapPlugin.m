#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Registers the Swift IapPlugin with Capacitor under the JS-side name "Iap".
CAP_PLUGIN(IapPlugin, "Iap",
    CAP_PLUGIN_METHOD(purchase, CAPPluginReturnPromise);
)
