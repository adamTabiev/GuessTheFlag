//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Адам Табиев on 14.09.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "UK", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    
    @State private var showingScore = false
    @State private var scoreTitle = ""
    
    @State private var score = 0
    
    @State private var numberOfGames = 0
    @State private var showingEndOfGame = false
    
    // Добавлены переменные состояния для анимации
    @State private var animationAmount = 0.0
    @State private var selectedFlag: Int? = nil
    
    var body: some View {
        ZStack {
            RadialGradient(
                stops: [
                    .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                    .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3)
                ],
                center: .top,
                startRadius: 200,
                endRadius: 700
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Угадай флаг")
                    .titleStyle()
                
                VStack(spacing: 15) {
                    VStack {
                        Text("Нажмите на флаг страны")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    ForEach(0..<3) { number in
                        Button {
                            flagTapped(number)
                        } label: {
                            FlagImage(imageName: countries[number])
                        }
                        // Вращение выбранного флага
                        .rotation3DEffect(
                            .degrees(number == selectedFlag ? animationAmount : 0),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        // Снижение непрозрачности невыбранных флагов
                        .opacity(selectedFlag == nil || number == selectedFlag ? 1.0 : 0.25)
                        // Анимация изменений
                        .animation(.easeInOut(duration: 1), value: animationAmount)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer()
                Spacer()
                
                Text("Счет: \(score)")
                    .foregroundStyle(.white)
                    .font(.title.bold())
                
                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Продолжить", action: askQuestion)
        } message: {
            Text("Ваш счет: \(score)")
        }
        .alert("Поздравляем!", isPresented: $showingEndOfGame) {
            Button("Начать заново", action: restartGame)
        } message: {
            Text("Ваш итоговый счет: \(score)")
        }
    }
    
    func flagTapped(_ number: Int) {
        selectedFlag = number
        
        if number == correctAnswer {
            scoreTitle = "Правильно"
            score += 1
        } else {
            scoreTitle = "Неверно! Это флаг \(countries[number])"
            if score > 0 {
                score -= 1
            }
        }
        
        withAnimation(.easeInOut(duration: 1)) {
            animationAmount += 360
        }
        
        numberOfGames += 1
        
        // Задержка перед показом алерта, чтобы дать время на завершение анимации
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if numberOfGames == 8 {
                showingEndOfGame = true
            } else {
                showingScore = true
            }
        }
    }

    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        selectedFlag = nil
        animationAmount = 0.0
    }
    
    func restartGame() {
        score = 0
        numberOfGames = 0
        selectedFlag = nil
        animationAmount = 0.0
        askQuestion()
    }
}

struct FlagImage: View {
    var imageName: String

    var body: some View {
        Image(imageName)
            .renderingMode(.original)
            .clipShape(Capsule())
            .shadow(radius: 5)
    }
}

#Preview {
    ContentView()
}

struct Title: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle.bold())
            .foregroundStyle(.white)
    }
}

extension View {
    func titleStyle() -> some View {
        modifier(Title())
    }
}


