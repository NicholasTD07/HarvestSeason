//
//  UnauthedViewController.swift
//  HarvestSeason
//
//  Created by Nicholas Tian on 19/12/2016.
//  Copyright © 2016 nicktd. All rights reserved.
//

import UIKit
import SnapKit
import JTAppleCalendar

import HarvestAPI

class UnauthedViewController: UIViewController {
    @IBOutlet weak var calendarView: JTAppleCalendarView!

    @IBOutlet weak var check: UIButton!
    @IBOutlet weak var fill: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        store.subscribe { [weak self] state in
            guard state != nil else { return }
            guard let `self` = self else { return }

            if let p = self.presentedViewController,
                let _ = p as? AuthedViewController {
                return
            }

            let auth = UIStoryboard(name: "main", bundle: nil).instantiateViewController(withIdentifier: "auth")

            self.dismiss(animated: true, completion: nil)
            self.present(auth, animated: false, completion: nil)
        }


        let style = NSMutableParagraphStyle()
        style.alignment = .center


        check.setAttributedTitle(
            NSAttributedString(
                string: "Check\nTimetable",
                attributes: [
                    NSForegroundColorAttributeName: UIColor.gray,
                    NSParagraphStyleAttributeName: style,
                    ]),
            for: .disabled)

        fill.setAttributedTitle(
            NSAttributedString(
                string: "Auto-fill\nTimetable",
                attributes: [
                    NSForegroundColorAttributeName: UIColor.gray,
                    NSParagraphStyleAttributeName: style,
                    ]),
            for: .disabled)


        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.registerCellViewXib(file: String(describing: CalendarDayCellView.self)) // Registering your cell is manditory

        calendarView.cellInset = CGPoint(x: 0, y: 0) // default is (3,3)
    }
}

private let textColorForThisMonth = UIColor(colorWithHexValue: 0xECEAED)
private let textColorForNotThisMonth = UIColor(colorWithHexValue: 0x574865)

extension UnauthedViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        let myCustomCell = cell as! CellView

        // Setup Cell text
        myCustomCell.dayLabel.text = cellState.text

        handleCellTextColor(view: cell, cellState: cellState)
        handleCellSelection(view: cell, cellState: cellState)
    }

    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }

    // Function to handle the text color of the calendar
    func handleCellTextColor(view: JTAppleDayCellView?, cellState: CellState) {

        guard let myCustomCell = view as? CellView  else {
            return
        }

        if cellState.isSelected {
            myCustomCell.dayLabel.textColor = darkPurple
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dayLabel.textColor = white
            } else {
                myCustomCell.dayLabel.textColor = dimPurple
            }
        }
    }

    // Function to handle the calendar selection
    func handleCellSelection(view: JTAppleDayCellView?, cellState: CellState) {
        guard let myCustomCell = view as? CellView  else {
            return
        }
        if cellState.isSelected {
            myCustomCell.selectedView.layer.cornerRadius =  25
            myCustomCell.selectedView.isHidden = false
        } else {
            myCustomCell.selectedView.isHidden = true
        }
    }

    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"

        let startDate = formatter.date(from: "2016 02 01")! // You can use date generated from a formatter
        let endDate = Date()                                // You can also use dates created from this function
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6, // Only 1, 2, 3, & 6 are allowed
            calendar: Calendar.current,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfGrid,
            firstDayOfWeek: .sunday)
        return parameters
    }
}

private extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
