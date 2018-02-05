//
//  MQBannerView.swift
//  Test
//
//  Created by 120v on 2018/1/29.
//  Copyright © 2018年 MQ. All rights reserved.
//

import UIKit

//MARK: - ZXBannerCell
class ZXBannerCell: UICollectionViewCell {
    
    static let ZXBannerCellID:String = "ZXBannerCell"
    
    
    //返回随机颜色
    var randomColor: UIColor {
        get {
            let red = CGFloat(arc4random()%256)/255.0
            let green = CGFloat(arc4random()%256)/255.0
            let blue = CGFloat(arc4random()%256)/255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        imgView.backgroundColor = UIColor.clear
        addSubview(imgView)
        
        imgView.backgroundColor = randomColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.frame = self.bounds
    }
    
    func loadData(_ urlStr:String) {
        //自己添加呈现图片的第三方库
        /*
        self.imgView.kf.setImage(with: URL.init(string: urlStr), placeholder: UIImage.Default.banner, options: nil, progressBlock: nil, completionHandler: nil)
        */
    }
    
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()
}

 typealias MQBannerCompletion = (_ bannerView: MQBannerView, _ itemIndex: Int,_ urlStr: String) -> ()
//MARK: - ZXBannerView
class MQBannerView: UIView {
    
    var block: MQBannerCompletion?
    private var timer: Timer?
    public var interval: TimeInterval = 5.0
    private var totalCount = 0
    private var sliderW: CGFloat = 0.0
    let sliderH: CGFloat = 2.0
    
    private func checkImageUrls(_ arr: Array<String>) {
        for url in arr {
            if !url.hasPrefix("http://") && !url.hasPrefix("https://") {
                print("image url format is error, please check it")
            }
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)

        backgroundColor = UIColor.clear
        
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI
    func setUI() {
        //
        addSubview(collView)
        
        //
        addSubview(sliderView)
        
        //
        sliderView.addSubview(slider)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setFrame()
    }
    
    func loadData(_ dataArr: Array<String>) {
        guard dataArr.count > 0 else {
            print("image urls count is 0")
            return
        }
        checkImageUrls(dataArr)
        
        imgUrls = dataArr
        
        setImgsCount()
        
        setFrame()
        
        collView.reloadData()
        
        if collView.contentOffset.x == 0, totalCount > 0 {
            collView.scrollToItem(at: IndexPath(row: totalCount/2 , section: 0), at: .left, animated: true)
        }
    }
    
    func setFrame() {
        sliderW = self.frame.width / CGFloat(imgUrls.count)
        //
        collView.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height - sliderH)
        //
        sliderView.frame = CGRect.init(x: 0, y: collView.frame.maxY, width: self.frame.width, height: sliderH)
        //
        slider.frame = CGRect.init(x: 0, y: 0, width: sliderW, height: sliderH)
    }
    
    //MARK: - 定时器
    private func setImgsCount() {
        if imgUrls.count <= 1 {
            totalCount = 1
            collView.isScrollEnabled = false
        }else{
            totalCount = imgUrls.count * 10
            collView.isScrollEnabled = true
            reset()
            setupTimer()
        }
    }
    
    private func setupTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(start), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .commonModes)
        }else{
            timer?.fireDate = Date()
        }
    }
    
    @objc private func start() {
        if totalCount == 0 {return}
        let itemIndex = currentIndex() + 1
        if itemIndex >= totalCount {
            collView.scrollToItem(at: IndexPath(row: totalCount / 2, section: 0), at: .left, animated: false)
            return
        }
        collView.scrollToItem(at: IndexPath(row: itemIndex, section: 0), at: .left, animated: true)
    }
    
    fileprivate func pauseTimer() {
        if timer != nil {
            timer?.fireDate = Date.distantFuture
        }
    }
    
    fileprivate func resumeTimer() {
        if timer != nil {
            timer?.fireDate = Date.init(timeIntervalSinceNow: interval)
        }
    }
    
    private func reset() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func currentIndex() -> Int {
        if collView.width == 0 || collView.height == 0 {
            return 0
        }
        return Int((collView.contentOffset.x) / bounds.size.width)
    }
    
    override public func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil {
            self.reset()
        } else {
            self.setupTimer()
        }
    }
    
    //MARK: - Lazy
    lazy var collView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let coll = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        coll.delegate = self
        coll.dataSource = self
        coll.isPagingEnabled = true
        coll.showsHorizontalScrollIndicator = false
        coll.indicatorStyle = .white
        coll.backgroundColor = UIColor.clear
        coll.register(ZXBannerCell.self, forCellWithReuseIdentifier: ZXBannerCell.ZXBannerCellID)
        return coll
    }()
    
    lazy var sliderView: UIView = {
        let slider = UIView()
        slider.backgroundColor = UIColor.lightGray
        return slider
    }()
    
    lazy var slider: UIView = {
        let slid = UIView()
        slid.backgroundColor = UIColor.blue
        return slid
    }()
    
    lazy var imgUrls: Array<String> = {
        let imgs = Array<String>.init()
        return imgs
    }()
}

//MARK: - UICollectionViewDataSource
extension MQBannerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ZXBannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: ZXBannerCell.ZXBannerCellID, for: indexPath) as! ZXBannerCell
        if imgUrls.count > 0 {
            let index = indexPath.item % imgUrls.count
            cell.loadData(imgUrls[index])
        }
        return cell
    }    
}

//MARK: - UICollectionViewDelegate
extension MQBannerView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item % imgUrls.count
        if imgUrls.count > 0 {
            let urlStr = imgUrls[index]
            if block != nil {
                block?(self, index, urlStr)
            }
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension MQBannerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.width, height: collectionView.height)
    }
}

//MARK: - UIScrollViewDelegate
extension MQBannerView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.setSliderIndex(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //resume timer
        self.resumeTimer()
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.pauseTimer()
    }
    
    func setSliderIndex(_ scrollView: UIScrollView) {
        if imgUrls.count == 0 { return }
        let cellIdx = currentIndex()
        let sliderIdx = getSliderIdx(index: cellIdx)        
        
        var offsetX = scrollView.contentOffset.x - (CGFloat(totalCount) * scrollView.frame.size.width) / 2
        let maxSwipeSize = CGFloat(imgUrls.count) * collView.frame.width
        var progress: CGFloat = 999
        if offsetX < 0 {
            if offsetX >= -scrollView.frame.size.width{
                offsetX = CGFloat(sliderIdx) * scrollView.frame.size.width
            }else if offsetX <= -maxSwipeSize{
                collView.scrollToItem(at: IndexPath.init(item: Int(totalCount/2), section: 0), at: .left, animated: false)
            }else{
                offsetX = maxSwipeSize + offsetX
            }
        }else if offsetX >= CGFloat(self.imgUrls.count) * scrollView.frame.size.width{
            collView.scrollToItem(at: IndexPath.init(item: Int(totalCount/2), section: 0), at: .left, animated: false)
            
        }
        progress = offsetX / scrollView.frame.size.width
        
        UIView.animate(withDuration: 0.05) {
            self.slider.x = CGFloat(sliderIdx) * self.sliderW
        }
    }
    
    func getSliderIdx(index: NSInteger) -> (Int) {
        return Int(index % imgUrls.count)
    }
}



