//
//  ViewController.swift
//  MQBannerView
//
//  Created by 120v on 2018/2/2.
//  Copyright © 2018年 MQ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var bannerView: MQBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBannerView()
    }
    
    func addBannerView() {
        
        let imgUrls = ["http://pic.qyer.com/public/mobileapp/homebanner/2017/10/09/15075430688640/w800",
                       "http://pic.qyer.com/ra/img/15064476767054",
//                       "http://pic.qyer.com/public/mobileapp/homebanner/2017/10/09/15075432049166/w800",
//                       "http://pic.qyer.com/public/mobileapp/homebanner/2017/10/10/15076301267252/w800"
        ]
        
        bannerView = MQBannerView.init(frame: CGRect.init(x: 0, y: 200, width: UIScreen.main.bounds.width, height: 146.0))
        view.addSubview(bannerView)
        bannerView.loadData(imgUrls)
        bannerView.block = {(view: MQBannerView, index: Int, urlStr: String) in
            print(index,urlStr)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

