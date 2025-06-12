import SwiftUI

struct DashboardView: View {
    @Environment(\.dismiss) private var dismiss
    var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    var calendarDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: Date())
    }
    @State private var healthyStreakDays = 0
    @State private var calendarDays: [CalendarView.CalendarDay] = []
    @State private var isRecording = false
    @State private var headerVisible = false
    @State private var showHealthGoalsLoading = false
    @State private var navigateToHealthGoals = false
    @State private var showProfile = false
    let calendar = Calendar.current
    let today = Date()
    func simulateMonthData() -> [CalendarView.CalendarDay] {
        let range = calendar.range(of: .day, in: .month, for: today) ?? 1..<31
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        return range.map { day in
            let date = calendar.date(byAdding: .day, value: day-1, to: startOfMonth)!
            // Simulate: first 5 days green, next 2 yellow, next 1 red, repeat
            let mod = (day-1) % 8
            let completion: Double = mod < 5 ? 1.0 : (mod < 7 ? 0.7 : 0.3)
            return CalendarView.CalendarDay(date: date, completion: completion)
        }
    }
    func calculateStreak(_ days: [CalendarView.CalendarDay]) -> Int {
        let upToToday = days.filter { $0.date <= today }
        guard let last = upToToday.last, last.completion == 1.0 else { return 0 }
        var streak = 0
        for day in upToToday.reversed() {
            if day.completion == 1.0 {
                streak += 1
            } else if day.completion < 0.5 {
                break
            } else {
                break
            }
        }
        return streak
    }
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color(hex: "#EAEDED").ignoresSafeArea()
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // Amazon-style header (no logo)
                            HStack(alignment: .center, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Hi, John Doe,")
                                        .font(.system(size: 34, weight: .bold))
                                        .foregroundColor(.black)
                                    Text("Happy \(currentDateString)")
                                        .font(.system(size: 22, weight: .medium))
                                        .foregroundColor(Color.black.opacity(0.7))
                                }
                                Spacer()
                                // Profile avatar with navigation
                                Button(action: { showProfile = true }) {
                                    Circle()
                                        .fill(Color.black.opacity(0.08))
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.black)
                                                .font(.system(size: 18, weight: .bold))
                                        )
                                        .shadow(radius: 2)
                                }
                                .buttonStyle(PlainButtonStyle())
                                NavigationLink(destination: ProfileView(), isActive: $showProfile) { EmptyView() }
                            }
                            .padding(.top, geometry.safeAreaInsets.top + 8)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                            .background(Color(hex: "#EAEDED"))
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color.black.opacity(0.08)),
                                alignment: .bottom
                            )
                            .offset(y: headerVisible ? 0 : -40)
                            .opacity(headerVisible ? 1 : 0)
                            .animation(.easeOut(duration: 0.7), value: headerVisible)
                            .onAppear { headerVisible = true }
                            Spacer().frame(height: 8)
                            VStack(spacing: 16) {
                                Button(action: {
                                    showHealthGoalsLoading = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showHealthGoalsLoading = false
                                        navigateToHealthGoals = true
                                    }
                                }) {
                                    DashboardCard(
                                        title: "HEALTH GOALS",
                                        subtitle: "2 of 4 completed",
                                        icon: .system(name: "heart.fill"),
                                        gradient: Gradient(colors: [Color(hex: "#0097A6"), Color(hex: "#01A4B4")]),
                                        bottomInfoText: "Next Healthy Task: Drink 2L water"
                                    )
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(PlainButtonStyle())
                                NavigationLink(destination: HealthGoalsView(), isActive: $navigateToHealthGoals) { EmptyView() }
                                NavigationLink(destination: NutritionView()) {
                                    DashboardCard(
                                        title: "NUTRITION",
                                        subtitle: nil,
                                        icon: .system(name: "leaf.fill"),
                                        gradient: Gradient(colors: [.red, .orange]),
                                        calories: 350,
                                        calorieGoal: 2000,
                                        bottomInfoText: "Your dish match today: Grilled Salmon Salad"
                                    )
                                    .frame(maxWidth: .infinity)
                                }
                                HStack(spacing: 16) {
                                    NavigationLink(destination: CalendarView(healthyStreakDays: $healthyStreakDays, days: $calendarDays)) {
                                        DashboardCard(
                                            title: "CALENDAR",
                                            subtitle: "Healthy streak: \(healthyStreakDays) days",
                                            icon: .system(name: "calendar"),
                                            gradient: Gradient(colors: [.orange, .yellow])
                                        )
                                    }
                                    NavigationLink(destination: LifestyleView()) {
                                        DashboardCard(
                                            title: "EXPLORE LIFESTYLE",
                                            subtitle: "Tips for a healthy life",
                                            icon: .system(name: "magnifyingglass"),
                                            gradient: Gradient(colors: [.blue, .teal])
                                        )
                                    }
                                }
                                .onAppear {
                                    let simulated = simulateMonthData()
                                    calendarDays = simulated
                                    healthyStreakDays = calculateStreak(simulated)
                                    if let todayDay = simulated.first(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
                                        print("Today is day \(calendar.component(.day, from: today)): completion=\(todayDay.completion)")
                                    }
                                    print("Calculated streak: \(healthyStreakDays)")
                                }
                                Text("QUICK ACTIONS")
                                    .font(.caption).bold()
                                    .foregroundColor(Color(hex: "#0097A6").opacity(0.8))
                                    .padding(.leading, 8)
                                    .padding(.top, 8)
                                QuickActionsGrid()
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity)
                            Spacer()
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                    // Floating Mic Button
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            MicButton(isRecording: $isRecording)
                                .padding(.bottom, 16)
                                .padding(.trailing, 16)
                        }
                    }
                    // Centered Recording Popup
                    if isRecording {
                        RecordingPopup()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .transition(.opacity)
                            .zIndex(2)
                    }
                    if showHealthGoalsLoading {
                        HealthGoalsLoadingView()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .transition(.opacity)
                            .zIndex(3)
                    }
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Health Goals")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "#146eb4"))
                }
            }
        }
    }
}

