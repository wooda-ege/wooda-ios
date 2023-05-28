//
//  RootCore.swift
//  wooda
//
//  Created by 황득연 on 2023/05/06.
//

import ComposableArchitecture

struct RootCore: ReducerProtocol {
    struct State: Equatable {
        var isOnboarding = true
    }
    enum Action: Equatable {
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
    
}
