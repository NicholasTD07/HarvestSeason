//
//  CalendarDayCell.swift
//  HarvestSeason
//
//  Created by Nicholas Tian on 20/12/2016.
//  Copyright © 2016 nicktd. All rights reserved.
//

import JTAppleCalendar

class CalendarDayCellView: JTAppleDayCellView {
    @IBOutlet weak var leftSelected: UIView!
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var selectedView: UIView!
    @IBOutlet weak var rightSelected: UIView!
    @IBOutlet weak var icon: UIImageView!
}
