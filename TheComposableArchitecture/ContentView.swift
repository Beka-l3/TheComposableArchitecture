//
//  ContentView.swift
//  TheComposableArchitecture
//
//  Created by Bekzhan Talgat on 29.08.2023.
//

import SwiftUI
import ComposableArchitecture

class AppState: ObservableObject {
    @Published var count: Int = .zero
    @Published var favoritePrimes: [Int] = []
}

struct ContentView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(state: appState)) {
                    Text("Counter demo")
                }
                
                NavigationLink(destination: Color(.green)) {
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
                
            }
        }
        .font(.title)
        .navigationTitle("Counter Demo")
        .sheet(isPresented: $isPresentationShown) {
            isPresentationShown = false
        } content: {
            IsPrimeView(state: state)
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
        get { state.favoritePrimes.contains([state.count]) }
    }
    
    var body: some View {
        if isPrime(state.count) {
            VStack(spacing: 24) {
                Text("Yes, \(state.count) is prime 🎉")
                
                Button(isInFavorites ? "Remove from favorites" : "Add to favorites") {
                    if isInFavorites {
                        state.favoritePrimes.removeAll { $0 == self.state.count }
                    } else {
                        state.favoritePrimes.append(state.count)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(appState: .init())
    }
}
