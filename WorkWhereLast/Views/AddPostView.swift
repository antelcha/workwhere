//
//  AddPostView.swift
//  WorkWhereLast
//
//  Created by Mustafa Girgin on 20.03.2024.
//

import Foundation
import SwiftUI

struct AddPostView: View {
    @FocusState public var isFocused: Bool
    @State private var isShowingImagePicker = false

    @ObservedObject var vm: AddPostViewModel = AddPostViewModel()

    init() {
        
    }

    private var buttonsView: some View {
        HStack {
            Spacer()
            Button(action: {
                Task {
                    await vm.sharePost()
                }

            }, label: {
                if vm.isSharingPost {
                    ProgressView()
                        .bold()

                        .padding()
                } else {
                    Text("Share")
                        .bold()

                        
                }

            })
            .disabled(vm.isSharingPost)

        }
    }

    private var photoPickerAndPresenter: some View {
        ZStack {
            
                
            Image(uiImage: vm.selectedImages ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaledToFit()
                        .frame(height: 300)
                
            
            
            .opacity(vm.selectedImages == nil ? 0 : 1)
            
            

            Button(action: {
                DispatchQueue.main.async {
                                isShowingImagePicker = true
                            }
                        }) {
                            Image(systemName: "photo.stack")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100)
                                
                                .vibrancyEffect()
                                
                                .opacity(vm.selectedImages != nil ? 0 : 1)
                        }
                        .sheet(isPresented: $isShowingImagePicker) {
                            
                           
                                ImagePicker(selectedImage: $vm.selectedImages)
                            
                        }
                    

           
        }
    }

    var body: some View {
        ScrollView {
            photoPickerAndPresenter.frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            Spacer().frame(height: 30)
           

            locationView

            Spacer().frame(height: 30)

            Divider()
                .frame(height: 20)
                .padding(.horizontal, 14)

            TitleTextField(title: $vm.title, isFocused: _isFocused)

            Divider()
                .frame(height: 20)
                .padding(.horizontal, 14)

            DescriptionTextField(description: $vm.description, isFocused: _isFocused)

            Spacer().frame(height: 300)
        }

        .scrollIndicators(.hidden)

        .padding(.horizontal)
        
        .toastView(toast: $vm.toast)
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                buttonsView
            }
        })
    }

    private var locationView: some View {
        Button {
            vm.isSelectingLocation = true
        } label: {
            HStack {
                if vm.location == nil {
                    Text("Select location on map")
                } else {
                    Text(vm.location!.title)

                    Spacer()
                    Text(vm.location!.district + "/" + vm.location!.city)
                }
            }
            .sheet(isPresented: $vm.isSelectingLocation) {
                SelectLocationView(selectedLocation: $vm.location)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 30, style: .continuous).foregroundStyle(.thinMaterial))
            .onChange(of: vm.location) { newValue in
                if let newLocation = newValue {
                    // Do something when the location is updated
                    vm.title = vm.location?.title ?? ""
                }
            }
        }
    }

}
