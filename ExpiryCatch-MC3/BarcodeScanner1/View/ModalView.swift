//
//  ModalView.swift
//  BarcodeScanner1
//
//  Created by Fernando Sensenhauser on 29/02/24.
//


import SwiftUI
import AVFoundation

struct ModalView: View {
    
    @Binding var isShowingScanner: Bool
    @Binding var productResponse: ProductResponse?
    @ObservedObject var savedProduct: SavedFoodViewModel
    @State var saved: SavedFoodModel?
    @Binding var scannedCode: String?
    @Environment(\.presentationMode) var presentationMode
    @State private var date = Date()
    @State private var showAlert = false
    @State private var isDateSelected = false
    @State private var imageURL: URL?
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    dismissModal()
                }
                .bold()
                .padding()
                
                Spacer()
                
                Button("Add") {
                    if isDateSelected {
                        saveProduct()
                    } else {
                        showAlert = true
                    }
                }
                .font(.headline)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Alert"), message: Text("Please select an expiration date."), dismissButton: .default(Text("OK")))
                }
                .padding()
            }
            .padding(.horizontal)
            
            
            ZStack {
                Rectangle()
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                if let imageUrl = imageURL {
                    AsyncImage(url: imageUrl) {
                        Image(systemName: "photo")
                            .resizable()
                            .cornerRadius(10)
                            .frame(width: 100, height: 100)
                    }
                    .padding()
                }
            }
            .frame(width: 200, height: 200)
            .padding(.top, 50)
            .padding(.bottom, 20)
            
            productNameView.bold().padding(.bottom,20)
            
            List{
                scoreView()
                
                Text("Scanned Code: ").bold()
                    + Text(" \(scannedCode ?? "not found") ")
                
                if productResponse?.product?.productName != nil {
                    HStack{
                        Text("Select expiration date: ").bold()
                        DatePicker(
                            "", selection: $date,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                        .padding()
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .onAppear {
            fetchProductDataIfNeeded()
        }
        .onChange(of: date) { _ in
            isDateSelected = true
        }
    }
    
    private var productNameView: some View {
        if let productName = productResponse?.product?.productName {
            return Text("Product Name: \(productName)")
        } else {
            return Text("Product Name: Unknown, please try again")
        }
    }
    
    private func scoreView() -> some View {
        if let nutriments = productResponse?.product?.nutriments {
            return AnyView(
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nutrients:")
                        .font(.headline)
                    Text(String(format: "Carbohydrates: %.2f g", nutriments.carbohydrates ?? 0))
                    Text(String(format: "Sugars: %.2f g", nutriments.sugars ?? 0))
                    Text("Energy (kcal): \(nutriments.energyKcal ?? 0) kcal")
                }
            )
        } else {
            return AnyView(
                Text("Nutritional information not available")
            )
        }
    }
    
    private func fetchProductDataIfNeeded() {
        guard let scannedCode = scannedCode else { return }
        let

apiUrl = "https://world.openfoodfacts.net/api/v2/product/\(scannedCode).json"
        if let url = URL(string: apiUrl) {
            let session = URLSession.shared
            let task = session.dataTask(with: url) { data, response, error in
                guard let data = data else {
                    print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(ProductResponse.self, from: data)
                    DispatchQueue.main.async {
                        imageURL = result.product?.image
                        productResponse = result
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }
            task.resume()
        } else {
            print("Invalid URL")
        }
    }
    
    private func saveProduct() {
        saved = SavedFoodModel(productName: productResponse?.product?.productName, imageUrl: productResponse?.product?.image, nutritionGrades: productResponse?.product?.nutritionGrades, expirationDate: date)
        savedProduct.savedFoods.append(saved!)
        savedProduct.saveProduct(saved!)
        dismissModal()
    }
    
    private func dismissModal() {
        presentationMode.wrappedValue.dismiss()
        isShowingScanner = true
    }
}
