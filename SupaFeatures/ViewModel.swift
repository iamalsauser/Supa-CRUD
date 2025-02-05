import Foundation
import Supabase

enum Table {
    static let features = "Features"
}

enum AuthAction: String, CaseIterable {
    case signUp = "Sign Up"
    case signIn = "Sign In"
}

@MainActor
final class ViewModel: ObservableObject {
    
    @Published var isAuthenticated = false
    @Published var authAction: AuthAction = .signUp
    
    @Published var features = [Feature]()
    
    @Published var showingAuthView = false
    @Published var email = ""
    @Published var password = ""
    
    let supabase = SupabaseClient(supabaseURL: Secrets.projectURL, supabaseKey: Secrets.apiKey)
    
    // MARK: - Database
    
    func createFeatureRequest(text: String) async throws {
        let user = try await supabase.auth.session.user
        
        let feature = Feature(createdAt: Date(), text: text, isComplete: false, userID: user.id)
        
        try await supabase.database
            .from(Table.features)
            .insert(values: feature)
            .execute()
        
        // Fetch features again after adding a new one
        try await fetchFeatureRequests()
    }
    
    func fetchFeatureRequests() async throws {
        let user = try await supabase.auth.session.user
        
        let features: [Feature] = try await supabase.database
            .from(Table.features)
            .select()
            .eq(column: "user_id", value: user.id) // Filter by the authenticated user's ID
            .order(column: "created_at", ascending: false)
            .execute()
            .value
        
        DispatchQueue.main.async {
            self.features = features
        }
    }
    
    func update(_ feature: Feature, with text: String) async {
        guard let id = feature.id else {
            print("Cannot update feature \(feature.id)")
            return
        }
        var toUpdate = feature
        toUpdate.text = text
        
        do {
            try await supabase.database
                .from(Table.features)
                .update(values: toUpdate)
                .eq(column: "id", value: id)
                .execute()
            
            // Fetch features again after updating
            try await fetchFeatureRequests()
        } catch {
            print("Error: \(error)")
        }
    }
    
    func deleteFeature(at id: Int) async throws {
        try await supabase.database
            .from(Table.features)
            .delete()
            .eq(column: "id", value: id)
            .execute()
        
        // Fetch features again after deleting
        try await fetchFeatureRequests()
    }
    
    // MARK: - Authentication
    
    func signUp() async throws {
        let response = try await supabase.auth.signUp(email: email, password: password)
        
        // Fetch features after signing up
        try await fetchFeatureRequests()
    }
    
    func signIn() async throws {
        let session = try await supabase.auth.signIn(email: email, password: password)
        
        // Fetch features after signing in
        try await fetchFeatureRequests()
    }
    
    func isUserAuthenticated() async {
        do {
            _ = try await supabase.auth.session.user
            isAuthenticated = true
            
            // Fetch features if the user is authenticated
            try await fetchFeatureRequests()
        } catch {
            isAuthenticated = false
        }
    }
    
    func signOut() async throws {
        try await supabase.auth.signOut()
        isAuthenticated = false
        features = [] // Clear the features when signing out
    }
    
    func authorize() async throws {
        switch authAction {
        case .signUp:
            try await signUp()
        case .signIn:
            try await signIn()
        }
    }
}
