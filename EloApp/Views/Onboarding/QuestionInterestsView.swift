import SwiftUI

struct QuestionInterestsView: View {
    @ObservedObject var vm: OnboardingViewModel
    @State private var showMoreInterests = false

    let initialInterests = [
        ("Pop Culture", "🎉"), ("Cooking", "🍳"), ("Food", "🍔"),
        ("Travel", "✈️"), ("Shopping", "🛍️"), ("Sports", "⚽"),
        ("Movies", "🎬"), ("Music", "🎵"), ("Technology", "💻")
    ]

    let allInterests = [
        ("Business", "💼"), ("Health", "🏥"), ("Fitness", "🏋️"),
        ("Fashion", "👗"), ("Art", "🎨"), ("Books", "📚"),
        ("Gaming", "🎮"), ("Nature", "🌿"), ("Photography", "📸"),
        ("Science", "🔬"), ("History", "🏛️")
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 30) {
                Spacer().frame(height: 60)

                Text("Please select your interests")
                    .font(.system(size: 36, weight: .regular, design: .serif))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)

                Text("You can choose up to 4")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 16
                ) {
                    ForEach(initialInterests, id: \.0) { interest, emoji in
                        InterestButton(
                            title: interest,
                            emoji: emoji,
                            isSelected: vm.selectedInterests.contains(interest),
                            canSelectMore: vm.selectedInterests.count < 4
                        ) {
                            toggleInterest(interest)
                        }
                    }
                }
                .padding(.horizontal)

                Button("More interests") {
                    showMoreInterests = true
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.eloTeal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.eloTeal.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.eloTeal.opacity(0.2), lineWidth: 1)
                )
                .cornerRadius(16)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.horizontal)

            Button { vm.previousPage() } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .clipShape(Circle())
            }
            .padding(.top, 50)
            .padding(.leading, 12)
        }
        .sheet(isPresented: $showMoreInterests) {
            NavigationView {
                List(allInterests, id: \.0) { interest, emoji in
                    Button {
                        toggleInterest(interest)
                    } label: {
                        HStack {
                            Text(emoji).font(.system(size: 30))
                            Text(interest).font(.title2)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            if vm.selectedInterests.contains(interest) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.eloTeal)
                                    .font(.title3.bold())
                            }
                        }
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                    }
                    .disabled(vm.selectedInterests.count >= 4 && !vm.selectedInterests.contains(interest))
                }
                .navigationTitle("More Interests")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { showMoreInterests = false }
                            .font(.headline)
                            .foregroundColor(.eloTeal)
                    }
                }
            }
        }
    }

    private func toggleInterest(_ interest: String) {
        if vm.selectedInterests.contains(interest) {
            vm.selectedInterests.remove(interest)
        } else if vm.selectedInterests.count < 4 {
            vm.selectedInterests.insert(interest)
        }
    }
}

struct InterestButton: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let canSelectMore: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(emoji).font(.system(size: 48))
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.eloTeal : Color.eloTeal.opacity(0.07))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.eloTeal : Color.eloTeal.opacity(0.15),
                        lineWidth: 1
                    )
            )
        }
        .disabled(!isSelected && !canSelectMore)
    }
}