// Helper enum for icon type
enum DashboardIcon {
    case system(name: String)
    case asset(name: String)
}

struct DashboardCard: View {
    let title: String
    let subtitle: String?
    let icon: DashboardIcon
    let gradient: Gradient
    var calories: Int? = nil
    var calorieGoal: Int? = nil
    var bottomInfoText: String? = nil
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    switch icon {
                    case .system(let name):
                        Image(systemName: name)
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    case .asset(let name):
                        Image(name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .shadow(radius: 2)
                    }
                    Spacer()
                }
                Text(title)
                    .font(.caption).bold()
                    .foregroundColor(.white.opacity(0.8))
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.title3).bold()
                        .foregroundColor(.white)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let calories = calories, let calorieGoal = calorieGoal {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(calories) / \(calorieGoal) kcal")
                            .font(.subheadline).bold()
                            .foregroundColor(.white)
                        ZStack(alignment: .leading) {
                            Capsule()
                                .frame(height: 8)
                                .foregroundColor(.white.opacity(0.3))
                            Capsule()
                                .frame(width: CGFloat(calories) / CGFloat(calorieGoal) * 120, height: 8)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 4)
                }
                if let bottomInfoText = bottomInfoText {
                    Spacer()
                    Text(bottomInfoText)
                        .font(.headline).bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 170)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#0097A6"), Color(hex: "#01A4B4")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(24)
            .shadow(color: Color(.systemGray4).opacity(0.5), radius: 6, x: 0, y: 2)
        }
    }
}

// Remove QuickActionsCard and add QuickActionsGrid and QuickActionButton

