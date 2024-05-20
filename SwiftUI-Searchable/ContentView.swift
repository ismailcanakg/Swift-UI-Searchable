//
//  ContentView.swift
//  SwiftUI-Searchable
//
//  Created by İsmail Can Akgün on 15.05.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var followers: [Follower] = [] // MARK: - State Properties
    
    @State private var searchTerm = "" // MARK: - Search State
    
    var filteredFollowers: [Follower] { // MARK: - Filtered Followers
        guard !searchTerm.isEmpty else { return followers }
        return followers.filter { $0.login.localizedCaseInsensitiveContains(searchTerm) }
    }
    
    var body: some View {
        NavigationStack { // MARK: - Navigation Stack
            List(filteredFollowers, id: \.id) { follower in
                HStack(spacing: 20) {
                    if let url = URL(string: follower.avatarUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                        } placeholder: {
                            Circle()
                                .foregroundColor(.secondary)
                                .frame(width: 44, height: 44)
                        }
                        .frame(width: 44, height: 44)
                    } else {
                        Circle()
                            .foregroundColor(.secondary)
                            .frame(width: 44, height: 44)
                    }

                    Text(follower.login)
                        .font(.title3)
                        .fontWeight(.medium)
                }
            }
            .navigationTitle("Followers") // MARK: - Navigation Title
            
            .task { followers = await getFollowers() } // MARK: - Fetch Followers
            
            // .searchable: Bu, takipçileri aramak için bir arama çubuğu ekler. Kullanıcı arama terimini girerken, searchTerm değişkeni güncellenir ve takipçileri filtrelemek için kullanılır.
            .searchable(text: $searchTerm, prompt: "Search Followers") // MARK: - Searchable
        }
    }
    
    func getFollowers() async -> [Follower] { // MARK: - Network Request
        let url = URL(string:"https://api.github.com/users/ismailcanakg/followers")!
        let (data, _) = try! await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try! decoder.decode([Follower].self, from: data)
    }
}

#Preview {
ContentView()
}

struct Follower: Codable {
    let login: String
    var avatarUrl: String
    let id: Int
}

