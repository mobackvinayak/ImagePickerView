//
//  ContentView.swift
//  ImagePickerViewDemo
//
//  Created by Vinayak Tudayekar on 13/09/21.
//

import SwiftUI
import Photos

struct ContentView: View {
    var body: some View {
        
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home : View {
    
    @State var selected : [SelectedImages] = []
    @State var show = false
    
    var body: some View{
        
        ZStack{
            
            Color.black.opacity(0.07).edgesIgnoringSafeArea(.all)
            VStack{
                
                
                if !self.selected.isEmpty{
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        HStack(spacing: 20){
                            
                            ForEach(self.selected,id: \.self){i in
                                ZStack{
                                Image(uiImage: i.image)
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.width/2.2, height: 150)
                                    .cornerRadius(15)
                               
                                Button(action: {
                                    
                                     self.selected.remove(at: i.id)
                                    
                                    
                                })
                                {
                                    Image("Cancel")
                                                    .resizable()
                                                    .edgesIgnoringSafeArea(.all)
                                        
                                }
                                //.background(Color.red)
                                .frame(width: 50, height: 50,alignment: .topTrailing)
                                //.clipShape(Capsule())
                                //.padding(.top)
                                
                           
                                }
                            }
                            Button(action: {
                                
                                // self.selected.removeAll()
                                
                                self.show.toggle()
                                
                            }) {
                                
                                Image("add-image")
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.width/2.2, height: 150)
                                    .cornerRadius(15)
                            }
                           
                            
                        }
                        
                        
                    }
                }
                
                Button(action: {
                    
                    // self.selected.removeAll()
                    
                    self.show.toggle()
                    
                }) {
                    
                    Text("Image Picker")
                        .foregroundColor(.white)
                        .padding(.vertical,10)
                        .frame(width: UIScreen.main.bounds.width / 3)
                }
                .background(Color.blue)
                .clipShape(Capsule())
                .padding(.top, 25)
            }
            
            if self.show{
                
                CustomPicker(selected: self.$selected, show: self.$show)
                
            }
        }
    }
}


struct CustomPicker : View {
    
    @Binding var selected : [SelectedImages]
    @State var grid : [[Images]] = []
    @Binding var show : Bool
    @State var disabled = false
    
    var body: some View{
        
        GeometryReader{_ in
            
            VStack{
                
                
                if !self.grid.isEmpty{
                    
                    HStack{
                        
                        Text("Pick a Image")
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.leading)
                    .padding(.top)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        
                        VStack(spacing: 20){
                            
                            ForEach(self.grid,id: \.self){i in
                                
                                HStack{
                                    
                                    ForEach(i,id: \.self){j in
                                        
                                        Card(data: j, selected: self.$selected)
                                    }
                                }
                            }
                        }
                        .padding(.bottom)
                    }
                    
                    Button(action: {
                        
                        self.show.toggle()
                        
                    }) {
                        
                        Text("Select")
                            .foregroundColor(.white)
                            .padding(.vertical,10)
                            .frame(width: UIScreen.main.bounds.width / 2)
                    }
                    .background(Color.red.opacity((self.selected.count != 0) ? 1 : 0.5))
                    .clipShape(Capsule())
                    .padding(.bottom)
                    .disabled((self.selected.count != 0) ? false : true)
                    
                }
                else{
                    
                    if self.disabled{
                        
                        Text("Enable Storage Access In Settings !!!")
                    }
                    if self.grid.count == 0{
                        
                        Indicator()
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height / 1.2)
            .background(Color.white)
            .cornerRadius(12)
        }
        .background(Color.black.opacity(0.1).edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            
                            self.show.toggle()
                            
                        })
        .onAppear {
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                if status == .authorized{
                    
                    self.getAllImages()
                    self.disabled = false
                }
                else{
                    
                    print("not authorized")
                    self.disabled = true
                }
            }
        }
    }
    
    func getAllImages(){
        
        let opt = PHFetchOptions()
        opt.includeHiddenAssets = false
        
        let req = PHAsset.fetchAssets(with: .image, options: .none)
        
        DispatchQueue.global(qos: .background).async {
            
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            
            // New Method For Generating Grid Without Refreshing....
            
            for i in stride(from: 0, to: req.count, by: 3){
                
                var iteration : [Images] = []
                
                for j in i..<i+3{
                    
                    if j < req.count{
                        
                        PHCachingImageManager.default().requestImage(for: req[j], targetSize: CGSize(width: 150, height: 150), contentMode: .default, options: options) { (image, _) in
                            
                            let data1 = Images(image: image!, selected: false, asset: req[j])
                            
                            iteration.append(data1)
                            
                        }
                    }
                }
                
                self.grid.append(iteration)
            }
            
        }
    }
}

struct Card : View {
    @State var data : Images
    @Binding var selected : [SelectedImages]
    
    @State var index:Int = 0

    var body: some View{
        
        ZStack{
            
            Image(uiImage: self.data.image)
                .resizable()
            
            if self.data.selected{
                
                ZStack{
                    
                    Color.black.opacity(0.5)
                    
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
            }
            
        }
        .frame(width: (UIScreen.main.bounds.width - 100) / 3, height: 60)
        .onTapGesture {
            
            if !self.data.selected{
                
                
                self.data.selected = true
                
                // Extracting Orginal Size of Image from Asset
                
                DispatchQueue.global(qos: .background).async {
                    
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    
                    // You can give your own Image size by replacing .init() to CGSize....
                    self.index = selected.count
                    print(index)
                    PHCachingImageManager.default().requestImage(for: self.data.asset, targetSize: .init(), contentMode: .default, options: options) { (image, _) in
                        self.selected.append(SelectedImages(asset: self.data.asset, image: image!, id:self.index))
                    }
                }
                
            }
            else{
                
                for i in 0..<self.selected.count{
                    
                    if self.selected[i].asset == self.data.asset{
                        
                        self.selected.remove(at: i)
                        self.data.selected = false
                        return
                    }
                    
                }
            }
        }
        
    }
}

struct Indicator : UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIActivityIndicatorView  {
        
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView:  UIActivityIndicatorView, context: Context) {
        
        
    }
}

struct Images: Hashable {
    
    var image : UIImage
    var selected : Bool
    var asset : PHAsset
}

struct SelectedImages: Hashable{
    
    var asset : PHAsset
    var image : UIImage
    var id: Int
}