struct QuickActionsGrid: View {
    let actions: [(icon: String, title: String)] = [
        ("mic.fill", "My Health Journal"),
        ("dot.radiowaves.left.and.right", "My Health Device Buddies"),
        ("book.fill", "My Kindle Reading Buddy"),
        ("cart.fill", "My Wholefoods Grocery Orders"),
        ("pills.fill", "Amazon Pharmacy Medications"),
        ("stethoscope", "Book One Medical Appointment")
    ]
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(actions, id: \.title) { action in
                QuickActionButton(icon: action.icon, title: action.title)
            }
        }
        .padding()
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    var body: some View {
        Button(action: { /* Add action here */ }) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(LinearGradient(gradient: Gradient(colors: [Color(hex: "#0097A6"), Color(hex: "#01A4B4")]), startPoint: .topLeading, endPoint: .bottomTrailing)))
                    .shadow(radius: 4)
                Text(title)
                    .font(.subheadline).bold()
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: Color(.systemGray4).opacity(0.4), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Floating Mic Button
struct MicButton: View {
    @Binding var isRecording: Bool
    var onInfoTapped: (() -> Void)? = nil
    var body: some View {
        ZStack {
            Circle()
                .fill(isRecording
                    ? AnyShapeStyle(Color(red: 1.0, green: 0.6, blue: 0.0)) // Amazon Orange
                    : AnyShapeStyle(Color(.systemGray4))
                )
                .frame(width: 80, height: 80)
                .shadow(radius: 8)
            Image(systemName: "mic.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
        }
        .onTapGesture {
            isRecording.toggle()
        }
        .animation(.easeInOut(duration: 0.2), value: isRecording)
        .accessibilityLabel("Tap to start or stop Alexa listening")
    }
}

// Centered Recording Popup
struct RecordingPopup: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Color.black.opacity(0.25).ignoresSafeArea()
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color(hex: "#00C6AE"), Color(hex: "#01A4B4")]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: animate ? 120 : 100, height: animate ? 120 : 100)
                        .opacity(0.8)
                        .scaleEffect(animate ? 1.1 : 1.0)
                        .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: animate)
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("Alexa is Listening")
                    .font(.title2).bold()
                    .foregroundColor(Color(hex: "#00C6AE"))
            }
        }
        .onAppear { animate = true }
        .onDisappear { animate = false }
        .allowsHitTesting(false)
    }
}

#Preview {
    DashboardView()
        .previewDevice("iPhone 15 Pro")
}

// Add Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Simple HealthGoalsView placeholder
struct HealthGoalsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var goals: [String] = [
        "Drink 2L water",
        "Walk 10,000 steps",
        "Eat 5 servings of vegetables"
    ]
    @State private var newGoal: String = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Health Goals")
                .font(.largeTitle).bold()
                .padding([.top, .horizontal])
            List {
                ForEach(goals, id: \.self) { goal in
                    Text(goal)
                }
                .onDelete { indexSet in
                    goals.remove(atOffsets: indexSet)
                }
                HStack {
                    TextField("Add new goal", text: $newGoal)
                        .textFieldStyle(PlainTextFieldStyle())
                    Button(action: {
                        let trimmed = newGoal.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        goals.append(trimmed)
                        newGoal = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#0097A6"))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Health Goals")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "#146eb4"))
                }
            }
        }
    }
}

