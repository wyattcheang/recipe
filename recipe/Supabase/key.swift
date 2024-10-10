//
//  Auth.swift
//  recipe
//
//  Created by Wyatt Cheang on 10/10/2024.
//

import Foundation
import Supabase

let supabase = SupabaseClient(
  supabaseURL: URL(string: "https://gchndufcgwahjnfzrssd.supabase.co")!,
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdjaG5kdWZjZ3dhaGpuZnpyc3NkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjg0OTM2NDEsImV4cCI6MjA0NDA2OTY0MX0.eHl7luD_h2Ga_cN5mDVzMzDtFg9YA_Ovbg-33DZHUAU"
)
