//
//  SearchPlaceCore.swift
//  LoveBird
//
//  Created by 이예은 on 2023/05/30.
//

import ComposableArchitecture
import SwiftUI

struct SearchPlaceCore: ReducerProtocol {
    struct State: Equatable {
        var placeSelection: String = ""
        var placeList: [PlaceInfo] = []
        var searchTerm: String = ""
    }
    
    enum SearchPlaceAction: Equatable {
        case textFieldDidEditting(String)
        case selectPlace(String)
        case changePlaceInfo([PlaceInfo])
        case completeButtonTapped
    }
    
    var body: some ReducerProtocol<State, SearchPlaceAction> {
        Reduce { state, action in
            switch action {
            case .textFieldDidEditting(let searchTerm):
                state.searchTerm = searchTerm
                return .none
            case .selectPlace(let place):
                // 여기서 DiaryCore의 place랑 바인딩
                state.placeSelection = place
                return .none
            case .changePlaceInfo(let placeInfo):
                state.placeList = placeInfo
                return .none
            case .completeButtonTapped:
                NavigationLink(destination: HomeView(store: Store(initialState: HomeCore.State(), reducer: HomeCore()))) {
                    
                }
            default:
                break
            }
            
            return .none
        }
    }
}



