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

    init(api: APIType, user: Model.User, projects: [Model.Project]) {
        self.api = api
        self.user = user
        self.projects = projects
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
                        self.stateUpdater(.init(api: api, user: user, projects: projects))
                    }
                }
            }
        }
    }

//    private func update(_ api: APIType, user: Model.User, projects: [Model.Project]) {
//
//    }
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
