//
//  ViewController.swift
//  HarvestSeason
//
//  Created by Nicholas Tian on 19/12/2016.
//  Copyright © 2016 nicktd. All rights reserved.
//

import UIKit
import Eureka
import SnapKit

import HarvestAPI

class ViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var api: APIType?
        var user: Model.User?
        var projects: [Model.Project]?

        let companyRow = AccountRow() { row in
            row.title = "Company"
            row.placeholder = "company"
        }
        let userRow = EmailRow() { row in
            row.title = "Username"
            row.placeholder = "username"
        }
        let passwordRow = PasswordRow() { row in
            row.title = "Password"
            row.placeholder = "password"
        }

        let nameRow = LabelRow() {
            $0.title = "Not logged in"
        }.cellSetup { (cell, row) in
            cell.textLabel!.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }

        let taskPickerRow = AlertRow<Model.Task>() {
            $0.title = "0 tasks"
            $0.selectorTitle = "Pick a project to fill timetable"
            $0.options = []

            $0.hidden = Condition(booleanLiteral: true)
            }.cellSetup { (cell, row) in
                cell.textLabel!.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                }
        }

        taskPickerRow.displayValueFor = {
            return $0?.description
        }

        let projectPickerRow = AlertRow<Model.Project>() {
            $0.title = "0 projects"
            $0.selectorTitle = "Pick a project to fill timetable"
            $0.options = []

            $0.hidden = Condition(booleanLiteral: true)
        }.cellSetup { (cell, row) in
            cell.textLabel!.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }.onChange { row in
            guard let project = row.value else { return }

            let tasks = project.tasks

            taskPickerRow.hidden = Condition(booleanLiteral: false)
            taskPickerRow.options = tasks
            taskPickerRow.title = "\(tasks.count) tasks"
            taskPickerRow.updateCell()
            taskPickerRow.evaluateHidden()
        }

        projectPickerRow.displayValueFor = { (project: Model.Project?) -> String? in
            return project?.description
        }

        let fromDateRow = DateRow() {
            $0.title = "From"
            $0.value = Date()
        }

        let toDateRow = DateRow() {
            $0.title = "To"
            $0.value = Date()
        }

        let minimumHoursRow = DecimalRow() { row in
            row.title = "Minimum hours"
            row.placeholder = "hours per day"
        }

        let resultsSection = Section("Results")


        form =
            Section("Login")
            <<< companyRow
            <<< userRow
            <<< passwordRow

            +++ Section("")
            <<< ButtonRow() {
                $0.title = "Login"
            }.onCellSelection { (cell, row) in
                let auth = API.HTTPBasicAuth(username: userRow.value!,
                                             password: passwordRow.value!)
                api = API(company: companyRow.value!, auth: auth)

                api?.user { result in
                    user = result.value

                    if let user = user {
                        nameRow.title = "Welcome \(user.name)!"
                        nameRow.updateCell()

                        api?.projects { result in
                            projects = result.value

                            if let projects = projects {
                                projectPickerRow.hidden = Condition(booleanLiteral: false)
                                projectPickerRow.options = projects
                                projectPickerRow.title = "\(projects.count) projects"
                                projectPickerRow.updateCell()
                                projectPickerRow.evaluateHidden()
                            }
                        }
                    }
                }
            }

            +++ Section("")
            <<< nameRow

            +++ Section("Check")
            <<< minimumHoursRow
            <<< ButtonRow() {
                $0.title = "Check"
            }.onCellSelection { cell, row in
                let from = fromDateRow.value!
                let to = toDateRow.value!

                resultsSection.removeAll()

                api?.days(from: from, to: to) { result in
                    if let days = result.value {
                        for day in days {
                            resultsSection <<< LabelRow() {
                                $0.title = day.description(forMinimumHours: Float(minimumHoursRow.value ?? 7.6))
                            }
                        }
                    }
                }
            }
            <<< ButtonRow() {
                $0.title = "Remove all results"
            }.onCellSelection { _, _ in
                resultsSection.removeAll()
            }

            +++ Section("Date Range")
            <<< fromDateRow
            <<< toDateRow

            +++ Section("Fill")
            <<< projectPickerRow
            <<< taskPickerRow

            +++ resultsSection
    }
}

