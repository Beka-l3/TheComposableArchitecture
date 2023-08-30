//
//  ContentView.swift
//  TheComposableArchitecture
//
//  Created by Bekzhan Talgat on 29.08.2023.
//

import SwiftUI
import ComposableArchitecture

fileprivate let wolframAlphaApiKey = "QVXP3R-9VX4K8AGPQ"

struct WolframAlphaResult: Decodable {
    let queryResult: QueryResult
    
    struct QueryResult: Decodable {
        let pods: [Pod]
        
        struct Pod: Decodable {
            let primary: Bool?
            let subPods: [SubPod]
            
            struct SubPod: Decodable {
                let plainText: String
            }
        }
    }
}

private func wolframAplha(query: String, callBack: @escaping (WolframAlphaResult?) -> Void) {
    var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
    components.queryItems = [
        URLQueryItem(name: "input", value: query),
        URLQueryItem(name: "format", value: "plaintext"),
        URLQueryItem(name: "output", value: "JSON"),
        URLQueryItem(name: "appid", value: wolframAlphaApiKey),
    ]
    
    URLSession.shared.dataTask(with: components.url(relativeTo: nil)!) { data, response, error in
        callBack( data.flatMap { try? JSONDecoder().decode(WolframAlphaResult.self, from: $0) } )
    }
    .resume()
}

private func nthPrime(n: Int, callback: @escaping (Int?) -> Void) {
    wolframAplha(query: "prime \(n)") { result in
        callback( result.flatMap { $0.queryResult.pods.first {$0.primary == .some(true)}?.subPods.first?.plainText }.flatMap(Int.init) )
    }
}


class AppState: ObservableObject {
    @Published var count: Int = .zero
    @Published var favoritePrimes: [Prime] = []
    
    struct Prime {
        let id: UUID = .init()
        let prime: Int
    }
}

struct ContentView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(state: appState)) {
                    Text("Counter demo")
                }
                
                NavigationLink(destination: FavoritePrimesView(state: appState)) {
                    Text("Favorite primes")
                }
            }
            .navigationTitle("State Management")
        }
    }
}

struct CounterView: View {
    @ObservedObject var state: AppState
    @State var isPresentationShown: Bool = false
    
    @State var nthPrime: Int = -1
    @State var isNthPrimePresented: Bool = false
    @State var fetching: Bool = false
    
    var ending: String {
        get {
            if state.count % 10 == 1 && state.count != 11 {
                return "st"
            } else if state.count % 10 == 2 && state.count != 12 {
                return "nd"
            } else if state.count % 10 == 3 && state.count != 13 {
                return "rd"
            } else {
                return "th"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 24) {
                Button("-") {
                    if state.count > 0 {
                        state.count -= 1
                    }
                }
                .disabled(state.count == .zero)
                
                Text("\(state.count)")
                
                Button("+") {
                    if state.count < 100 {
                        state.count += 1
                    }
                }
            }
            
            Button("Is this prime number?") {
                isPresentationShown = true
            }
            
            Button("What is the \(state.count)\(ending) prime number") {
                fetching = true
                TheComposableArchitecture.nthPrime(n: state.count) { n in
                    nthPrime = n ?? -1
                    isNthPrimePresented = true
                }
            }
            .disabled(fetching)
        }
        .font(.title)
        .navigationTitle("Counter Demo")
        .sheet(isPresented: $isPresentationShown) {
            isPresentationShown = false
        } content: {
            IsPrimeView(state: state)
        }
        .alert("Nth prime", isPresented: $isNthPrimePresented, presenting: nthPrime) { n in
            Text("\(self.state.count)th prime number is \(n)")
                .onDisappear {
                    self.fetching = false
                }
        }

    }
}

private func isPrime(_ num: Int) -> Bool {
    if num <= 1 {return false}
    if num <= 3 {return true}
    
    for i in 2...Int(sqrtf(Float(num))) {
        if num % i == 0 {return false}
    }
    
    return true
}

struct IsPrimeView: View {
    @ObservedObject var state: AppState
    var isInFavorites: Bool {
        get { state.favoritePrimes.contains { $0.prime == state.count } }
    }
    
    var body: some View {
        if isPrime(state.count) {
            VStack(spacing: 24) {
                Text("Yes, \(state.count) is prime 🎉")
                
                Button(isInFavorites ? "Remove from favorites" : "Add to favorites") {
                    if isInFavorites {
                        state.favoritePrimes.removeAll { $0.prime == self.state.count }
                    } else {
                        state.favoritePrimes.append( .init(prime: state.count) )
                    }
                }
            }
            .font(.title2)
        } else {
            Text("Nope, \(state.count) is not prime")
                .font(.title2)
        }
    }
    
}

struct FavoritePrimesView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        List {
            ForEach(state.favoritePrimes, id: \.id) { prime in
                Text("\(prime.prime)")
            }
            .onDelete { indexSet in
                for index in indexSet {
                    self.state.favoritePrimes.remove(at: index)
                }
            }
        }
        .navigationTitle("Favorite primes")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(appState: .init())
    }
}
