//
//  ListView.swift
//  BarcodeScanner1
//
//  Created by Francesca Ferrini on 23/02/24.
//

import SwiftUI
import AVFoundation





struct ListView: View {
    @ObservedObject var savedProduct: SavedFoodViewModel
    @State private var isAnotherViewActive = false
    @State var productResponse: ProductResponse?
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }
    
    
    
    var body: some View {
        
        NavigationView {
            ZStack{
                Color.color2.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    LazyVStack (alignment: .leading){
                        // Sezione per i prodotti in scadenza
                        if savedProduct.savedFoods.contains(where: { food in
                            if let expirationDate = food.expirationDate {
                                return Calendar.current.isDateInTomorrow(expirationDate) || Calendar.current.isDateInToday(expirationDate)
                            }
                            return false
                        }) {
                            Text("About to expire!").foregroundColor(.green).bold().font(.title)
                            ForEach(savedProduct.savedFoods.filter { food in
                                if let expirationDate = food.expirationDate {return Calendar.current.isDateInTomorrow(expirationDate) || Calendar.current.isDateInToday(expirationDate)
                                }
                                return false
                            }, id: \.self) { food in
                                // Visualizza i prodotti in scadenza
                                NavigationLink(destination: ProductDetailView(savedProduct: savedProduct, food: food)) {
                                    VStack {
                                        HStack {
                                            AsyncImage(url: food.imageUrl ?? URL(string: "placeholder")!) {
                                                ProgressView()
                                            }
                                            .frame(width: 100, height: 100)
                                            .foregroundStyle(.primary)
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .foregroundColor(Color.white)
                                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                            )
                                            .padding(.top, 20)
                                            .padding(.trailing, 10)
                                            VStack {
                                                Text(food.productName ?? "Name not found")
                                                    .foregroundColor(.black)
                                                    .bold()
                                                    
                                                
                                                if let expirationDate = food.expirationDate {
                                                    if Calendar.current.isDateInTomorrow(expirationDate) || Calendar.current.isDateInToday(expirationDate) {Image(systemName: "exclamationmark.triangle")
                                                            .foregroundColor(.yellow)
                                                        
                                                    }
                                                } else {
                                                    Text("Expiration date not available")
                                                }
                                                
                                                if let expirationDate = food.expirationDate {
                                                    VStack{
                                                        Text("Expiration date: ").foregroundColor(.black)
                                                        Text("\(dateFormatter.string(from: expirationDate))")
                                                            .foregroundColor(.black)
                                                    }
                                                } else {
                                                    Text("Expiration date not available")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                        // Sezione per i prodotti non in scadenza
                        let nonScaduti = savedProduct.savedFoods.filter { food in
                            if let expirationDate = food.expirationDate {
                                return !Calendar.current.isDateInTomorrow(expirationDate) && !Calendar.current.isDateInToday(expirationDate)
                            }
                            return true
                        }
                        
                        if !nonScaduti.isEmpty {
                            Text("Products").foregroundColor(.green).bold().font(.title).padding(.top,20)
                            ForEach(nonScaduti, id: \.self) { food in
                                // Visualizza i prodotti non in scadenza
                                NavigationLink(destination: ProductDetailView(savedProduct: savedProduct, food: food)) {
                                    VStack {
                                        HStack {
                                            AsyncImage(url: food.imageUrl ?? URL(string: "placeholder")!) {
                                                ProgressView()
                                            }
                                            .frame(width: 75, height: 75)
                                            .foregroundStyle(.primary)
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .foregroundColor(Color.white)
                                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                            )
                                            .padding(.top, 20)
                                            .padding(.trailing, 40)
                                            VStack {
                                                Text(food.productName ?? "Name not found")
                                                    .foregroundColor(.black)
                                                    .bold()
                                                    
                                                
                                                if let expirationDate = food.expirationDate {
                                                    if Calendar.current.isDateInTomorrow(expirationDate) || Calendar.current.isDateInToday(expirationDate) {
                                                        Image(systemName: "exclamationmark.triangle")
                                                            .foregroundColor(.yellow)
                                                        
                                                    }
                                                } else {
                                                    Text("Expiration date not available")
                                                }
                                                
                                                if let expirationDate = food.expirationDate {
                                                    VStack{
                                                        Text("Expiration date: ").foregroundColor(.black)
                                                        Text("\(dateFormatter.string(from: expirationDate))")
                                                            .foregroundColor(.black)
                                                    }
                                                } else {
                                                    Text("Expiration date not available")
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .onAppear {
                        savedProduct.sortSavedFoodsByExpirationDate()
                    }
                    .padding(.horizontal)
                }
                
                if savedProduct.savedFoods.isEmpty {
                    Image("scan")
                        .padding(.top,-100)
                }
            }
            .navigationBarItems(
                leading:
                    Button(action: {
                        self.isAnotherViewActive = true
                    }) {
                        Image(systemName: "gearshape").foregroundColor(.green).font(.system(size: 20))
                    },
                trailing:
                    NavigationLink(destination: BarcodeScannerView(productResponse: $productResponse, savedProduct: savedProduct)) {
                        Image(systemName: "barcode.viewfinder").foregroundColor(.green).font(.system(size: 20))
                    }
            )
            .background(
                NavigationLink(destination: SettingsView(notificationTime: Date()), isActive: $isAnotherViewActive) {
                    EmptyView()
                }
            )
        }
    }
}
