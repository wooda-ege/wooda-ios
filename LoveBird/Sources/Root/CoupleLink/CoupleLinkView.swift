//
//  CoupleLinkView.swift
//  LoveBird
//
//  Created by 이예은 on 2023/07/04.
//

import SwiftUI
import UIKit
import ComposableArchitecture

struct CoupleLinkView: View {
  
  let store: StoreOf<CoupleLinkCore>
  @FocusState private var isEmailFieldFocused: Bool
  @StateObject private var keyboard = KeyboardResponder()
  @State var showShare: Bool = false
  var invitationCode: String = ""
  
  @Dependency(\.apiClient) var apiClient
  @Dependency(\.userData) var userData
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        Spacer().frame(height: 24)
        
        Text(R.string.localizable.onboarding_invitation_title)
          .font(.pretendard(size: 20, weight: .bold))
          .foregroundColor(.black)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.leading, 16)

        Text(R.string.localizable.onboarding_invitation_description)
          .font(.pretendard(size: 16, weight: .regular))
          .foregroundColor(Color(R.color.gray07))
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.top, 12)
          .padding(.leading, 16)
        
        Spacer().frame(height: 48)
    
        HStack {
          Text(viewStore.invitationCode)
            .font(.pretendard(size: 16, weight: .semiBold))
            .foregroundColor(.black)
            .lineLimit(1)
          
          Spacer()
          
          TouchableStack {
            Text("공유")
              .font(.pretendard(size: 14, weight: .bold))
              .foregroundColor(.white)
          }
          .background(.black)
          .frame(width: 48, height: 32)
          .cornerRadius(8)
          .padding(.trailing, 32)
          .onTapGesture {
            self.showShare = true
          }
          .sheet(isPresented: $showShare) {
            ActivityViewController(activityItems: [viewStore.invitationCode])
          }
        }
        .cornerRadius(12)
        .padding(.leading, 16)
        .frame(height: 56)
        .frame(width: UIScreen.width - 32)
        .roundedBackground(cornerRadius: 12, color: Color(R.color.gray07))
        
        
        Spacer()
          .frame(height: 53)
        
        VStack(alignment: .leading) {
          Text(R.string.localizable.onboarding_invitation_question)
            .font(.pretendard(size: 14, weight: .regular))
          TextField("초대코드 입력", text: viewStore.binding(get: \.invitationInputCode, send: CoupleLinkCore.Action.invitationcodeEdited))
            .font(.pretendard(size: 18, weight: .regular))
            .foregroundColor(Color(R.color.gray07))
            .padding(.vertical, 15)
            .padding(.leading, 16)
            .padding(.trailing, 48)
            .focused($isEmailFieldFocused)
            .showClearButton(viewStore.binding(get: \.invitationInputCode, send: .none))
            .frame(width: UIScreen.width - 32)
            .roundedBackground(cornerRadius: 12, color: viewStore.textFieldState.color)
        }
        
        Spacer()
        
        Button {
          Task {
            do {
              if viewStore.invitationInputCode.isEmpty { // 코드를 공유한 상황
                let response = try await self.apiClient.requestRaw(.coupleCheckButtonClicked(authorization: userData.get(key: .accessToken, type: String.self)!, refresh: userData.get(key: .refreshToken, type: String.self) ?? ""))
                if response == "SUCCESS" {
                  viewStore.send(.isSuccessTryLink(true))
                } else {
                  viewStore.send(.isSuccessTryLink(false))
                }
              } else { // 코드를 직접 입력한 상황
                let response = try await self.apiClient.requestRaw(.coupleLinkButtonClicked(coupleCode: viewStore.invitationInputCode, authorization: userData.get(key: .accessToken, type: String.self)!, refresh: userData.get(key: .refreshToken, type: String.self) ?? ""))
                if response == "SUCCESS" {
                  viewStore.send(.isSuccessTryLink(true))
                } else {
                  viewStore.send(.isSuccessTryLink(false))
                }
              }
            } catch {
              print("연동 실패")
            }
          }
          
          self.hideKeyboard()
        } label: {
          TouchableStack {
            Text(R.string.localizable.onboarding_invitation_connect)
              .font(.pretendard(size: 16, weight: .semiBold))
              .foregroundColor(.white)
          }
        }
        .frame(height: 56)
        .background(.black)
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.bottom, keyboard.currentHeight == 0 ? 20 + UIApplication.edgeInsets.bottom : keyboard.currentHeight + 20)
      }
      .onAppear {
        Task {
          do {
            let response = try await self.apiClient.request(.invitationViewLoaded(authorization: userData.get(key: .accessToken, type: String.self)!, refresh: userData.get(key: .refreshToken, type: String.self) ?? "")) as InvitationCodeResponse
            viewStore.send(.invitationViewLoaded(response.coupleCode))
          } catch {
            print("연동코드 발급 실패")
          }
        }
      }
      .background(.white)
      .onTapGesture {
        self.isEmailFieldFocused = false
      }
      .onChange(of: isEmailFieldFocused) { newValue in
        if viewStore.invitationInputCode.isEmpty {
          viewStore.send(.textFieldStateChanged(newValue ? .editing : .none))
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.white)
    }
  }
}

//struct OnboardingInviteView_Previews: PreviewProvider {
//  static var previews: some View {
//    OnboardingInvitationView(store: Store(initialState: OnboardingCore.State(), reducer: OnboardingCore()))
//  }
//}


struct ActivityViewController: UIViewControllerRepresentable {
  var activityItems: [Any]
  var applicationActivities: [UIActivity]? = nil
  @Environment(\.presentationMode) var presentationMode
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>
  ) -> UIActivityViewController {
    let controller = UIActivityViewController(
      activityItems: activityItems,
      applicationActivities: applicationActivities
    )
    controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
      self.presentationMode.wrappedValue.dismiss()
    }
    return controller
  }
  
  func updateUIViewController(
    _ uiViewController: UIActivityViewController,
    context: UIViewControllerRepresentableContext<ActivityViewController>
  ) {}
}

