import Foundation
import Capacitor

/// Custom bridge view controller that explicitly registers app-local plugins.
///
/// Capacitor 6 with SPM auto-discovers plugins that ship as separate npm/SPM
/// packages, but plugins compiled directly into the main app target are NOT
/// discovered automatically. They must be registered via `capacitorDidLoad`.
class CustomBridgeViewController: CAPBridgeViewController {
    override func capacitorDidLoad() {
        bridge?.registerPluginInstance(NativeOcrPlugin())
        bridge?.registerPluginInstance(IapPlugin())
    }
}
