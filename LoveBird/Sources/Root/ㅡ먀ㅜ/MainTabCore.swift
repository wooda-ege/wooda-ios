//
//  MainTabCore.swift
//  LoveBird
//
//  Created by 황득연 on 2023/05/27.
//

import Foundation
import ComposableArchitecture

struct MainTabCore: ReducerProtocol {
    enum Tab {
        case home
        case canlander
        case diary
        case myPage
    }
    
    struct State: Equatable {
        var selectedTab = Tab.home
        var home: HomeCore.State? = HomeCore.State()
        var calander: CalanderCore.State? = CalanderCore.State()
        var diary: DiaryCore.State? = DiaryCore.State()
        var myPage: MyPageCore.State? = MyPageCore.State()
    }
    
    enum Action: Equatable {
        case tabSelected(Tab)
        case home(HomeCore.Action)
        case calander(CalanderCore.Action)
        case diary(DiaryCore.Action)
        case myPage(MyPageCore.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
            case .home(.emptyDiaryTapped):
                state.selectedTab = .diary
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.home, action: /Action.home) {
            HomeCore()
        }
    }
}
