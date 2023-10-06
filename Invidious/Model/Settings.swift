import Foundation
import Observation

private enum SettingsKey: String {
    case invidiousInstance
}

@Observable
final class Settings {
    var invidiousInstance: String? = UserDefaults.standard.string(forKey: SettingsKey.invidiousInstance.rawValue) {
        didSet {
            UserDefaults.standard.setValue(invidiousInstance, forKey: SettingsKey.invidiousInstance.rawValue)
        }
    }
    
    func reset() {
        UserDefaults.standard.removeObject(forKey: SettingsKey.invidiousInstance.rawValue)
    }
}
