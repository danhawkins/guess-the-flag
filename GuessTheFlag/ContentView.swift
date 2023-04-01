//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Danny Hawkins on 24/09/2022.
//

import SwiftUI
import AVFoundation

struct Country {
  var name: String
  var code: String
}

struct TitleModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.largeTitle.weight(.bold))
  }
}

extension View {
  func titleText() -> some View {
    modifier(TitleModifier())
  }
}

struct FlagImage: View {
  var country: Country

  var body: some View {
    Image(country.code.lowercased())
      .resizable()
      .aspectRatio(contentMode: .fit)
      .shadow(radius: 6)
      .cornerRadius(3)
      .frame(width: 280, height: 120)
      
  }
}

struct ContentView: View {
  @State var countries: [Country] = []
  @State var correctAnswer = -1

  @State private var score = 0
  @State private var scoreTitle = ""
  @State private var showImages = false
  @State private var showingAlert = false
  
  let player = try! AVAudioPlayer(data: NSDataAsset(name: "success")!.data)
  let generator = UINotificationFeedbackGenerator()

  var body: some View {
    ZStack {
      RadialGradient(stops: [
        .init(color: Color(red: 0.46, green: 0.1, blue: 0.1), location: 0.2),
        .init(color: Color(red: 0.4, green: 0.2, blue: 0.2), location: 0.4),
      ], center: .top, startRadius: 200, endRadius: 900)
      if correctAnswer >= 0 {
        VStack {
          Text("Guess the Flag").titleText()
            .foregroundColor(.white)
            .padding(.bottom)
          Text("Score: \(score)")
            .foregroundColor(.white)
            .font(.title.bold())
          Text(scoreTitle)
            .foregroundColor(.white)
            .font(.title.bold())
          VStack(spacing: 25) {
            VStack {
              Text("Tap the flag of")
                .foregroundColor(.white)
                .font(.subheadline.weight(.heavy))
              
              Text(countries[correctAnswer].name)
                .foregroundColor(.white)
                .font(.largeTitle.weight(.semibold))
                .animation(.none)
            }
            VStack(spacing: 25){
              ForEach(0 ..< 3) { number in
                if countries.count > number + 1 {
                  Button {
                    flagTapped(number)
                  } label: {
                    FlagImage(country: countries[number])
                     .transition(.slide)
                  }
                }
              }
            }
            .offset(y: showImages ? 0 : 800)
          }
          Spacer()
        }.padding()
      } else {
        VStack {
          Text("Loading")
        }
      }
    }
    .onAppear(perform: load)
  }

  func flagTapped(_ number: Int) {
    generator.prepare()

    if number == correctAnswer {
      player.play()
      scoreTitle = "Correct"
      generator.notificationOccurred(.success)
      score += 1
    } else {
      generator.notificationOccurred(.error)
      scoreTitle = "Wrong"
    }
    countries.remove(at: number)

    askQuestion()
  }

  func askQuestion() {
    showImages = false

    withAnimation(.linear(duration: 0.2)){
      countries.shuffle()
      correctAnswer = Int.random(in: 0 ... 2)
      showImages = true
    }
  }

  func load() {
    guard let url = Bundle.main.url(forResource: "countries", withExtension: "csv") else { return }
    guard let contents = try? String(contentsOf: url) else { return }
    for row in contents.components(separatedBy: .newlines) {
      let data = row.components(separatedBy: ",")
      if data.count == 2 {
        countries.append(Country(name: data[1], code: data[0]))
      }
    }
    askQuestion()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
