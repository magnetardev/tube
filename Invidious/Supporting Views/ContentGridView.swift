import SwiftUI

struct ContentGridView<Content>: View where Content: View {
    @ViewBuilder
    var content: () -> Content

    var body: some View {
        LazyVGrid(columns: [.init(.adaptive(minimum: 200.0, maximum: 500.0))], alignment: .leading, spacing: 16.0) {
            self.content()
        }
    }
}
