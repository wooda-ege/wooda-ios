//
//  CalendarTabView.swift
//  LoveBird
//
//  Created by 황득연 on 2023/06/30.
//

import ComposableArchitecture
import SwiftUI

struct CalendarTabView: View {
  let store: StoreOf<CalendarCore>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      HStack(alignment: .center) {
        HStack(spacing: 0) {
          Text(String(viewStore.currentDate.year) + "." + String(viewStore.currentDate.month))
            .font(.pretendard(size: 22, weight: .bold))
            .foregroundColor(.black)

          Image(asset: LoveBirdAsset.icArrowDropDown)
            .frame(width: 24, height: 24)
        }
        .onTapGesture {
          viewStore.send(.toggleTapped)
        }

        Spacer()

        HStack(spacing: 16) {
          Button { viewStore.send(.plusTapped(viewStore.currentDate)) } label: {
            Image(asset: LoveBirdAsset.icPlus)
          }
        }
      }
      .frame(height: 44)
      .padding(.horizontal, 16)
    }
  }
}

#Preview {
  CalendarTabView(
    store: Store(
      initialState: CalendarState(),
      reducer: { CalendarCore() }
    )
  )
}
