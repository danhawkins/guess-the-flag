//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Danny Hawkins on 24/09/2022.
//

import SwiftUI

struct Country {
  var name: String
  var code: String
}

struct TitleModifier : ViewModifier {
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
      .aspectRatio( contentMode: .fit)
      .shadow(radius: 4)
      .frame(width: 400, height: 150)
      .clipShape(RoundedRectangle(cornerRadius: 5))
  }
}

struct ContentView: View {
  @State var countries: [Country] = []
  @State var correctAnswer = -1
  
  @State private var showingScore = false
  @State private var scoreTitle = ""
  
  @State private var showingAlert = false
  
  var body: some View {
    ZStack {
      RadialGradient(stops: [
        .init(color: Color(red: 0.76, green: 0.1, blue: 0.1), location: 0.2),
        .init(color: Color(red: 0.2, green: 0.2, blue: 0.2), location: 0.2),
      ], center: .top, startRadius: 200, endRadius: 400)
      .ignoresSafeArea()
      if correctAnswer > 0 {
        VStack{
          Text("Guess the Flag").titleText()
            .foregroundColor(.white)
            .padding(.bottom)
          Text("Score: ???")
            .foregroundColor(.white)
            .font(.title.bold())
          Spacer()
          VStack(spacing: 15) {
            VStack {
              Text("Tap the flag of").foregroundColor(.secondary).font(.subheadline.weight(.heavy))
              Text(countries[correctAnswer].name).foregroundColor(.white).font(.largeTitle.weight(.semibold))
            }
            ForEach(0 ..< 3) { number in
              Button {
                flagTapped(number)
              } label: {
                FlagImage(country: countries[number])

              }
            }
          }
          Spacer()
        }.padding()
      } else {
        VStack{
          Text("Loading")
        }
      }
      
    }
    .onAppear(perform: load)
    .alert(scoreTitle, isPresented: $showingScore) {
      Button("Continue", action: askQuestion)
    } message: {
      Text("Your score is ???")
    }
  }
  
  func flagTapped(_ number: Int) {
    if number == correctAnswer {
      scoreTitle = "Correct"
    } else {
      scoreTitle = "Wrong"
    }

    showingScore = true
  }
  
  func askQuestion() {
    countries.shuffle()
    correctAnswer = Int.random(in: 0...3)
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
    correctAnswer = Int.random(in: 0...3)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
