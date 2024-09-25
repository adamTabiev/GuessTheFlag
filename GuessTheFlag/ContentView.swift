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
    
    @State private var showingScore = false // Показывать ли алерт с результатом ответа
    @State private var scoreTitle = "" // Заголовок алерта с результатом
    
    // Переменная для хранения текущего счета игрока
    @State private var score = 0
    
    // Переменные для отслеживания количества игр и окончания игры
    @State private var numberOfGames = 0 // Счетчик сыгранных игр
    @State private var showingEndOfGame = false // Показывать ли алерт с окончанием игры
    
    // Переменные состояния для анимации
    @State private var animationAmount = 0.0 // Угол вращения флага
    @State private var selectedFlag: Int? = nil // Индекс выбранного флага
    
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
                            FlagImage(imageName: countries[number]) // Кастомное представление флага
                        }
                        // Анимация вращения выбранного флага
                        .rotation3DEffect(
                            .degrees(number == selectedFlag ? animationAmount : 0), // Вращаем только выбранный флаг
                            axis: (x: 0, y: 1, z: 0) // Вращение по оси Y
                        )
                        // Изменение прозрачности невыбранных флагов
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
    
    // Функция, вызываемая при нажатии на флаг
    func flagTapped(_ number: Int) {
        selectedFlag = number // Сохраняем индекс выбранного флага
        
        if number == correctAnswer {
            scoreTitle = "Правильно"
            score += 1
        } else {
            scoreTitle = "Неверно! Это флаг \(countries[number])"
            if score > 0 {
                score -= 1
            }
        }
        
        // Запускаем анимацию вращения
        withAnimation(.easeInOut(duration: 1)) {
            animationAmount += 360 // Увеличиваем угол вращения на 360 градусов
        }
        
        numberOfGames += 1 // Увеличиваем счетчик игр
        
        // Задерживаем показ алерта на 1 секунду для завершения анимации
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if numberOfGames == 8 {
                showingEndOfGame = true // Показываем алерт с окончанием игры
            } else {
                showingScore = true // Показываем алерт с результатом ответа
            }
        }
    }
    
    // Функция для перехода к следующему вопросу
    func askQuestion() {
        countries.shuffle() // Перемешиваем массив стран
        correctAnswer = Int.random(in: 0...2) // Выбираем новый правильный ответ
        selectedFlag = nil // Сбрасываем выбранный флаг
        animationAmount = 0.0 // Сбрасываем угол вращения
    }
    
    // Функция для перезапуска игры
    func restartGame() {
        score = 0 // Сбрасываем счет
        numberOfGames = 0 // Сбрасываем счетчик игр
        selectedFlag = nil // Сбрасываем выбранный флаг
        animationAmount = 0.0 // Сбрасываем угол вращения
        askQuestion() // Начинаем новую игру
    }
}

// Кастомное представление для отображения флага
struct FlagImage: View {
    var imageName: String // Название изображения флага
    
    var body: some View {
        Image(imageName) // Загружаем изображение
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



