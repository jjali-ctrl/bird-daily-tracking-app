////
//  ContentView.swift
//  Bird app
//
//  Created by Mac on 9/21/25.
//
import SwiftUI
import Charts  // iOS16+ 自带的 Swift Charts 框架
import PhotosUI

// MARK: - 数据模型
struct FeedingRecord: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var foodType: String
    var foodAmount: Double
    var weight: Double
    var notes: String? = nil  // 备注
}

struct Bird: Identifiable {
    var id = UUID()
    var name: String = "Unnamed"
    var species: String = "Unknown species"
    var gender: String = "Male/Female"
    var weight: String = "---kg"
    var notes: String = "Comments"
    var image: String? = nil
    var records: [FeedingRecord] = []  // 每日记录
    var profileImage:UIImage? //存头像
}

// MARK: - App 入口
@main
struct BirdApp: App {
    var body: some Scene {
        WindowGroup {
            IntroView()   // App 启动时先显示 IntroView
        }
    }
}

// MARK: - IntroView
struct IntroView: View {
    @State private var showLogin = false
    
    var body: some View {
        if showLogin {
            LoginView()
        } else {
            VStack(spacing: 20) {
                Image(systemName: "bird")
                    .resizable()
                    .scaledToFit()
                    .frame(width:150, height:150)
                    .foregroundStyle(.indigo)
                
                Text("Birds Health Tracker")
                    .font(.largeTitle)
                    .bold()
                
                Text("Welcome! Bird Lovers")
                    .foregroundStyle(.gray)
            }
            .padding()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showLogin = true
                }
            }
        }
    }
}

// MARK: - LoginView
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            ContentView()
        } else {
            VStack(spacing:20) {
                Text("Login")
                    .font(.largeTitle)
                    .bold()
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Button("Login") {
                    if password == "000000" {
                        isLoggedIn = true
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

// MARK: - 菜单 ContentView
struct ContentView: View {
    @State private var birds:[Bird] = []
    
    var body: some View {
        NavigationStack {
            List($birds) { $bird in
                NavigationLink{
                    BirdDetailView(bird: $bird)
                } label: {
                    HStack {
                        if let img = bird.profileImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width:40, height:40)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "bird")
                                .resizable()
                                .scaledToFill()
                                .frame(width:40, height:40)
                                .foregroundColor(.gray)
                        }
                        
                        Text("\(bird.name) - \(bird.species)")
                    }
                }
            }
            .navigationTitle("All Birds")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action:addBird){
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    private func addBird() {
        let newBird = Bird(name: "new bird")
        birds.append(newBird)
        
    }
}

// MARK: - BirdMainView
struct BirdMainView: View {
    @Binding var bird: Bird
    @State private var foodType = ""
    @State private var foodAmount = ""
    @State private var weight = ""
    @State private var notes = ""
    @State private var date = Date()
    @State private var viewMode: String = "Chart"
    
    let modes = ["Chart", "Table"]
    
    var body: some View {
        VStack {
            // 切换模式
            Picker("Display Mode", selection: $viewMode) {
                ForEach(modes, id: \.self) { mode in
                    Text(mode).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            if viewMode == "Chart" {
                // 图表模式
                if bird.records.isEmpty {
                    Text("No available data")
                        .foregroundStyle(.gray)
                        .padding()
                } else {
                    Chart {
                        ForEach(bird.records) { record in
                            LineMark(
                                x: .value("Date", record.date),
                                y: .value("Weight (g)", record.weight)
                            )
                            .foregroundStyle(.blue)
                            .symbol(.circle)
                            .interpolationMethod(.monotone)
                            .annotation(position: .top) {
                                Text("\(Int(record.weight))g")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                        ForEach(bird.records) { record in
                            LineMark(
                                x: .value("Date", record.date),
                                y: .value("Feeding (g)", record.foodAmount)
                            )
                            .foregroundStyle(.green)
                            .symbol(.square)
                            .interpolationMethod(.monotone)
                            .annotation(position: .top) {
                                Text("\(Int(record.foodAmount))g")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                    .frame(height: 200)
                    .padding()
            }else {
                // 表格模式
                if bird.records.isEmpty {
                    Text("No available data")
                        .foregroundStyle(.gray)
                        .padding()
                } else {
                    List {
                        HStack {
                            Text("Date").bold()
                            Spacer()
                            Text("Food type").bold()
                            Spacer()
                            Text("Feeding quantity (g)").bold()
                            Spacer()
                            Text("Weight(g)").bold()
                            Spacer()
                            Text("Comments").bold()
                        }
                        ForEach(bird.records) { record in
                            HStack {
                                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                                Spacer()
                                Text(record.foodType)
                                Spacer()
                                Text("\(record.foodAmount, specifier: "%.1f")")
                                Spacer()
                                Text("\(record.weight, specifier: "%.1f")")
                                Spacer()
                                Text(record.notes ?? "-")
                            }
                        }
                    }
                }
            }
            
            // 输入表单
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Food type", text: $foodType)
                TextField("Feeding quantity (g)", text: $foodAmount)
                    .keyboardType(.decimalPad)
                TextField("Weight (g)", text: $weight)
                    .keyboardType(.decimalPad)
                TextField("Comments", text: $notes)
                
                Button("Adding records") {
                    if let amount = Double(foodAmount),
                       let w = Double(weight) {
                        let newRecord = FeedingRecord(
                            date: date,
                            foodType: foodType,
                            foodAmount: amount,
                            weight: w,
                            notes: notes.isEmpty ? nil : notes
                        )
                        bird.records.append(newRecord)
                        
                        // 清空
                        foodType = ""
                        foodAmount = ""
                        weight = ""
                        notes = ""
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("\(bird.name)-\(bird.species)")
    }
}

// MARK: - BirdDetailView
struct BirdDetailView: View {
    @Binding var bird: Bird
    @State private var showProfileEditor = false
    
    var body: some View {
        BirdMainView(bird: $bird)
            .toolbar{
                ToolbarItem(placement:.navigationBarTrailing){
                    Button{
                        showProfileEditor = true
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showProfileEditor){
                BirdProfileView(bird: $bird)
            }
    }
}

// MARK: - BirdProfileView
struct BirdProfileView: View {
    @Binding var bird: Bird
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        NavigationStack{
            Form {
                Section("Basic information") {
                    TextField("Name", text: $bird.name)
                    TextField("Species", text: $bird.species)
                    TextField("Sex", text: $bird.gender)
                    TextField("Initial Weight", text: $bird.weight)
                }
                
                Section("Condition") {
                    TextField("Condition when coming", text: $bird.notes)
                }
                Section("TAKE A PHOTO"){
                    if let img=bird.profileImage {
                        Image(uiImage:img)
                            .resizable()
                            .scaledToFit()
                            .frame(height:150)
                            .clipShape(RoundedRectangle(cornerRadius:12))
                    }
                    PhotosPicker("select a photo", selection: $selectedItem, matching:.images)
                        .onChange(of: selectedItem) {oldItem, newItem in
                            guard let newItem else { return }
                            Task{
                                if let data = try? await newItem.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data:data) {
                                    bird.profileImage = uiImage
                                }
                            }
                        }
                }
                Section {
                    Button("Confirm") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("Edit Profile")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Confirm") {
                    dismiss()
            }
        }
    }
