import SwiftUI
import FirebaseFirestore
import FirebaseAuth

enum UrgeStep {
    case home, observe, accept, gratitude, reframe, redirect, success
}

struct ContentView: View {
    @State private var step: UrgeStep = .home
    @State private var capturedObserve = ""
    @State private var capturedGratitude = ""
    @State private var isSaving = false
    
    @State private var userId: String? = Auth.auth().currentUser?.uid
    
    // Notes fetched exactly from your App's Accept framework
    let acceptCards = [
        "This thought resurfaced from something I watched before. It is allowed to come — I don't have to act on it.",
        "I have fallen before, and that is part of being human. Krishna's love for me does not depend on me perfect.",
        "Krishna gave me a heart to love. Even when no one stayed with me, He was with me, and He still is.",
        "Despite my failures, Radharani and Krishna have a heart for me. I am accepted, not condemned.",
        "I accept this feeling without fighting or hating myself. Acceptance, not shame, is how I get back up."
    ]
    @State private var randomQuote = ""
    
    @State private var timeRemaining = 60
    @State private var timer: Timer? = nil

    var body: some View {
        VStack {
            switch step {
            case .home:
                homeView
            case .observe:
                observeView
            case .accept:
                acceptView
            case .gratitude:
                gratitudeView
            case .reframe:
                reframeView
            case .redirect:
                redirectView
            case .success:
                successView
            }
        }
        .onAppear {
            if userId == nil {
                Auth.auth().signInAnonymously { authResult, _ in
                    self.userId = authResult?.user.uid
                }
            }
            randomQuote = acceptCards.randomElement() ?? ""
        }
    }
    
    var homeView: some View {
        VStack {
            Spacer()
            Button(action: {
                step = .observe
                capturedObserve = ""
                capturedGratitude = ""
                randomQuote = acceptCards.randomElement() ?? ""
            }) {
                VStack {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 40))
                    Text("URGE")
                        .font(.headline)
                        .bold()
                }
                .frame(width: 120, height: 120)
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
        }
    }
    
    var observeView: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("1. Observe")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text("Name what surfaced. Don't suppress it.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                
                TextField("Tap to dictate...", text: $capturedObserve)
                    .padding(.vertical, 5)
                
                if !capturedObserve.isEmpty {
                    Button("I've observed it →") { step = .accept }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                }
            }
            .padding(.horizontal, 5)
        }
    }
    
    var acceptView: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("2. Accept")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text(randomQuote)
                    .font(.footnote) // Smaller font to fit full quotes
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Button("I accept this →") { step = .gratitude }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
            }
            .padding(.horizontal, 5)
        }
    }
    
    var gratitudeView: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("3. Gratitude")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text("What has Krishna done for you? Dictate your gratitude.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                
                TextField("Tap to dictate...", text: $capturedGratitude)
                    .padding(.vertical, 5)
                
                Button(capturedGratitude.isEmpty ? "Skip / Next →" : "I am grateful →") { step = .reframe }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
            }
            .padding(.horizontal, 5)
        }
    }
    
    var reframeView: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("4. Reframe")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text("Krishna created woman to be protected and respected. She is someone's daughter, sister, mother. I honour her. This is my defence.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 5)
                
                Button("I've reframed it →") {
                    step = .redirect
                    startTimer()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
        }
    }
    
    var redirectView: some View {
        VStack {
            Text("5. Redirect")
                .font(.headline)
                .foregroundColor(.blue)
            
            Text("Breathe. Chant Hare Krishna.")
                .font(.footnote)
            
            Text("\(timeRemaining)")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(timeRemaining <= 10 ? .green : .white)
                .padding(.vertical, 5)
            
            if isSaving {
                ProgressView()
            } else if timeRemaining == 0 {
                Button("Save Victory") { saveUrge() }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
            } else {
                Button("End & Save") {
                    timer?.invalidate()
                    saveUrge()
                }
                .buttonStyle(.bordered)
                .tint(.gray)
            }
        }
    }
    
    var successView: some View {
        VStack {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
                .padding(.bottom, 10)
            Text("Redirected!")
                .font(.headline)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                step = .home
            }
        }
    }
    
    func startTimer() {
        timeRemaining = 60
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
    
    func saveUrge() {
        guard let uid = userId else { return }
        isSaving = true
        timer?.invalidate()
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)
        
        docRef.getDocument { snapshot, error in
            var entries: [[String: Any]] = []
            
            if let data = snapshot?.data(), let existingEntries = data["entries"] as? [[String: Any]] {
                entries = existingEntries
            }
            
            var noteParts: [String] = []
            if !capturedObserve.isEmpty { noteParts.append("Observed: \(capturedObserve)") }
            if !capturedGratitude.isEmpty { noteParts.append("Gratitude: \(capturedGratitude)") }
            
            let finalNote = noteParts.isEmpty ? "Completed the Watch chain." : noteParts.joined(separator: " • ")
            
            let newEntry: [String: Any] = [
                "id": Int(Date().timeIntervalSince1970 * 1000),
                "t": Int(Date().timeIntervalSince1970 * 1000),
                "urge": true,
                "gratitude": !capturedGratitude.isEmpty,
                "text": "⌚ Watch: " + finalNote,
                "tags": ["urge", "watch", "chain"]
            ]
            
            entries.insert(newEntry, at: 0)
            
            docRef.setData(["entries": entries], merge: true) { err in
                isSaving = false
                if err == nil {
                    withAnimation {
                        step = .success
                    }
                } else {
                    step = .home
                }
            }
        }
    }
}
