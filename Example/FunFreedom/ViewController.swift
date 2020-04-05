//
//  ViewController.swift
//  FunFreedom
//
//  Created by choarkinphe on 09/16/2019.
//  Copyright (c) 2019 choarkinphe. All rights reserved.
//

import UIKit
import FunFreedom
import SwiftyJSON
import CoreLocation
import SnapKit
//typealias FunNetworkKit = FunFreedom.NetworkKit
class ViewController: UIViewController {
    var actions = [FunFreedom.Sheet.Action]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let v = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 66))
//        v.backgroundColor = .red
//        fun.navigationBar = v
        FunFreedom.networkManager.errorHUD = true
        FunFreedom.networkManager.baseUrl = "https://api.61park.cn/"
        //        if let model = ResponseModel<[ModuleModel]>.deserialize(from: str) {
        //
        //            print(model)
        //        }
        FunFreedom.DownloadManager.default.maxDownloadCount = 3
//        FunFreedom.alert
//            .message(message: "message")
//            .title(title: "title")
//            .addAction(title: "cancel", style: .cancel)
//            .addAction(title: "OK", style: .default) { (action) in
//
//            }
//            .show()
        
        let testView = UIView()
        testView.backgroundColor = .red
        view.addSubview(testView)
        
        
        testView.snp.makeConstraints { (make) in
            make.left.idiom(.phone)?.equalTo(10)
            make.top.equalTo(10)
            make.width.height.equalTo(100)
        }
        
    }
    
    @IBAction func sheet(_ sender: Any) {
        
        FunFreedom.sheet.addActions(["Music0","Music1","Music2","Music3","Music4","Music5","Music6","Music7"]).resultActions(actions).selectType(.multi)
//            .handler({ (result) in
//
//            print(result)
//        })
            .multiHandler({ (result) in
            result.forEach { (action) in
                let url = "http://192.168.1.17/files/Music/music\(action.index).mp3"
                guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return }
                FunFreedom.netwokKit.urlString(url).destinationURL(URL(fileURLWithPath: path)).method(.get).downloadResponder?.response(nil)
            }

            self.actions = result
        })
            .present()
        
//        FunFreedom.datePicker.present()
//        FunFreedom.toast.message("Loading").showActivity()
        
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        
//        present(TestViewController(), animated: true, completion: nil)
        
//        FunFreedom.cache.cache(key: "a", data: "b")
//        FunFreedom.cache.totalSize
        // 快速获取当前定位信息
//        FunFreedom.Location.default.updatingLocation { (location) in
//            print(location)
//        }
        
        let location = CLLocation.init(latitude: 30.51667, longitude: 114.31667)
        
        
//        FunFreedom.Location.default.reverseGeocodeLocation(location)
        FunFreedom.Location.default.reverseGeocodeLocation(location) { (result) in
            if let address = result.address {
                print(address)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        FunFreedom.toast.dismiss()
    }
    @IBAction func download(_ sender: UIButton) {
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return }
        FunFreedom.NetworkKit.hz.urlString("http://192.168.1.17/files/PollChief_alameda_Token.zip").destinationURL(URL(fileURLWithPath: path)).method(.get).downloadResponder?.progressHandler({ (progress) in
            print(progress)
        }).response({ (fileUrl, error) in

        })
        
//        FunFreedom.NetworkKit.hz.urlString("http://192.168.1.17/files/PollChief_alameda_Token.zip").method(.get).build(.download).progress { (progress) in
//            print(progress)
//        }.response { (response) in
//            print(response.fileURL)
//        }
    }
    @IBAction func upload(_ sender: UIButton) {
        if let image = UIImage.init(named: "timg-2"), let imageData = image.jpegData(compressionQuality: 1) {
        
            FunNetworkKit.hz.urlString("http://test.xoinstein.com/upload.php").body { (formatData) in
                //            formatData.append(UIImage.jpegData(image!), withName: "file", fileName: "timg-2.jpeg", mimeType: "image/jpeg")
                formatData.append(imageData, withName: "file", fileName: "timg-2.jpeg", mimeType: "image/jpeg")
            }.build(.upload).progress { (progress) in
                print(progress)
            }.response({ (response) in
                print(response.data)
            })

            


        }
    }
    @IBAction func request(_ sender: Any) {
        
        FunFreedom.NetworkKit.hz.urlString("t/service/cms/getTeachHomePage").params(["test":"test"]).isCache(true).cacheTimeOut(30).build(.default).response({ (response) in
            if let data = response.data {
                if let json = try? JSON(data: data) {
                    
                    print(json.dictionaryObject?.keys)
                }
            }
        })

//            .request(BBModel.self, { (result) in
//
//            print(result.data)
//
//        })
//            .success { (baseModel) in
//
//            print(baseModel.data ?? "null")
//        }.request()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

struct BBModel {
    
//    var success: Bool {get set}
    var code: String?
    var msg: String?
    var data: String?

//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        let string = try container.decode(String.self)
////        data = T.deserialize(from: <#T##[String : Any]?#>)
//        print(string)
//    }
    
}

//struct TESTBaseModel: HandyJSON {
//    var code: Int?
//    var data: TESTModel?
//    var msg: String?
//
//}
//
//struct TESTModel: HandyJSON {
//    var description: String?
//    var pageName: String?
//    var modules: [ModuleModel]?
//}
//
//struct ModuleModel: HandyJSON {
//    var templeteCode: String?
//    var moduleName: String?
//    var templeteData: [CMSDataConfig]?
//}
//
//struct CMSDataConfig: HandyJSON {
//    var id: Int?
//    var title: String?
//    var linkPic: String?
//    var linkUrl: String?
//    var linkeType: Int?
//}

extension ConstraintMakerExtendable {
//    public var a: ConstraintMakerExtendable? {
//        left.equalTo(<#T##other: ConstraintRelatableTarget##ConstraintRelatableTarget#>)
//
//        return self
//    }
    
    // 作用屏幕方向
    public func orientation(_ orientation: UIInterfaceOrientation) -> ConstraintMakerExtendable? {
        
        if orientation == UIApplication.shared.statusBarOrientation {
            return self
        }
        
        return nil
    }
    
    // 作用设备类型
    public func idiom(_ idiom: UIUserInterfaceIdiom) -> ConstraintMakerExtendable? {
        
        if idiom == UIDevice.current.userInterfaceIdiom {
            return self
        }
        return nil
    }
    
}
