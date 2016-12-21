//
//  State.swift
//  HarvestSeason
//
//  Created by Nicholas Tian on 20/12/2016.
//  Copyright © 2016 nicktd. All rights reserved.
//

import Foundation
import Result

import HarvestAPI

let store = Store<State>.init(with: nil)
let action = Action.init(with: store.update)

struct State {
    let api: APIType
    let user: Model.User
    let projects: [Model.Project]
    let days: [String: Model.Day]

    init(api: APIType, user: Model.User, projects: [Model.Project], days: [String: Model.Day]) {
        self.api = api
        self.user = user
        self.projects = projects
        self.days = days
    }

    func new(api: APIType? = nil,
             user: Model.User? = nil,
             projects: [Model.Project]? = nil,
             days: [String: Model.Day]? = nil
    ) -> State {
        return State(
            api: api ?? self.api,
            user: user ?? self.user,
            projects: projects ?? self.projects,
            days: days ?? self.days
        )
    }

    func newDay(at date: Date, day: Model.Day) -> State {
        var days = self.days
        
        days.updateValue(day, forKey: Model.Day.dateFormatter.string(from: date))

        return new(days: days)
    }
}

struct Action {
    private let stateUpdater: (_ state: State) -> Void

    init(with stateUpdater: @escaping (_ state: State) -> Void) {
        self.stateUpdater = stateUpdater
    }

    func login(company: String, username: String, password: String) {
        let api = API(company: company, auth: (username: username, password: password))

        api.user { result in
            result.error(ErrorLogging.log) { user in
                api.projects { result in
                    result.error(ErrorLogging.log) { projects in
                        let state = State(api: api, user: user, projects: projects, days: [:])
                        self.stateUpdater(state)
                    }
                }
            }
        }
    }

    func days(_ days: [Date]) {
        store.state.api.days(days) { date in
            return { result in
                result.error(ErrorLogging.log) { day in
                    let state = store.state.newDay(at: date, day: day)
                    self.stateUpdater(state)
                }
            }
        }
    }
}

class Store<State> {
    private(set) var state: State!
    typealias Subscriber = (_ state: State) -> Void
    private var subscribers = [Subscriber]()

    init(with state: State?) {
        self.state = state
    }

    func update(_ state: State) {
        self.state = state

        subscribers.forEach { $0(state) }
    }

    func subscribe(_ subscriber: @escaping Subscriber) {
        subscribers.append(subscriber)

        if state != nil {
            subscriber(state)
        }
    }
}

extension Result {
    func `if`(_ takeValue: (T) -> Void, or takeError: (Error) -> Void) {
        switch self {
        case let .success(value):
            takeValue(value)
        case let .failure(error):
            takeError(error)
        }
    }

    func error(_ takeError: (Error) -> Void, or takeValue: (T) -> Void) {
        switch self {
        case let .success(value):
            takeValue(value)
        case let .failure(error):
            takeError(error)
        }
    }
}
