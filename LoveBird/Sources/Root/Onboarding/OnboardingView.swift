//
//  OnboardingView.swift
//  wooda
//
//  Created by 황득연 on 2023/05/09.
//

import ComposableArchitecture
import SwiftUI
import SwiftUIPager
import Foundation

struct OnboardingView: View {
  let store: StoreOf<OnboardingCore>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        HStack(alignment: .center) {
          Button { viewStore.send(.previousTapped) } label: {
            Image(
              viewStore.page.isFisrt
                ? R.image.ic_navigate_previous_inactive
                : R.image.ic_navigate_previous_active
            )
            .padding(.leading, 16)
          }
          
          Spacer()
          
          HStack {
            ForEach(Page.Onboarding.allCases, id: \.self) {
              Circle()
                .frame(width: 10, height: 10)
                .foregroundColor(viewStore.page.index == $0.rawValue ? Color(R.color.primary) : Color(R.color.green164))
            }
          }
          
          Spacer()
          
          Button { viewStore.send(.nextTapped) } label: {
            Image(
              viewStore.page.isLast
                ? R.image.ic_navigate_next_inactive
                : R.image.ic_navigate_next_active
            )
            .padding(.trailing, 16)
          }
        }
        .frame(width: UIScreen.width, height: 44)

        Spacer(minLength: 24)

        VStack(alignment: .leading, spacing: 12) {
          Text(viewStore.state.pageState.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.pretendard(size: 20, weight: .bold))
            .foregroundColor(.black)

          Text(viewStore.state.pageState.description)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.pretendard(size: 16, weight: .regular))
            .foregroundColor(Color(R.color.gray07))
        }
        .padding(.leading, 16)

        Spacer(minLength: 48)
        
        Pager(page: viewStore.page, data: Page.Onboarding.allCases, id: \.self) {
          switch $0 {
          case .email:
            OnboardingEmailView(store: self.store)
          case .nickname:
            OnboardingNicknameView(store: self.store)
          case .profileImage:
            OnboardingProfileView(store: self.store)
          case .birth:
            OnboardingBirthDateView(store: self.store)
          case .gender:
            OnboardingGenderView(store: self.store)
          case .anniversary:
            OnboardingDateView(store: self.store)
          }
        }
        .allowsDragging(false)
        .edgesIgnoringSafeArea(.bottom)
      }
    }
  }
}

//struct OnboardingView_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardingView(store: Store(initialState: OnboardingCore.State(), reducer: OnboardingCore()))
//    }
//}
