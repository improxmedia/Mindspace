import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    @State private var showingDictation = false
    @State private var capturedText = ""
    @State private var isSaving = false
    @State private var showSuccess = false
    
    // Replace with the user's UID after sign-in (or use anonymous auth)
    @State private var userId: String? = Auth.auth().currentUser?.uid
    
    var body: some View {
        VStack {
            if showSuccess {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                    .padding()
                Text("Saved & Redirected")
                    .font(.headline)
            } else {
                Spacer()
                
                Button(action: {
                    showingDictation = true
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
                    .shadow(color: .red.opacity(0.6), radius: 10, x: 0, y: 0)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Text("Tap to capture via Voice")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .sheet(isPresented: $showingDictation) {
            TextField("Speak your urge...", text: $capturedText)
                .textContentType(.name) // Triggers dictation UI on watchOS
                .onSubmit {
                    saveUrge()
                }
        }
        .onAppear {
            // If user isn't logged in, log them in anonymously for demo
            if userId == nil {
                Auth.auth().signInAnonymously { authResult, error in
                    if let user = authResult?.user {
                        self.userId = user.uid
                    }
                }
            }
        }
    }
    
    func saveUrge() {
        guard let uid = userId, !capturedText.isEmpty else { return }
        isSaving = true
        showingDictation = false
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)
        
        // Fetch existing data or create new entry
        docRef.getDocument { snapshot, error in
            var entries: [[String: Any]] = []
            
            if let data = snapshot?.data(), let existingEntries = data["entries"] as? [[String: Any]] {
                entries = existingEntries
            }
            
            let newEntry: [String: Any] = [
                "id": Int(Date().timeIntervalSince1970 * 1000),
                "t": Int(Date().timeIntervalSince1970 * 1000),
                "urge": true,
                "gratitude": false,
                "text": "Observed via Watch Voice: \(capturedText)",
                "tags": ["urge", "watch", "voice"]
            ]
            
            entries.insert(newEntry, at: 0)
            
            docRef.setData(["entries": entries], merge: true) { err in
                isSaving = false
                if err == nil {
                    withAnimation {
                        showSuccess = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSuccess = false
                            capturedText = ""
                        }
                    }
                }
            }
        }
    }
}
