import SwiftUI

struct DailyWordView: View {

    @State private var word = "Hello"
    @State private var translation = "Hola"

    var body: some View {
        VStack(spacing: 20) {
            Text(word)
                .font(.largeTitle)
                .bold()

            Text(translation)
                .font(.title2)
                .foregroundColor(.secondary)

            Button("Next Word") {
                word = ["Hello", "Bye", "Thanks"].randomElement()!
                translation = ["Hola", "Adiós", "Gracias"].randomElement()!
            }
        }
        .padding()
        .navigationTitle("Daily Word")
    }
}

#Preview {
    DailyWordView()
}
