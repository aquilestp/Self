import Foundation
import Supabase

@MainActor
let supabase = SupabaseClient(
    supabaseURL: URL(string: Config.EXPO_PUBLIC_SUPABASE_URL.isEmpty ? "https://placeholder.supabase.co" : Config.EXPO_PUBLIC_SUPABASE_URL)!,
    supabaseKey: Config.EXPO_PUBLIC_SUPABASE_ANON_KEY.isEmpty ? "placeholder" : Config.EXPO_PUBLIC_SUPABASE_ANON_KEY
)
