// SupabaseConfig.swift
// Replace the placeholder values with your Supabase project's URL and anon key.

import Foundation

enum SupabaseConfig {
    static let url: URL = {
        guard let urlString = SecretsLoader.shared.value(for: "SUPABASE_URL"),
              let url = URL(string: urlString) else {
            fatalError("Missing or invalid SUPABASE_URL in Secrets.plist")
        }
        return url
    }()

    static let anonKey: String = {
        guard let key = SecretsLoader.shared.value(for: "SUPABASE_ANON_KEY"), !key.isEmpty else {
            fatalError("Missing SUPABASE_ANON_KEY in Secrets.plist")
        }
        return key
    }()
}

private final class SecretsLoader {
    static let shared = SecretsLoader()
    private var secrets: [String: Any] = [:]

    private init() {
        loadSecrets()
    }

    private func loadSecrets() {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
              let dict = plist as? [String: Any] else {
            assertionFailure("Could not load Secrets.plist from bundle")
            return
        }
        secrets = dict
    }

    func value(for key: String) -> String? {
        secrets[key] as? String
    }
}
