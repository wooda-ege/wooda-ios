//
//  OnboardingNicknameView.swift
//  LoveBird
//
//  Created by 황득연 on 2023/05/20.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingNicknameView: View {
    
    let store: StoreOf<OnboardingCore>
    @State private var name: String = ""
    @State private var state: TextFieldState = .none
    @FocusState private var isNameFieldFocused: Bool
    @StateObject private var keyboard = KeyboardResponder()
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                Spacer().frame(height: 24)
                Text("당신의 애칭을 알려주세요")
                    .font(.pretendard(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                Text("애칭이 없다면 이름 또는 별명을 알려주셔도 좋아요")
                    .font(.pretendard(size: 16, weight: .regular))
                    .foregroundColor(Color(R.color.gray156))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
                    .padding(.leading, 16)
                Spacer().frame(height: 48)
                TextField("ex. 러버", text: $name)
                    .font(.pretendard(size: 18, weight: .regular))
                    .foregroundColor(.black)
                    .padding(.vertical, 15)
                    .padding(.leading, 16)
                    .padding(.trailing, 48)
                    .focused($isNameFieldFocused)
                    .showClearButton($name)
                    .frame(width: UIScreen.width - 32)
                    .roundedBackground(cornerRadius: 12, color: $state.wrappedValue.color)
                
                Text($state.wrappedValue.description)
                    .font(.pretendard(size: 16, weight: .regular))
                    .foregroundColor($state.wrappedValue.color)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.leading, 16)
                Spacer()
                Button(action: {
                    
                }) {
                    Text("다음")
                        .font(.pretendard(size: 16, weight: .semiBold))
                }
                .frame(width: UIScreen.width - 32, height: 56)
                .background(state == .correct ? .black : Color(R.color.gray214))
                .cornerRadius(12)
                .foregroundColor(.white)
                .padding(.bottom, keyboard.currentHeight == 0 ? 20 + UIApplication.edgeInsets.bottom : keyboard.currentHeight + 20)
            }
            .onChange(of: isNameFieldFocused) { newValue in
                state = newValue ? .editing : .none
            }
            .onChange(of: name) { newValue in
                state = newValue.count >= 2 ? .correct : .editing
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white)
        }
    }
}

struct OnboardingNicknameView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingNicknameView(store: Store(initialState: OnboardingCore.State(), reducer: OnboardingCore()))
    }
}