struct NutritionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var animateRings = false
    struct NutritionGoal: Identifiable, Hashable {
        let id = UUID()
        var name: String
        var current: Double
        var goal: Double
        var color: Color
    }
    @State private var nutritionGoals: [NutritionGoal] = [
        NutritionGoal(name: "Calories", current: 1500, goal: 2000, color: Color(hex: "#00C6AE")),
        NutritionGoal(name: "Carbs", current: 120, goal: 300, color: Color(hex: "#F9A825")),
        NutritionGoal(name: "Protein", current: 80, goal: 100, color: Color(hex: "#1976D2")),
        NutritionGoal(name: "Fiber", current: 10, goal: 30, color: Color(hex: "#8BC34A"))
    ]
    @State private var newGoalName: String = ""
    @State private var newGoalCurrent: String = ""
    @State private var newGoalTarget: String = ""
    var body: some View {
        VStack {
            Text("Daily Nutrition Completion")
                .font(.title2).bold()
                .foregroundColor(.black)
                .padding(.top, 24)
            NutritionProgressRingsView(
                goals: Array(nutritionGoals.prefix(4)),
                percentage: animateRings ? nutritionGoals.prefix(4).map { $0.current / max($0.goal, 1) }.reduce(0, +) / max(Double(nutritionGoals.prefix(4).count), 1) : 0
            )
            .frame(width: 180, height: 180)
            .padding(.top, 8)
            .onAppear { withAnimation(.easeOut(duration: 1.2)) { animateRings = true } }
            Spacer().frame(height: 24)
            HStack(spacing: 18) {
                ForEach(nutritionGoals.prefix(4), id: \.id) { goal in
                    RingLegend(color: goal.color, label: goal.name)
                }
            }
            .padding(.bottom, 16)

            // Progress bars for each goal
            VStack(spacing: 16) {
                ForEach(nutritionGoals) { goal in
                    NutritionGoalProgressBar(goal: goal)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)

            // Editable table for nutrition goals
            VStack(alignment: .leading, spacing: 8) {
                Text("Modify Nutrition Goals")
                    .font(.headline)
                    .padding(.bottom, 4)
                ForEach(nutritionGoals) { goal in
                    HStack {
                        Text(goal.name)
                            .font(.subheadline)
                            .frame(width: 80, alignment: .leading)
                        Spacer()
                        Text("Current: \(Int(goal.current))")
                            .font(.caption)
                        Text("Goal: \(Int(goal.goal))")
                            .font(.caption)
                        Button(action: {
                            if let idx = nutritionGoals.firstIndex(of: goal) {
                                nutritionGoals.remove(at: idx)
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                HStack {
                    TextField("New goal name", text: $newGoalName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 90)
                    TextField("Current", text: $newGoalCurrent)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(width: 60)
                    TextField("Goal", text: $newGoalTarget)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(width: 60)
                    Button(action: {
                        let trimmed = newGoalName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty,
                              let current = Double(newGoalCurrent),
                              let target = Double(newGoalTarget),
                              target > 0 else { return }
                        nutritionGoals.append(NutritionGoal(name: trimmed, current: current, goal: target, color: .gray))
                        newGoalName = ""
                        newGoalCurrent = ""
                        newGoalTarget = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#0097A6"))
                    }
                }
            }
            .padding()
            Spacer()
        }
        .navigationTitle("Nutrition")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "#146eb4"))
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

// Safe array index extension
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct NutritionGoalProgressBar: View {
    var goal: NutritionView.NutritionGoal
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(goal.name)
                    .font(.subheadline).bold()
                    .foregroundColor(goal.color)
                Spacer()
                Text(String(format: "%d / %d", Int(goal.current), Int(goal.goal)))
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(String(format: "%.0f%%", min(goal.current / max(goal.goal, 1), 1) * 100))
                    .font(.caption).bold()
                    .foregroundColor(goal.color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .frame(height: 10)
                        .foregroundColor(goal.color.opacity(0.18))
                    Capsule()
                        .frame(width: CGFloat(min(goal.current / max(goal.goal, 1), 1)) * geo.size.width, height: 10)
                        .foregroundColor(goal.color)
                }
            }
            .frame(height: 10)
        }
    }
}

struct NutritionProgressRingsView: View {
    var goals: [NutritionView.NutritionGoal] // up to 4
    var percentage: Double // 0...1
    let ringWidths: [CGFloat] = [18, 14, 10, 10]
    let paddings: [CGFloat] = [0, 12, 24, 36]
    var body: some View {
        ZStack {
            ForEach(Array(goals.enumerated()), id: \.element.id) { idx, goal in
                Circle()
                    .trim(from: 0, to: min(goal.current / max(goal.goal, 1), 1))
                    .stroke(goal.color, style: StrokeStyle(lineWidth: ringWidths[safe: idx] ?? 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .opacity(0.85)
                    .padding(paddings[safe: idx] ?? 0)
            }
            // Percentage in the center
            VStack {
                Text("\(Int(percentage * 100))%")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#00C6AE"))
                Text("Complete")
                    .font(.caption).bold()
                    .foregroundColor(.gray)
            }
        }
    }
}

struct RingLegend: View {
    var color: Color
    var label: String
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.caption).bold()
                .foregroundColor(.black)
        }
    }
}

struct CalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var healthyStreakDays: Int
    @Binding var days: [CalendarDay]
    let calendar = Calendar.current
    let today = Date()
    struct CalendarDay: Identifiable {
        let id = UUID()
        let date: Date
        let completion: Double // 0...1
    }
    var body: some View {
        VStack(spacing: 0) {
            Text("Health Goal Streak: \(healthyStreakDays) days")
                .font(.title2).bold()
                .foregroundColor(Color(hex: "#00C6AE"))
                .padding(.top, 24)
            CalendarMonthView(days: days)
                .padding(.vertical, 16)
            Spacer()
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "#146eb4"))
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

struct CalendarMonthView: View {
    let days: [CalendarView.CalendarDay]
    let calendar = Calendar.current
    var body: some View {
        let firstDay = days.first?.date ?? Date()
        let weekday = calendar.component(.weekday, from: firstDay)
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        VStack(spacing: 8) {
            HStack {
                ForEach(["S","M","T","W","T","F","S"], id: \.self) { d in
                    Text(d).font(.caption2).bold().frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<(weekday-1), id: \.self) { _ in
                    Color.clear.frame(height: 32)
                }
                ForEach(days) { day in
                    if day.date <= Date() {
                        let color: Color = day.completion == 1.0 ? Color.green : (day.completion > 0.5 ? Color.yellow : Color.red)
                        VStack {
                            Text("\(calendar.component(.day, from: day.date))")
                                .font(.subheadline).bold()
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(color.opacity(0.7)))
                                .foregroundColor(.white)
                        }
                    } else {
                        VStack {
                            Text("\(calendar.component(.day, from: day.date))")
                                .font(.subheadline).bold()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct LifestyleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    struct Article: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let image: String // SF Symbol
    }
    let articles: [Article] = [
        Article(title: "10-Minute Morning Yoga", subtitle: "Start your day with energy and focus.", image: "figure.yoga"),
        Article(title: "Healthy Meal Prep", subtitle: "Easy recipes for a balanced diet.", image: "leaf"),
        Article(title: "Sleep Hygiene Tips", subtitle: "Improve your rest with science-backed advice.", image: "bed.double.fill"),
        Article(title: "Mindful Breathing", subtitle: "Reduce stress in 5 minutes.", image: "wind"),
        Article(title: "Walking for Wellness", subtitle: "How daily walks boost your health.", image: "figure.walk"),
        Article(title: "Hydration Hacks", subtitle: "Stay refreshed all day.", image: "drop.fill")
    ]
    var filteredArticles: [Article] {
        if searchText.isEmpty { return articles }
        return articles.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.subtitle.localizedCaseInsensitiveContains(searchText) }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Explore Lifestyle")
                    .font(.largeTitle).bold()
                Spacer()
            }
            .padding([.top, .horizontal])
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search articles", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 8)
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 18) {
                    ForEach(filteredArticles) { article in
                        VStack(alignment: .leading, spacing: 10) {
                            Image(systemName: article.image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 48)
                                .foregroundColor(Color(hex: "#00C6AE"))
                                .padding(.top, 8)
                            Text(article.title)
                                .font(.headline).bold()
                                .foregroundColor(.black)
                            Text(article.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 160)
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: Color(.systemGray4).opacity(0.25), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .navigationTitle("Explore Lifestyle")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "#146eb4"))
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

struct HealthGoalsLoadingView: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color(hex: "#00C6AE"), Color(hex: "#01A4B4")]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: animate ? 120 : 100, height: animate ? 120 : 100)
                        .opacity(0.8)
                        .scaleEffect(animate ? 1.1 : 1.0)
                        .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: animate)
                    Image(systemName: "bolt.heart.fill")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("Creating health goals for today based on your profile")
                    .font(.title3).bold()
                    .foregroundColor(Color(hex: "#00C6AE"))
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear { animate = true }
        .onDisappear { animate = false }
        .allowsHitTesting(true)
    }
}

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 32)
            Circle()
                .fill(Color(hex: "#EAEDED"))
                .frame(width: 110, height: 110)
                .overlay(
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                )
                .shadow(radius: 6)
            Text("John Doe")
                .font(.title).bold()
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "envelope.fill").foregroundColor(.blue)
                    Text("john.doe@email.com")
                }
                HStack {
                    Image(systemName: "calendar").foregroundColor(.green)
                    Text("Age: 29")
                }
                HStack {
                    Image(systemName: "figure.walk").foregroundColor(.orange)
                    Text("Steps goal: 10,000/day")
                }
            }
            .font(.headline)
            .padding(.top, 8)
            Spacer()
        }
        .padding()
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "#146eb4"))
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
} 
