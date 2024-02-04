//
//  ContentView.swift
//  BetterRest
//
//  Created by Chad Eymard on 1/29/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWaketime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWaketime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var calculateBedtime: String {
        get {
            do {
                let config = MLModelConfiguration()
                let model = try SleepCalculator(configuration: config)
                
                let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
                let hour = (components.hour ?? 0) * 60 * 60
                let minute = (components.minute) ?? 0 * 60
                
                let prediction = try model.prediction(wake: Int64((hour + minute)), estimatedSleep: sleepAmount, coffee: Int64(coffeeAmount))
                
                let sleepTime = wakeUp - prediction.actualSleep
                
                return sleepTime.formatted(date: .omitted, time: .shortened)
                
            } catch {
                alertTitle = "Error"
                alertMessage = "Sorry, there was an error calculating your bedtime."
                
                showingAlert = true
            }
            return "Error"
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Text("Your ideal bedtime is \(calculateBedtime)")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Text("When do you want to wake up?")
                            .font(.headline)
                    Spacer()
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    Spacer()
                }
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Spacer()
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    Spacer()
                }
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Text("Daily coffee intake")
                        .font(.headline)
                    Spacer()
 
                    Picker("^[\(coffeeAmount) cup](inflect: true)", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            Text("^[\($0) cup](inflect: true)")
                        }
                    }
                    .labelsHidden()

                    Spacer()
                }
            }
            .navigationTitle("BetterRest")
        }
    }
}

#Preview {
    ContentView()
}
