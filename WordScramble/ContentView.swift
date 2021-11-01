//
//  ContentView.swift
//  WordScramble
//
//  Created by Elliott Harris on 4/7/21.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                
                List(usedWords, id: \.self){
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                
                Text("Score: \(score)")
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(leading: Button("New Game", action: startGame))
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            showError(title: "Not Original", message: "Cannot reuse words")
            return
        }
        
        guard isPossible(word: answer) else {
            showError(title: "Not Possible", message: "Word cannot be created within main word")
            return
        }
        
        guard isReal(word: answer) else {
            showError(title: "Not Real", message: "No made up words allowed")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
        score += answer.count
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords = []
                score = 0
                return
            }
        }
        fatalError("Could not load start.txt")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word) || word == rootWord
    }
    
    func isPossible(word: String) -> Bool {
        var temp = rootWord.lowercased()
        
        for letter in word {
            if let pos = temp.firstIndex(of: letter) {
                temp.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        if word.count < 3 {
            return false
        }
        return misspelledRange.location == NSNotFound
    }
    
    func showError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
