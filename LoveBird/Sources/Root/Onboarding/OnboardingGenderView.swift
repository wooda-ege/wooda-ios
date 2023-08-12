//
//  OnboardingGenderView.swift
//  LoveBird
//
//  Created by 이예은 on 2023/07/03.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingGenderView: View {
  
  let store: StoreOf<OnboardingCore>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      ZStack {
        VStack {
          Spacer().frame(height: 24)
          Text(R.string.localizable.onboarding_gender_title)
            .font(.pretendard(size: 20, weight: .bold))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
          Text(R.string.localizable.onboarding_gender_description)
            .font(.pretendard(size: 16, weight: .regular))
            .foregroundColor(Color(R.color.gray07))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 12)
            .padding(.leading, 16)
          
          Spacer()
            .frame(height: 48)
          
          VStack(alignment: .leading) {
            TouchableStack {
              HStack {
                Text(R.string.localizable.onboarding_gender_female)
                  .font(.pretendard(size: 16, weight: .semiBold))
                  .foregroundColor((viewStore.gender == "FEMALE" ? Color.black : Color(R.color.gray07)))
                  .padding(.leading, 36)
                Spacer()
                Button {
                  viewStore.send(.genderSelected("FEMALE"))
                } label: {
                  viewStore.gender == "FEMALE" ? Image(R.image.ic_checkbox_on) : Image(R.image.ic_checkbox_off)
                }
                .padding(.trailing, 36)
              }
            }
            .frame(height: 56)
            .background(viewStore.gender == "FEMALE" ? Color.white : Color(R.color.gray02))
            .shadow(color: .black.opacity(0.08), radius: 12)
            
            TouchableStack {
              HStack {
                Text(R.string.localizable.onboarding_gender_male)
                  .font(.pretendard(size: 16, weight: .semiBold))
                  .foregroundColor((viewStore.gender == "MALE" ? Color.black : Color(R.color.gray07)))
                  .padding(.leading, 36)
                Spacer()
                Button {
                  viewStore.send(.genderSelected("MALE"))
                } label: {
                  viewStore.gender == "MALE" ? Image(R.image.ic_checkbox_on) : Image(R.image.ic_checkbox_off)
                }
                .padding(.trailing, 36)
              }
            }
            .frame(height: 56)
            .background(viewStore.gender == "MALE" ? Color.white : Color(R.color.gray02))
            .shadow(color: .black.opacity(0.08), radius: 12)
            
            TouchableStack {
              HStack {
                Text(R.string.localizable.onboarding_gender_private)
                  .font(.pretendard(size: 16, weight: .semiBold))
                  .foregroundColor((viewStore.gender == "PRIVATE" ? Color.black : Color(R.color.gray07)))
                  .padding(.leading, 36)
                Spacer()
                Button {
                  viewStore.send(.genderSelected("PRIVATE"))
                } label: {
                  viewStore.gender == "PRIVATE" ? Image(R.image.ic_checkbox_on) : Image(R.image.ic_checkbox_off)
                }
                .padding(.trailing, 36)
              }
            }
            .frame(height: 56)
            .background(viewStore.gender == "PRIVATE" ? Color.white : Color(R.color.gray02))
            .shadow(color: .black.opacity(0.08), radius: 12)
          }
          .cornerRadius(12)
          .padding(.horizontal, 16)
          
          Spacer()
            .frame(height: 294)
          
          Button {
            viewStore.send(.nextTapped)
            self.hideKeyboard()
          } label: {
            TouchableStack {
              Text(R.string.localizable.common_next)
                .font(.pretendard(size: 16, weight: .semiBold))
                .foregroundColor(.white)
            }
          }
          .frame(height: 56)
          .background(viewStore.buttonClickState == .notClicked ? Color(R.color.gray05) : .black)
          .cornerRadius(12)
          .padding(.horizontal, 16)
          .padding(.bottom, 20 + UIApplication.edgeInsets.bottom)
        }
      }
    }
  }
}

//struct OnboardingGenderView_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardingGenderView(store: Store(initialState: OnboardingCore.State(), reducer: OnboardingCore()))
//    }
//}

