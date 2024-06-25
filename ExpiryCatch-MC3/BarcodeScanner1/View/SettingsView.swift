//
//  SettingsView.swift
//  BarcodeScanner1
//
//  Created by Francesca Ferrini on 23/02/24.
//

import SwiftUI

struct SettingsView: View {
    
    //Differenciate alert typo
    enum alertStyle {
        case sameDay, dayBefore, threedaysbefore
    }
    
    @State private var darkModeToggle: Bool = false
    @State private var notificationsToggle: Bool = false
    @State private var alertPicker: alertStyle = .sameDay
    @State var notificationTime: Date
    
    
    var body: some View {
        List {
            //User preferences
            Section {
                NavigationLink("Change the mood!") {
                    TemporaryView()
                }
                Toggle("Dark mode", isOn: $darkModeToggle)
            } header: {
                Text("Preferences")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.black)
            }
            
            //Notifications management
            Section {
                Toggle("Disable notifications", isOn: $notificationsToggle)
                
                DatePicker("Change time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                
                Picker("Alert", selection: $alertPicker) {
                    Text("Same day").tag(alertStyle.sameDay)
                    Text("Day before").tag(alertStyle.dayBefore)
                    Text("Three days before").tag(alertStyle.threedaysbefore)
                }
                
            } header: {
                Text("Notifications")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.black)
            }
            
            //Support section
            Section {
                NavigationLink("Terms & policies") {
                    TemporaryView()
                }
                NavigationLink("Help") {
                    TemporaryView()
                }
                NavigationLink("Contact us") {
                    TemporaryView()
                }
            } header: {
                Text("Support")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.black)
            }
        }
        .listStyle(.automatic)
    }
}


#Preview {
    SettingsView(notificationTime: Date())
}
