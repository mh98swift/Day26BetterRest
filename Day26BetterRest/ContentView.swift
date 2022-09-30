//
//  ContentView.swift
//  Day26BetterRest
//
//  Created by VCM1 on 12/09/2022.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var titleAlert = ""
    @State private var messageAlert = ""
    @State private var showAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView{
            Form{
                VStack(alignment: .leading, spacing: 10){
                    Text("When You Want to get up?")
                        .font(.headline)
                    DatePicker(
                        "Please pick a time",
                        selection: $wakeUp,
                            displayedComponents:
                                .hourAndMinute)
                                .labelsHidden()
                }
                VStack(alignment: .leading, spacing: 10){
                      Text("Desire amount of sleep?")
                            .font(.headline)
                        Stepper(sleepAmount.formatted(), value: $sleepAmount, in: 4...12, step: 0.25)
                        Text("Cups of coffee you drink?")
                            .font(.headline)
                        Stepper(String(coffeeAmount), value: $coffeeAmount, in: 0...20, step: 1)
                }.padding()
            }
            .navigationTitle("Better Rest")
                .toolbar{
                    Button("Calculate", action: calculateBedTime)
                }.alert(titleAlert, isPresented: $showAlert){
                    Button("OK") {}
                } message: {
                    Text(messageAlert)
                }
        }
    }
    
    func calculateBedTime(){
  // start count from 24:00 -> 8 = 8
        //                         |
        //WEAK UP TIME exp: 8:00am 8h = 8 * 60m * 60s
        //ESTIMATED SLEEP
        
        //We Have sleep amount & coffee amount
        do {
            let config = MLModelConfiguration()
            let modal = try SleepCalculator(configuration: config)
            //Transfer date to second
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60 //con to sec
            let min = (components.minute ?? 0) * 60 //con to sec
            //predict how much sleep they need
            let predication = try modal.prediction(wake: Double(hour + min), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            //date
            let sleepTime = wakeUp - predication.actualSleep
            // convert date to seconds
            titleAlert = "your bed time"
            messageAlert = sleepTime.formatted(date: .omitted, time: .shortened)
            
            
        } catch  {
            titleAlert = "Error"
            messageAlert = "calculating bed time"
        }
        
        showAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
