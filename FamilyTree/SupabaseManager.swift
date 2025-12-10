// SupabaseManager.swift
// Singleton manager for Supabase client. Uses conditional compilation so the project
// continues to build even if the Supabase Swift package hasn't been added yet.

import Foundation

#if canImport(Supabase)
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.anonKey
        )
    }
}

#else

// Supabase package is not available. Provide a lightweight stub so the app compiles
// until you add the real 'Supabase' Swift package via Xcode > Add Packages...

public struct SupabaseClient {
    public init(supabaseURL: URL, supabaseKey: String) {}

    public func from(_ table: String) -> SupabaseTableQuery {
        SupabaseTableQuery(table: table)
    }
}

public struct SupabaseTableQuery {
    let table: String

    public func insert<T: Encodable>(values: T) -> SupabaseInsertQuery {
        SupabaseInsertQuery()
    }
}

public struct SupabaseInsertQuery {
    public func execute() async throws {}
}

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        // Uses the stub client. Replace by adding the Supabase Swift package.
        client = SupabaseClient(supabaseURL: SupabaseConfig.url, supabaseKey: SupabaseConfig.anonKey)
    }
}

#endif
