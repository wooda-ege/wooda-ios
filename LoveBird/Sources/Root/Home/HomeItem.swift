//
//  HomeItem.swift
//  LoveBird
//
//  Created by 황득연 on 2023/05/25.
//

import ComposableArchitecture
import SwiftUI

struct HomeItem: View {
  
  enum ContentType: Decodable, Encodable, Sendable {
    case empty
    case diary
    case initial
    case anniversary
  }
  
  let store: StoreOf<HomeCore>
  let diary: Diary
  
  var body: some View {
    HStack(spacing: 12) {
      HomeLeftLineView(timeState: diary.timeState)
        .padding(.leading, 16)

      if diary.isTimelineDateShown {
        VStack(alignment: .trailing) {
          Text(String(diary.memoryDate.month))
            .foregroundColor(diary.type == .anniversary ? Color(R.color.gray05) : Color.black)
            .font(.pretendard(size: 14, weight: .bold))

          Text(String(diary.memoryDate.day))
            .foregroundColor(diary.type == .anniversary ? Color(R.color.gray05) : Color.black)
            .font(.pretendard(size: 16, weight: .regular))

          Text(String(diary.memoryDate.year))
            .foregroundColor(diary.type == .anniversary ? Color(R.color.gray05) : Color(R.color.gray07))
            .font(.pretendard(size: 8, weight: .bold))

          Spacer()
        }
        .padding(.top, 20)
      } else {
        // Date를 보여줄때와 같은 Width를 같게 하기 위함.
        VStack {
          Text("2023")
            .foregroundColor(.clear)
            .font(.pretendard(size: 8, weight: .bold))
        }
      }

      HomeContentView(store: self.store, diary: diary)
    }
  }
}

//struct HomeItem_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeItem(diary: Diary.dummy[0])
//    }
//}

