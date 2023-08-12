//
//  ScheduleDetailCore.swift
//  LoveBird
//
//  Created by 황득연 on 2023/07/04.
//

import Foundation
import ComposableArchitecture

typealias ScheduleDetailState = ScheduleDetailCore.State
typealias ScheduleDetailAction = ScheduleDetailCore.Action

struct ScheduleDetailCore: ReducerProtocol {

  struct State: Equatable {
    @PresentationState var scheduleAdd: ScheduleAddState?
    let schedule: Schedule

    init(schedule: Schedule) {
      self.schedule = schedule
    }
  }

  enum Action: Equatable {
    case scheduleAdd(PresentationAction<ScheduleAddAction>)
    case backButtonTapped
    case editTapped
    case deleteTapped
  }

  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .editTapped:
        state.scheduleAdd = ScheduleAddState(schedule: state.schedule)
      case .deleteTapped:
        state.scheduleAdd = nil
      case .scheduleAdd(.presented(.addScheduleResponse(.success))):
        state.scheduleAdd = nil
      case .scheduleAdd(.presented(.backButtonTapped)):
        state.scheduleAdd = nil
      default:
        break
      }
      return .none
    }
    .ifLet(\.$scheduleAdd, action: /ScheduleDetailAction.scheduleAdd) {
      ScheduleAddCore()
    }
  }
}
