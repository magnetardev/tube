import SwiftUI

extension View {
    func modify<T: View>(@ViewBuilder _ modifier: (Self) -> T) -> some View {
        return modifier(self)
    }

    func asyncTaskOverlay(error: Error?, isLoading: Bool) -> some View {
        return self.overlay(alignment: .center) {
            AsyncOverlayView(error: error, isLoading: isLoading)
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}
