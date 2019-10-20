//
//  ViewController.swift
//  FunFreedom
//
//  Created by choarkinphe on 09/16/2019.
//  Copyright (c) 2019 choarkinphe. All rights reserved.
//

import UIKit
import FunFreedom
import HandyJSON

class ViewController: UIViewController {
    var actions = [FunFreedom.ActionSheet]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        FunFreedom.networkManager.baseUrl = "https://api.61park.cn/"
        //        if let model = ResponseModel<[ModuleModel]>.deserialize(from: str) {
        //
        //            print(model)
        //        }
    }
    
    @IBAction func sheet(_ sender: Any) {
        
        FunFreedom.sheet.addActions(titles: ["A","B","C","E","F","G"]).resultActions(actions).selectType(.multi).multiHandler({ (actions) in
            self.actions = actions
        }).present()
        
    }
    @IBAction func request(_ sender: Any) {
        
        FunFreedom.NetworkKit.hz.urlString("t/service/cms/getTeachHomePage").isCache(true).cacheTimeOut(30).success { (baseModel) in
            
            print(baseModel.data ?? "null")
        }.request()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

struct TESTBaseModel: HandyJSON {
    var code: Int?
    var data: TESTModel?
    var msg: String?
    
}

struct TESTModel: HandyJSON {
    var description: String?
    var pageName: String?
    var modules: [ModuleModel]?
}

struct ModuleModel: HandyJSON {
    var templeteCode: String?
    var moduleName: String?
    var templeteData: [CMSDataConfig]?
}

struct CMSDataConfig: HandyJSON {
    var id: Int?
    var title: String?
    var linkPic: String?
    var linkUrl: String?
    var linkeType: Int?
}

let str = "{\"code\":\"0\",\"msg\":\"hffhkjsdhjfkh\",\"ext\":null,\"data\":[{\"templeteCode\":\"cmsTopBanner\",\"moduleName\":\"顶部banner\",\"templeteData\":[{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"61学院VIP直通车\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20190312145846402_632.jpg?x-oss-process=style/compress_nologo\",\"linkUrl\":\"http://m.61park.cn/teach/#/servicedict/index/613\",\"linkType\":1,\"linkData\":\"\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null},{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"万能工匠大中小班科学构建示范课展示视频\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20190313165957938_409.jpg?x-oss-process=style/compress_nologo\",\"linkUrl\":\"http://m.61park.cn/teach/#/servicedict/index/616\",\"linkType\":1,\"linkData\":\"\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null},{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"幼儿园区角环创设计\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20190305153055849_194.jpg\",\"linkUrl\":\"http://m.61park.cn/teach/#/servicedict/index/615\",\"linkType\":1,\"linkData\":\"\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null},{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"做好“收心计划”\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20190222134146555_909.jpg?x-oss-process=style/compress_nologo\",\"linkUrl\":\"http://m.61park.cn/teach/#/activity/activitycontent/1607\",\"linkType\":1,\"linkData\":\"\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null},{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"培训会精选\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20190408134848686_187.jpg?x-oss-process=style/compress_nologo\",\"linkUrl\":\"http://m.61park.cn/teach/#/servicedict/index/626\",\"linkType\":1,\"linkData\":\"\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null},{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"幼儿园开学游戏精选\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20190222101205386_276.jpg?x-oss-process=style/compress_nologo\",\"linkUrl\":\"http://m.61park.cn/teach/#/servicedict/index/610\",\"linkType\":1,\"linkData\":\"\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null}]},{\"templeteCode\":\"cmsFastGoTo\",\"moduleName\":\"快捷入口\",\"templeteData\":[{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"创新师训\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20180912102132060_578.png\",\"linkUrl\":\"http://m.61park.cn/teach/#/servicedict/index/467\",\"linkType\":1,\"linkData\":\"\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null},{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"每日一学\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20180918150623595_775.png\",\"linkUrl\":\"http://m.61park.cn/teach/#/servicedict/index/466\",\"linkType\":1,\"linkData\":\"\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null},{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"服务提报\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20180921182831717_147.png\",\"linkUrl\":\"teach61://ServiceReport\",\"linkType\":10,\"linkData\":\"\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null},{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"操作指引\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20190415093820951_909.png\",\"linkUrl\":\"http://m.61park.cn/teach/#/servicedict/index/627\",\"linkType\":1,\"linkData\":\"\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null}]},{\"templeteCode\":\"cmsCategory\",\"moduleName\":\"创新体育\",\"templeteData\":[{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"早操\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20181113103340335_362.png?x-oss-process=style/compress_nologo\",\"linkUrl\":\"基本体操|10|2\",\"linkType\":14,\"linkData\":\"{\\\"id\\\":\\\"10\\\",\\\"level\\\":2}\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null},{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"户外体育活动\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20181113103349777_210.png?x-oss-process=style/compress_nologo\",\"linkUrl\":\"自主游戏|11|2\",\"linkType\":14,\"linkData\":\"{\\\"id\\\":\\\"11\\\",\\\"level\\\":2}\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null},{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"体能教学\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20181113103402901_297.png?x-oss-process=style/compress_nologo\",\"linkUrl\":\"体能教学|13|2\",\"linkType\":14,\"linkData\":\"{\\\"id\\\":\\\"13\\\",\\\"level\\\":2}\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null},{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"运动会\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20181113103417563_926.png\",\"linkUrl\":\"运动会|63|2\",\"linkType\":14,\"linkData\":\"{\\\"id\\\":\\\"63\\\",\\\"level\\\":2}\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null},{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"活动音乐\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20181113103430275_712.png\",\"linkUrl\":\"活动音乐|22|2\",\"linkType\":14,\"linkData\":\"{\\\"id\\\":\\\"22\\\",\\\"level\\\":2}\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null}]},{\"templeteCode\":\"cmsCategory\",\"moduleName\":\"创新建构\",\"templeteData\":[{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"区角环创\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20181112101922177_553.png\",\"linkUrl\":\"环境布置|4|2\",\"linkType\":14,\"linkData\":\"{\\\"id\\\":\\\"4\\\",\\\"level\\\":2}\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null},{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"创造力课\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20181112102041555_600.png\",\"linkUrl\":\"教案|61|2\",\"linkType\":14,\"linkData\":\"{\\\"id\\\":\\\"61\\\",\\\"level\\\":2}\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null},{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"亲子活动\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20181112102148251_985.png\",\"linkUrl\":\"亲子活动|16|2\",\"linkType\":14,\"linkData\":\"{\\\"id\\\":\\\"16\\\",\\\"level\\\":2}\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null}]},{\"templeteCode\":\"cmsCategory\",\"moduleName\":\"家园共育\",\"templeteData\":[{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"免费素材\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20181113105455606_712.png\",\"linkUrl\":\"电子素材|85|2\",\"linkType\":14,\"linkData\":\"{\\\"id\\\":\\\"85\\\",\\\"level\\\":2}\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null},{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"转给家长\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20181113105527301_0.png\",\"linkUrl\":\"转给家长|15|2\",\"linkType\":14,\"linkData\":\"{\\\"id\\\":\\\"15\\\",\\\"level\\\":2}\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null},{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"节日通知\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20181113105538012_864.png\",\"linkUrl\":\"节日通知|104|2\",\"linkType\":14,\"linkData\":\"{\\\"id\\\":\\\"104\\\",\\\"level\\\":2}\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null}]},{\"templeteCode\":\"cmsExpertOpinion\",\"moduleName\":\"专家观点\",\"templeteData\":[{\"id\":98,\"num\":null,\"bigPictureUrl\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/teach/20181224181210373_37.jpg?x-oss-process=style/compress_nologo\",\"name\":\"张怡筠\",\"subhead\":null,\"description\":null,\"status\":null,\"viewNumber\":null,\"delFlag\":null,\"headPictureUrl\":null,\"content\":null,\"contentUpdateTime\":null,\"createDate\":null,\"createBy\":null,\"updateDate\":null,\"updateBy\":null,\"contentTitle\":null,\"popularity\":null,\"trainerCourseSeriesList\":null}]},{\"templeteCode\":\"cmsGoldTeacher\",\"moduleName\":\"幼教专家\",\"templeteData\":{\"pageIndex\":0,\"pageSize\":3,\"total\":29,\"pageCount\":10,\"offset\":0,\"sort\":\"id\",\"order\":\"asc\",\"esPageIndex\":1,\"rows\":[{\"id\":1,\"num\":null,\"bigPictureUrl\":null,\"name\":\"61学院官方\",\"subhead\":\"线上师训/教研平台\",\"description\":\"致力于提高幼师教研能力\",\"status\":null,\"viewNumber\":null,\"delFlag\":null,\"headPictureUrl\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20171201175242899_862.png?x-oss-process=style/compress_nologo\",\"content\":null,\"contentUpdateTime\":null,\"createDate\":null,\"createBy\":null,\"updateDate\":null,\"updateBy\":null,\"contentTitle\":\"【万能工匠】体育游戏大学问，园所老师们速来看！\",\"popularity\":\"1463.9万\",\"trainerCourseSeriesList\":null},{\"id\":15,\"num\":null,\"bigPictureUrl\":null,\"name\":\"陈冬华\",\"subhead\":\"幼儿体能教育泰斗\",\"description\":\"3-6岁儿童学习与发展指南，悬垂、远足、幼儿区域活动等项目科研成果转换实施\",\"status\":null,\"viewNumber\":null,\"delFlag\":null,\"headPictureUrl\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/teach/20171024174941739_499.jpg?x-oss-process=style/compress_nologo\",\"content\":null,\"contentUpdateTime\":null,\"createDate\":null,\"createBy\":null,\"updateDate\":null,\"updateBy\":null,\"contentTitle\":\"体操教学对幼教的重要性\",\"popularity\":\"21.1万\",\"trainerCourseSeriesList\":null},{\"id\":59,\"num\":null,\"bigPictureUrl\":null,\"name\":\"宁科\",\"subhead\":\"陕西学前师范学院体育系副教授\",\"description\":\"北京体育大学体育教育训练学博士研究生，儿童早期动作发展与体质健康促进研究方向\",\"status\":null,\"viewNumber\":null,\"delFlag\":null,\"headPictureUrl\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/teach/20180309203418365_641.jpg\",\"content\":null,\"contentUpdateTime\":null,\"createDate\":null,\"createBy\":null,\"updateDate\":null,\"updateBy\":null,\"contentTitle\":\"幼儿到底需要多少身体活动？\",\"popularity\":\"6.7万\",\"trainerCourseSeriesList\":null}]}},{\"templeteCode\":\"cmsMiddleBannerOne\",\"moduleName\":\"中部bannerOne\\r\\n\",\"templeteData\":[{\"id\":null,\"moduleId\":null,\"locationId\":null,\"title\":\"名园案例\",\"linkPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20180606150715435_874.jpg\",\"linkUrl\":\"http://m.61park.cn/teach/#/servicedict/index/464\",\"linkType\":1,\"linkData\":\"\",\"effectiveStartTime\":null,\"effectiveEndTime\":null,\"createDate\":\"2019-09-15 19:37:21\",\"updateDate\":\"2019-09-15 19:37:21\",\"locationIdArr\":null,\"limitNum\":null,\"selected\":0,\"selectedPicUrl\":null}]},{\"templeteCode\":\"cmsNewRecommend\",\"moduleName\":\"最新推荐\",\"templeteData\":{\"pageIndex\":0,\"pageSize\":10,\"total\":1439,\"pageCount\":144,\"offset\":0,\"sort\":\"id\",\"order\":\"asc\",\"esPageIndex\":1,\"rows\":[{\"id\":2984,\"code\":null,\"title\":\"【万能工匠】体育游戏大学问，园所老师们速来看！\",\"level1CateId\":null,\"level2CateId\":null,\"adaptAge\":null,\"status\":0,\"coverImg\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/banner/20190912154959573_782.jpg\",\"content\":null,\"intro\":null,\"contentType\":0,\"commentNum\":0,\"viewNum\":0,\"praiseNum\":0,\"praiseTotal\":null,\"shareNum\":0,\"authorId\":null,\"authorMobile\":null,\"authorName\":\"61学院官方\",\"authorPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20171201175242899_862.png?x-oss-process=style/compress_nologo\",\"teachActivityId\":null,\"activityType\":null,\"isFree\":0,\"isFine\":0,\"isNew\":0,\"keyWords\":null,\"keyWordArray\":null,\"delFlag\":\"0\",\"createBy\":null,\"createDate\":\"2019-09-12 16:05:28\",\"updateBy\":null,\"updateDate\":null,\"rejectBy\":null,\"rejectDate\":null,\"rejectCause\":null,\"sort\":0,\"sortTime\":\"2019-09-15 19:37:21\",\"level1CateName\":null,\"isCollect\":null,\"tags\":null,\"isPraised\":null,\"contentItemList\":null,\"attachments\":null,\"showDate\":\"09-12 16:05\",\"activityName\":null,\"activityPic\":null,\"praiseTimes\":null,\"newTag\":null,\"praiseNumDsc\":null,\"originalHeight\":null,\"originalWidth\":null,\"playTotalNum\":null,\"focusNum\":0,\"putawayStatus\":null,\"isSourceCanExport\":null,\"isMember\":0,\"isTag\":0,\"memberGroupId\":null,\"isView\":1,\"viewCode\":1},{\"id\":2983,\"code\":null,\"title\":\"【精彩案例】快接住！中秋教案豪华大礼包来啦！\",\"level1CateId\":null,\"level2CateId\":null,\"adaptAge\":null,\"status\":0,\"coverImg\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/banner/20190911161327947_953.png\",\"content\":null,\"intro\":null,\"contentType\":0,\"commentNum\":0,\"viewNum\":0,\"praiseNum\":0,\"praiseTotal\":null,\"shareNum\":0,\"authorId\":null,\"authorMobile\":null,\"authorName\":\"61学院官方\",\"authorPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20171201175242899_862.png?x-oss-process=style/compress_nologo\",\"teachActivityId\":null,\"activityType\":null,\"isFree\":0,\"isFine\":0,\"isNew\":0,\"keyWords\":null,\"keyWordArray\":null,\"delFlag\":\"0\",\"createBy\":null,\"createDate\":\"2019-09-11 16:25:15\",\"updateBy\":null,\"updateDate\":null,\"rejectBy\":null,\"rejectDate\":null,\"rejectCause\":null,\"sort\":0,\"sortTime\":\"2019-09-15 19:37:21\",\"level1CateName\":null,\"isCollect\":null,\"tags\":null,\"isPraised\":null,\"contentItemList\":null,\"attachments\":null,\"showDate\":\"09-11 16:25\",\"activityName\":null,\"activityPic\":null,\"praiseTimes\":null,\"newTag\":null,\"praiseNumDsc\":null,\"originalHeight\":null,\"originalWidth\":null,\"playTotalNum\":null,\"focusNum\":0,\"putawayStatus\":null,\"isSourceCanExport\":null,\"isMember\":0,\"isTag\":0,\"memberGroupId\":null,\"isView\":1,\"viewCode\":1},{\"id\":2982,\"code\":null,\"title\":\"教师节，如阳光一般灿烂的日子！\",\"level1CateId\":null,\"level2CateId\":null,\"adaptAge\":null,\"status\":0,\"coverImg\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/banner/20190910173931403_288.jpg\",\"content\":null,\"intro\":null,\"contentType\":0,\"commentNum\":0,\"viewNum\":0,\"praiseNum\":0,\"praiseTotal\":null,\"shareNum\":0,\"authorId\":null,\"authorMobile\":null,\"authorName\":\"61学院官方\",\"authorPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20171201175242899_862.png?x-oss-process=style/compress_nologo\",\"teachActivityId\":null,\"activityType\":null,\"isFree\":0,\"isFine\":0,\"isNew\":0,\"keyWords\":null,\"keyWordArray\":null,\"delFlag\":\"0\",\"createBy\":null,\"createDate\":\"2019-09-10 17:41:42\",\"updateBy\":null,\"updateDate\":null,\"rejectBy\":null,\"rejectDate\":null,\"rejectCause\":null,\"sort\":0,\"sortTime\":\"2019-09-15 19:37:21\",\"level1CateName\":null,\"isCollect\":null,\"tags\":null,\"isPraised\":null,\"contentItemList\":null,\"attachments\":null,\"showDate\":\"09-10 17:41\",\"activityName\":null,\"activityPic\":null,\"praiseTimes\":null,\"newTag\":null,\"praiseNumDsc\":null,\"originalHeight\":null,\"originalWidth\":null,\"playTotalNum\":null,\"focusNum\":0,\"putawayStatus\":null,\"isSourceCanExport\":null,\"isMember\":0,\"isTag\":0,\"memberGroupId\":null,\"isView\":1,\"viewCode\":1},{\"id\":2981,\"code\":null,\"title\":\"AR智慧教育产品“贝玛影见”首次亮相于世界物联网峰会！\",\"level1CateId\":null,\"level2CateId\":null,\"adaptAge\":null,\"status\":0,\"coverImg\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/banner/20190909113731115_847.jpg\",\"content\":null,\"intro\":null,\"contentType\":0,\"commentNum\":0,\"viewNum\":0,\"praiseNum\":0,\"praiseTotal\":null,\"shareNum\":0,\"authorId\":null,\"authorMobile\":null,\"authorName\":\"61学院官方\",\"authorPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20171201175242899_862.png?x-oss-process=style/compress_nologo\",\"teachActivityId\":null,\"activityType\":null,\"isFree\":0,\"isFine\":0,\"isNew\":0,\"keyWords\":null,\"keyWordArray\":null,\"delFlag\":\"0\",\"createBy\":null,\"createDate\":\"2019-09-09 11:37:43\",\"updateBy\":null,\"updateDate\":null,\"rejectBy\":null,\"rejectDate\":null,\"rejectCause\":null,\"sort\":0,\"sortTime\":\"2019-09-15 19:37:21\",\"level1CateName\":null,\"isCollect\":null,\"tags\":null,\"isPraised\":null,\"contentItemList\":null,\"attachments\":null,\"showDate\":\"09-09 11:37\",\"activityName\":null,\"activityPic\":null,\"praiseTimes\":null,\"newTag\":null,\"praiseNumDsc\":null,\"originalHeight\":null,\"originalWidth\":null,\"playTotalNum\":null,\"focusNum\":0,\"putawayStatus\":null,\"isSourceCanExport\":null,\"isMember\":0,\"isTag\":0,\"memberGroupId\":null,\"isView\":1,\"viewCode\":1},{\"id\":2980,\"code\":null,\"title\":\"【精彩案例】您的教师节攻略来啦，请注意查收~\",\"level1CateId\":null,\"level2CateId\":null,\"adaptAge\":null,\"status\":0,\"coverImg\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/banner/20190907100539140_130.jpg\",\"content\":null,\"intro\":null,\"contentType\":0,\"commentNum\":0,\"viewNum\":0,\"praiseNum\":0,\"praiseTotal\":null,\"shareNum\":0,\"authorId\":null,\"authorMobile\":null,\"authorName\":\"61学院官方\",\"authorPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20171201175242899_862.png?x-oss-process=style/compress_nologo\",\"teachActivityId\":null,\"activityType\":null,\"isFree\":0,\"isFine\":0,\"isNew\":0,\"keyWords\":null,\"keyWordArray\":null,\"delFlag\":\"0\",\"createBy\":null,\"createDate\":\"2019-09-07 10:06:49\",\"updateBy\":null,\"updateDate\":null,\"rejectBy\":null,\"rejectDate\":null,\"rejectCause\":null,\"sort\":0,\"sortTime\":\"2019-09-15 19:37:21\",\"level1CateName\":null,\"isCollect\":null,\"tags\":null,\"isPraised\":null,\"contentItemList\":null,\"attachments\":null,\"showDate\":\"09-07 10:06\",\"activityName\":null,\"activityPic\":null,\"praiseTimes\":null,\"newTag\":null,\"praiseNumDsc\":null,\"originalHeight\":null,\"originalWidth\":null,\"playTotalNum\":null,\"focusNum\":0,\"putawayStatus\":null,\"isSourceCanExport\":null,\"isMember\":0,\"isTag\":0,\"memberGroupId\":null,\"isView\":1,\"viewCode\":1},{\"id\":2979,\"code\":null,\"title\":\"【师训手记】关于师训不得不说的二三事！\",\"level1CateId\":null,\"level2CateId\":null,\"adaptAge\":null,\"status\":0,\"coverImg\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/banner/20190905160121077_783.jpg\",\"content\":null,\"intro\":null,\"contentType\":0,\"commentNum\":0,\"viewNum\":0,\"praiseNum\":0,\"praiseTotal\":null,\"shareNum\":0,\"authorId\":null,\"authorMobile\":null,\"authorName\":\"61学院官方\",\"authorPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20171201175242899_862.png?x-oss-process=style/compress_nologo\",\"teachActivityId\":null,\"activityType\":null,\"isFree\":0,\"isFine\":0,\"isNew\":0,\"keyWords\":null,\"keyWordArray\":null,\"delFlag\":\"0\",\"createBy\":null,\"createDate\":\"2019-09-05 16:28:40\",\"updateBy\":null,\"updateDate\":null,\"rejectBy\":null,\"rejectDate\":null,\"rejectCause\":null,\"sort\":0,\"sortTime\":\"2019-09-15 19:37:21\",\"level1CateName\":null,\"isCollect\":null,\"tags\":null,\"isPraised\":null,\"contentItemList\":null,\"attachments\":null,\"showDate\":\"09-05 16:28\",\"activityName\":null,\"activityPic\":null,\"praiseTimes\":null,\"newTag\":null,\"praiseNumDsc\":null,\"originalHeight\":null,\"originalWidth\":null,\"playTotalNum\":null,\"focusNum\":0,\"putawayStatus\":null,\"isSourceCanExport\":null,\"isMember\":0,\"isTag\":0,\"memberGroupId\":null,\"isView\":1,\"viewCode\":1},{\"id\":2978,\"code\":null,\"title\":\"【家园共育】筑梦安全，家长是孩子最好的老师！\",\"level1CateId\":null,\"level2CateId\":null,\"adaptAge\":null,\"status\":0,\"coverImg\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/banner/20190902101415443_792.jpg\",\"content\":null,\"intro\":null,\"contentType\":0,\"commentNum\":0,\"viewNum\":0,\"praiseNum\":0,\"praiseTotal\":null,\"shareNum\":0,\"authorId\":null,\"authorMobile\":null,\"authorName\":\"61学院官方\",\"authorPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20171201175242899_862.png?x-oss-process=style/compress_nologo\",\"teachActivityId\":null,\"activityType\":null,\"isFree\":0,\"isFine\":0,\"isNew\":0,\"keyWords\":null,\"keyWordArray\":null,\"delFlag\":\"0\",\"createBy\":null,\"createDate\":\"2019-09-02 10:22:56\",\"updateBy\":null,\"updateDate\":null,\"rejectBy\":null,\"rejectDate\":null,\"rejectCause\":null,\"sort\":0,\"sortTime\":\"2019-09-15 19:37:21\",\"level1CateName\":null,\"isCollect\":null,\"tags\":null,\"isPraised\":null,\"contentItemList\":null,\"attachments\":null,\"showDate\":\"09-02 10:22\",\"activityName\":null,\"activityPic\":null,\"praiseTimes\":null,\"newTag\":null,\"praiseNumDsc\":null,\"originalHeight\":null,\"originalWidth\":null,\"playTotalNum\":null,\"focusNum\":0,\"putawayStatus\":null,\"isSourceCanExport\":null,\"isMember\":0,\"isTag\":0,\"memberGroupId\":null,\"isView\":1,\"viewCode\":1},{\"id\":2977,\"code\":null,\"title\":\"【万能工匠】有朋自远方来，携手共发展 ——唐山幼教访学团参观贝玛教育共同碰撞创新教育理念\",\"level1CateId\":null,\"level2CateId\":null,\"adaptAge\":null,\"status\":0,\"coverImg\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/banner/20190830091735757_768.png\",\"content\":null,\"intro\":null,\"contentType\":0,\"commentNum\":0,\"viewNum\":0,\"praiseNum\":0,\"praiseTotal\":null,\"shareNum\":0,\"authorId\":null,\"authorMobile\":null,\"authorName\":\"61学院官方\",\"authorPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20171201175242899_862.png?x-oss-process=style/compress_nologo\",\"teachActivityId\":null,\"activityType\":null,\"isFree\":0,\"isFine\":0,\"isNew\":0,\"keyWords\":null,\"keyWordArray\":null,\"delFlag\":\"0\",\"createBy\":null,\"createDate\":\"2019-08-30 09:25:02\",\"updateBy\":null,\"updateDate\":null,\"rejectBy\":null,\"rejectDate\":null,\"rejectCause\":null,\"sort\":0,\"sortTime\":\"2019-09-15 19:37:21\",\"level1CateName\":null,\"isCollect\":null,\"tags\":null,\"isPraised\":null,\"contentItemList\":null,\"attachments\":null,\"showDate\":\"08-30 09:25\",\"activityName\":null,\"activityPic\":null,\"praiseTimes\":null,\"newTag\":null,\"praiseNumDsc\":null,\"originalHeight\":null,\"originalWidth\":null,\"playTotalNum\":null,\"focusNum\":0,\"putawayStatus\":null,\"isSourceCanExport\":null,\"isMember\":0,\"isTag\":0,\"memberGroupId\":null,\"isView\":1,\"viewCode\":1},{\"id\":2976,\"code\":null,\"title\":\"【万能工匠】新学期，幼儿园大中小班一日常规！\",\"level1CateId\":null,\"level2CateId\":null,\"adaptAge\":null,\"status\":0,\"coverImg\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/banner/20190829095423432_862.jpg\",\"content\":null,\"intro\":null,\"contentType\":0,\"commentNum\":0,\"viewNum\":0,\"praiseNum\":0,\"praiseTotal\":null,\"shareNum\":0,\"authorId\":null,\"authorMobile\":null,\"authorName\":\"61学院官方\",\"authorPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20171201175242899_862.png?x-oss-process=style/compress_nologo\",\"teachActivityId\":null,\"activityType\":null,\"isFree\":0,\"isFine\":0,\"isNew\":0,\"keyWords\":null,\"keyWordArray\":null,\"delFlag\":\"0\",\"createBy\":null,\"createDate\":\"2019-08-29 09:59:54\",\"updateBy\":null,\"updateDate\":null,\"rejectBy\":null,\"rejectDate\":null,\"rejectCause\":null,\"sort\":0,\"sortTime\":\"2019-09-15 19:37:21\",\"level1CateName\":null,\"isCollect\":null,\"tags\":null,\"isPraised\":null,\"contentItemList\":null,\"attachments\":null,\"showDate\":\"08-29 09:59\",\"activityName\":null,\"activityPic\":null,\"praiseTimes\":null,\"newTag\":null,\"praiseNumDsc\":null,\"originalHeight\":null,\"originalWidth\":null,\"playTotalNum\":null,\"focusNum\":0,\"putawayStatus\":null,\"isSourceCanExport\":null,\"isMember\":0,\"isTag\":0,\"memberGroupId\":null,\"isView\":1,\"viewCode\":1},{\"id\":2966,\"code\":null,\"title\":\"【区角系列】最好的教育，藏在细节里！\",\"level1CateId\":null,\"level2CateId\":null,\"adaptAge\":null,\"status\":0,\"coverImg\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/banner/20190828095918089_419.jpg\",\"content\":null,\"intro\":null,\"contentType\":0,\"commentNum\":0,\"viewNum\":0,\"praiseNum\":0,\"praiseTotal\":null,\"shareNum\":0,\"authorId\":null,\"authorMobile\":null,\"authorName\":\"61学院官方\",\"authorPic\":\"http://park61.oss-cn-zhangjiakou.aliyuncs.com/activity/20171201175242899_862.png?x-oss-process=style/compress_nologo\",\"teachActivityId\":null,\"activityType\":null,\"isFree\":0,\"isFine\":0,\"isNew\":0,\"keyWords\":null,\"keyWordArray\":null,\"delFlag\":\"0\",\"createBy\":null,\"createDate\":\"2019-08-28 10:35:55\",\"updateBy\":null,\"updateDate\":null,\"rejectBy\":null,\"rejectDate\":null,\"rejectCause\":null,\"sort\":0,\"sortTime\":\"2019-09-15 19:37:21\",\"level1CateName\":null,\"isCollect\":null,\"tags\":null,\"isPraised\":null,\"contentItemList\":null,\"attachments\":null,\"showDate\":\"08-28 10:35\",\"activityName\":null,\"activityPic\":null,\"praiseTimes\":null,\"newTag\":null,\"praiseNumDsc\":null,\"originalHeight\":null,\"originalWidth\":null,\"playTotalNum\":null,\"focusNum\":0,\"putawayStatus\":null,\"isSourceCanExport\":null,\"isMember\":0,\"isTag\":0,\"memberGroupId\":null,\"isView\":1,\"viewCode\":1}]}}]}"


