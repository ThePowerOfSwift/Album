//
//  ExtensionUtil.swift
//  Album
//
//  Created by Mister on 16/4/26.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit

extension NSDate{

    func PictureCreateTimeStr() -> String{
    
        if self.isToday() {return "今天"}
        if self.isYesterday() {return "昨天"}
        if self.isThisWeek() {return self.weekday().WeekStr()}
        if self.isThisYear(){return self.toString(format: DateFormat.Custom("M月d日"))}
        return self.toString(format: DateFormat.Custom("yyyy年M月d日"))
    }
}


private extension Int{

    func WeekStr() -> String{
    
        switch self {
        case 1:
            return "星期日"
        case 2:
            return "星期一"
        case 3:
            return "星期二"
        case 4:
            return "星期三"
        case 5:
            return "星期四"
        case 6:
            return "星期五"
        default:
            return "星期六"
        }
    }
}