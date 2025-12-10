import Foundation
import Combine

// MARK: - Data Source Manager

@MainActor
final class DataSourceManager: ObservableObject {
    static let shared = DataSourceManager()
    
    @Published var isUsingMockData = false {
        didSet {
            UserDefaults.standard.set(isUsingMockData, forKey: "isUsingMockData")
            NotificationCenter.default.post(name: .dataSourceChanged, object: nil)
        }
    }
    
    private init() {
        self.isUsingMockData = UserDefaults.standard.bool(forKey: "isUsingMockData")
    }
    
    func getCurrentRepository() -> FamilyRepositoryProtocol {
        if isUsingMockData {
            return MockFamilyRepository()
        } else {
            return SupabaseFamilyRepository()
        }
    }
    
    func getCurrentUseCase() -> FamilyWizardUseCaseProtocol {
        return FamilyWizardUseCase(repository: getCurrentRepository())
    }
}

// MARK: - Notification

extension Notification.Name {
    static let dataSourceChanged = Notification.Name("dataSourceChanged")
}
