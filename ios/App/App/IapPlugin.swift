import Foundation
import Capacitor
import StoreKit

/// StoreKit 2 in-app purchase plugin for the developer-support ("coffee")
/// section. Two consumable products:
///   com.rufnek.descentplanning.coffee      — 커피 한 잔 (₩1,500)
///   com.rufnek.descentplanning.coffeecake  — 커피+케익 (₩4,500)
///
/// These product IDs must exist in App Store Connect (Consumable type,
/// Cleared for Sale) before purchases will resolve — StoreKit returns an
/// empty product list otherwise. The JS side then shows an availability error;
/// iOS must never route the user to an external payment method.
@objc(IapPlugin)
public class IapPlugin: CAPPlugin {
    static let productIds = [
        "com.rufnek.descentplanning.coffee",
        "com.rufnek.descentplanning.coffeecake"
    ]

    private var updatesTask: Task<Void, Never>?

    public override func load() {
        // Listen for transactions that complete outside an explicit purchase()
        // call (e.g. Ask to Buy approval arriving later, or a restored
        // transaction), so those still get finished instead of staying pending.
        updatesTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                await self?.finish(result: result)
            }
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    @objc func purchase(_ call: CAPPluginCall) {
        guard let productId = call.getString("productId"), !productId.isEmpty else {
            call.reject("Missing productId")
            return
        }
        Task {
            do {
                let products = try await Product.products(for: [productId])
                guard let product = products.first else {
                    call.reject("Product not found in App Store Connect: \(productId)")
                    return
                }
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    await finish(result: verification)
                    switch verification {
                    case .verified:
                        call.resolve(["status": "success"])
                    case .unverified:
                        call.resolve(["status": "unverified"])
                    }
                case .userCancelled:
                    call.resolve(["status": "cancelled"])
                case .pending:
                    // Ask to Buy / parental approval — completes later via Transaction.updates.
                    call.resolve(["status": "pending"])
                @unknown default:
                    call.resolve(["status": "unknown"])
                }
            } catch {
                call.reject("Purchase failed: \(error.localizedDescription)")
            }
        }
    }

    private func finish(result: VerificationResult<Transaction>) async {
        if case .verified(let transaction) = result {
            await transaction.finish()
        }
    }
}
