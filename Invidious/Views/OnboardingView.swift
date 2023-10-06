import InvidiousKit
import Observation
import SwiftUI

@Observable
final class OnboardingViewModel {
    var instance = ""
    var isInvalid = true
    var loading = false
    @ObservationIgnored
    private var task: Task<Void, Never>? = nil

    func validate() {
        guard let url = URL(string: instance) else {
            isInvalid = true
            loading = false
            return
        }
        task?.cancel()
        task = Task {
            await MainActor.run {
                loading = true
            }
            let response = await APIClient.isValidInstance(url: url)
            if response {
                TubeApp.client.setApiUrl(url: url)
            }
            await MainActor.run {
                isInvalid = !response
                loading = false
            }
        }
    }
}

struct AppIconView: View {
    #if canImport(UIKit)
        func iconImage() -> Image? {
            guard
                let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
                let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
                let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
                let iconName = iconFiles.last,
                let image = UIImage(named: iconName)
            else { return nil }
            return Image(uiImage: image)
        }
    #else
        func iconImage() -> Image? {
            guard let image = Bundle.main.image(forResource: "AppIcon") else { return nil }
            return Image(nsImage: image)
        }
    #endif

    var body: some View {
        if let image = iconImage() {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

struct OnboardingView: View {
    @Bindable var model = OnboardingViewModel()
    @Binding var hasValidInstance: Bool?
    @Environment(Settings.self) var settings

    var body: some View {
        ScrollView {
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    AppIconView()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    Text("Welcome to Tube").font(.title).fontWeight(.bold).padding(.bottom, 4.0)
                    Text("Tube uses [Invidious](https://invidious.io) to access YouTube. Enter an Invidious instance URL to start watching.").multilineTextAlignment(.center).foregroundStyle(.secondary).font(.subheadline)
                }.frame(maxWidth: 600.0)
                Spacer()
            }.padding(.vertical, 64)
        }.safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading) {
                HStack {
                    if model.isInvalid {
                        Label("Instance is invalid", systemImage: "xmark")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    } else {
                        Label("Instance is valid", systemImage: "checkmark")
                            .font(.callout)
                            .foregroundStyle(.green)
                    }
                    Spacer()
                    ProgressView().opacity(model.loading ? 1 : 0)
                }.opacity(model.instance.isEmpty ? 0 : 1)
                TextField("Invidious Instance", text: $model.instance)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.URL)
                    .autocorrectionDisabled()
                #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                #endif
                Button {
                    settings.invidiousInstance = model.instance
                    hasValidInstance = !model.isInvalid
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.vertical, 6.0)
                }.disabled(model.isInvalid)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle)
                    .fontWeight(.medium)
            }.frame(maxWidth: 600.0).background(.windowBackground)
        }
        .padding()
        .onChange(of: model.instance, model.validate)
    }
}

#Preview {
    OnboardingView(hasValidInstance: .constant(nil))
}
