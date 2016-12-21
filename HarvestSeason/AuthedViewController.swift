//
//  AuthedViewController.swift
//  HarvestSeason
//
//  Created by Nicholas Tian on 20/12/2016.
//  Copyright © 2016 nicktd. All rights reserved.
//

import UIKit
import SnapKit
import JTAppleCalendar

import HarvestAPI

class AuthedViewController: UIViewController {
    @IBOutlet weak var calendarView: JTAppleCalendarView!

    @IBOutlet weak var welcomeUser: UILabel!
    @IBOutlet weak var loggedInUser: UILabel!

    @IBAction func check(_ sender: Any) {
        guard !calendarView.selectedDates.isEmpty else {
            ErrorLogging.log(ErrorLogging.Error.ui(.warning(message: "Please select dates by tapping the date on calendar")))

            return
        }

        action.days(calendarView.selectedDates)
    }

    @IBAction func fill(_ sender: Any) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let style = NSMutableParagraphStyle()
        style.alignment = .center

        store.subscribe { [weak self] state in
            guard let `self` = self else { return }

            self.welcomeUser.attributedText = NSAttributedString(
                string: "Welcome,\n\(state.user.name)",
                attributes: [
                    NSForegroundColorAttributeName: UIColor.black,
                    NSParagraphStyleAttributeName: style,
                    ]
            )

            self.loggedInUser.text = "Logged in as \(state.user.name)"
        }

        store.subscribe { [weak self] state in
            guard let `self` = self else { return }

            self.calendarView.reloadData()
        }

        calendarView.dataSource = self
        calendarView.delegate = self

        calendarView.allowsMultipleSelection  = true
        calendarView.rangeSelectionWillBeUsed = true

        calendarView.cellInset = CGPoint(x: 0, y: 0) // default is (3,3)

        calendarView.registerCellViewXib(file: String(describing: CalendarDayCellView.self)) // Registering your cell is manditory
    }
}

typealias CellView = CalendarDayCellView

let white = UIColor(colorWithHexValue: 0xECEAED)
let darkPurple = UIColor(colorWithHexValue: 0x3A284C)
let dimPurple = UIColor(colorWithHexValue: 0x574865)

private let calendar = Calendar.current

extension AuthedViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func calendar(_ calendarView: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        let myCustomCell = cell as! CellView

        // Setup Cell text
        myCustomCell.dayLabel.text = cellState.text

        myCustomCell.icon.image = nil

        let dateString = Model.Day.dateFormatter.string(from: date)
        if let day = store.state.days[dateString] {
            let hours = day.hours()

            if hours >= 7.6 {
                myCustomCell.icon.image = #imageLiteral(resourceName: "dot-green")
            } else if hours > 0 {
                myCustomCell.icon.image = #imageLiteral(resourceName: "dot-gray")
            } else { // <= 0
                myCustomCell.icon.image = #imageLiteral(resourceName: "dot-empty")
            }
        }

        handleCellTextColor(view: cell, cellState: cellState)
        handleCellSelection(view: cell, cellState: cellState)
        handleCellSecetedView(view: cell, cellState: cellState)
    }

    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        handleCellSecetedView(view: cell, cellState: cellState)
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        handleCellSecetedView(view: cell, cellState: cellState)
    }

    func handleCellSecetedView(view: JTAppleDayCellView?, cellState: CellState) {
        guard let myCustomCell = view as? CellView  else {
            return
        }

        func show(_ isShowing: Bool = true, view: UIView) {
            view.isHidden = !isShowing
            view.backgroundColor = isShowing ? #colorLiteral(red: 0.9881840348, green: 0.7945293188, blue: 0.2451312542, alpha: 1) : nil
        }

        switch cellState.selectedPosition() {
        case .full:
            show(false, view: myCustomCell.leftSelected)
            show(true, view: myCustomCell.selectedView)
            show(false, view: myCustomCell.rightSelected)
        case .left:
            show(false, view: myCustomCell.leftSelected)
            show(true, view: myCustomCell.selectedView)
            show(true, view: myCustomCell.rightSelected)
        case .right:
            show(true, view: myCustomCell.leftSelected)
            show(true, view: myCustomCell.selectedView)
            show(false, view: myCustomCell.rightSelected)
        case .middle:
            show(true, view: myCustomCell.leftSelected)
            show(false, view: myCustomCell.selectedView)
            show(true, view: myCustomCell.rightSelected)
        case .none:
            show(false, view: myCustomCell.leftSelected)
            show(false, view: myCustomCell.selectedView)
            show(false, view: myCustomCell.rightSelected)
        }
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

    func configureCalendar(_ calendarView: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"

//        let startDate = formatter.date(from: "2016 02 01")! // You can use date generated from a formatter
        let endDate = Date()                                // You can also use dates created from this function
        let parameters = ConfigurationParameters(
            startDate: endDate,
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
