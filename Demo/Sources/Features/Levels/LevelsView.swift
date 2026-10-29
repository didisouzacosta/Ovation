// README:view:begin

import os
import Ovation
import SwiftUI

struct LevelsView: View {

    // MARK: - Private Properties

    private static let logger = Logger(subsystem: "com.example.levels", category: "Review")

    @State private var wonLevels = 0

    // MARK: - Body

    var body: some View {
        List {
            Section {
                LabeledContent("Levels won", value: wonLevels, format: .number)

                Button("Win a level", action: winLevel)
            } footer: {
                Text("The review sheet can appear from the third win, once per session.")
            }
        }
        .ovationReview(.levels, trigger: wonLevels) { event in
            Self.logger.info("Review prompt: \(String(describing: event))")
        }
    }

    // MARK: - Private Methods

    private func winLevel() {
        wonLevels += 1
    }
}

// README:view:end

#Preview("Levels") {
    LevelsView()
}
