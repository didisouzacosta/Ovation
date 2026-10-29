import Foundation

/// One presentation of the sheet, with the configuration frozen when it appeared.
struct OvationPresentation: Identifiable, Sendable {
    let id = UUID()
    let configuration: OvationConfiguration
}
