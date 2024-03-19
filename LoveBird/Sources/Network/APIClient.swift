//
//  APIClient.swift
//  LoveBird
//
//  Created by 황득연 on 2023/05/30.
//

import Moya
import Alamofire
import ComposableArchitecture
import Dependencies
import Alamofire
import UIKit
import SwiftUI
import Foundation

public enum APIClient {

  // auth
  case authenticate(auth: Authenticate)
  case signUp(signUp: SignUpRequest)
  case withdrawal
  case recreate

  // profile
  case fetchProfile
  case editProfile(profile: EditProfileRequest)
  case presignProfileImage(presigned: PresignProfileImageRequest)

  // coupleLink
  case linkCouple(linkCouple: LinkCoupleRequest)
  case fetchCoupleCode
  case checkLinkedOrNot

  // diary
  case fetchDiaries
  case fetchDiary(id: Int)
  case addDiary(diary: AddDiaryRequest)
  case editDiary(id: Int, diary: AddDiaryRequest)
  case deleteDiary(id: Int)
  case searchPlaces(places: FetchPlacesRequest)
  case presignDiaryImages(presigned: PresignDiaryImagesRequest)

  // schedule
  case fetchCalendars(date: FetchSchedulesRequest)
  case fetchSchedule(id: Int)
  case addSchedule(schedule: AddScheduleRequest)
  case editSchedule(id: Int, schedule: AddScheduleRequest)
  case deleteSchedule(id: Int)

  var requestBody: Encodable? {
    switch self {
    case
        .signUp(let encodable as Encodable),
        .addSchedule(let encodable as Encodable),
        .editSchedule(_, let encodable as Encodable),
        .linkCouple(let encodable as Encodable),
        .authenticate(let encodable as Encodable),
        .editProfile(let encodable as Encodable),
        .addDiary(let encodable as Encodable),
        .editDiary(_, let encodable as Encodable),
        .presignProfileImage(let encodable as Encodable),
        .presignDiaryImages(let encodable as Encodable):
      return encodable

    default:
      return nil
    }
  }
}

extension APIClient: TargetType {

  // MARK: - Properties

    public var validationType: ValidationType {
      return .successCodes
    }

  public var userData: UserData {
    @Dependency(\.userData) var userData
    return userData
  }

  public var baseURL: URL {
    switch self {
    case .searchPlaces:
      return URL(string: Config.kakaoMapURL)!

    default:
      return URL(string: Config.baseURL)!
    }
  }

  public var path: String {
    switch self {
    case .withdrawal:
      return "/auth"

    case .authenticate:
      return "/auth/sign-in/oidc"

    case .fetchCoupleCode:
      return "/couple/code"

    case .linkCouple:
      return "/couple/link"

    case .checkLinkedOrNot:
      return "/couple/check"

    case .searchPlaces:
      return "/v2/local/search/keyword.json"

    case let .fetchDiary(id):
      return "/diaries/\(id)"

    case .fetchDiaries:
      return "/diaries"

    case .addDiary:
      return "/diaries"

    case let .editDiary(id, _), let .deleteDiary(id):
      return "/diaries/\(id)"

    case .addSchedule, .fetchCalendars:
      return "/calendars"

    case .fetchProfile, .editProfile:
      return "/profile"

    case .signUp:
      return "/auth/sign-up/oidc"

    case let .fetchSchedule(id), let .deleteSchedule(id), let .editSchedule(id, _):
      return "/calendars/\(id)"

    case .presignProfileImage:
      return "/presigned-urls/profile"

    case .presignDiaryImages:
      return "/presigned-urls/diary"

    case .recreate:
      return "/auth/recreate"
    }
  }

  public var method: Moya.Method {
    switch self {
    case .signUp, .addSchedule, .authenticate, .addDiary, .presignProfileImage, .presignDiaryImages, .recreate:
      return .post

    case .fetchDiary, .fetchCalendars, .fetchDiaries, .fetchProfile,
        .fetchSchedule, .checkLinkedOrNot, .searchPlaces, .fetchCoupleCode:
      return .get

    case .editSchedule, .editDiary, .editProfile, .linkCouple:
      return .put

    case .deleteSchedule, .deleteDiary, .withdrawal:
      return .delete
    }
  }

  public var task: Moya.Task {
    switch self {
    case
        .signUp,
        .addSchedule,
        .editSchedule,
        .linkCouple,
        .authenticate,
        .editProfile,
        .addDiary,
        .editDiary,
        .presignProfileImage,
        .presignDiaryImages:
      if let body = requestBody {
        return .requestJSONEncodable(body)
      } else {
        return .requestPlain
      }

    case let .searchPlaces(encodable):
      return .requestParameters(parameters: ["query": encodable.query], encoding: URLEncoding.queryString)

    default:
      return .requestPlain
    }
  }

  public var headers: [String: String]? {
    let accessToken = userData.accessToken.value
    let refreshToken =  userData.refreshToken.value
    print("Access Token is \(accessToken)")
    print("Refresh Token is \(refreshToken)")
    if case .searchPlaces = self {
      return ["Authorization" : Config.kakaoMapKey]
    }
    if accessToken.isNotEmpty, refreshToken.isNotEmpty  {
      return ["Authorization": "Bearer \(accessToken)", "Refresh": "Bearer \(refreshToken)"]
    }

    if case .recreate = self {
      return ["Refresh": refreshToken]
    }

    return nil
  }
}


extension MoyaProvider {
  var userData: UserData {
    @Dependency(\.userData) var userData
    return userData
  }

  func request<T: Decodable>(_ target: Target) async throws -> T? {
    return try await withCheckedThrowingContinuation { continuation in
      self.request(target) { response in
        switch response {
        case .success(let result):
          do {
            print("-----> Network Request (\(target.path))")
            if case let .requestJSONEncodable(requestBody) = target.task {
              print("\(String(describing: requestBody))")
            }

            switch LovebirdStatusCode(code: result.statusCode) {
            case .success:
              let data = try JSONDecoder().decode(NetworkResponse<T>.self, from: result.data)
              print("<----- Network Response (\(target.path))")
              print("\(String(describing: data.data))\n")
              continuation.resume(returning: data.data)

            case .badRequest:
              let data = try JSONDecoder().decode(NetworkStatusResponse.self, from: result.data)
              guard let errorType = LovebirdAPIError(rawValue: data.code) else { throw LovebirdError.unknownError }
              if errorType == .invalidJWTToken {
                self.callRecreateAPI { result in
                  switch result {
                  case .success(let token):
                    self.userData.accessToken.value = token.accessToken
                    self.userData.refreshToken.value = token.refreshToken
                  case .failure:
                    self.userData.reset()
                    // 로그아웃 + 홈화면 가기
                    break
                  }
                }
              } else {
                throw LovebirdError.badRequest(errorType: errorType, message: data.message)
              }

            case .internalServerError:
              throw LovebirdError.internalServerError

            default:
              throw LovebirdError.unknownError
            }
          } catch {
            continuation.resume(throwing: error)
            print("<----- Network Failure: (\(target.path))")
            print("\(error)\n")
          }

        case .failure(let error):
          continuation.resume(throwing: error)
          print("<----- Network Failure: (\(target.path))")
          print("\(error)\n")
        }      }
    }
  }

  func requestKakaoMap(_ target: Target) async throws -> FetchPlacesResponse {
    return try await withCheckedThrowingContinuation { continuation in
      self.request(target) { response in
        switch response {
        case .success(let result):
          do {
            let networkResponse = try JSONDecoder().decode(FetchPlacesResponse.self, from: result.data)
            continuation.resume(returning: networkResponse)
            print("<----- Network Success (\(target.path))\n")
            print("\(networkResponse)\n")
          } catch {
            continuation.resume(throwing: error)
            print("<----- Network Exception: (\(target.path))")
            print("\(error)\n")
          }

        case .failure(let error):
          continuation.resume(throwing: error)
          print("<----- Network Exception: (\(target.path))")
          print("\(error)\n")
        }
      }
    }
  }

  func callRecreateAPI(completion: @escaping (Result<Token, Error>) -> Void) {
      guard let url = URL(string: "https://dev-app-api.lovebird-wooda.com/api/v1/auth/recreate") else {
          completion(.failure(LovebirdError.internalServerError))
          return
      }

      let refreshToken = userData.refreshToken.value

      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
      request.setValue(refreshToken, forHTTPHeaderField: "Refresh")

      URLSession.shared.dataTask(with: request) { data, response, error in
          if let error = error {
              completion(.failure(error))
              return
          }

          guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
              completion(.failure(LovebirdError.unknownError))
              return
          }

          guard let responseData = data else {
              completion(.failure(LovebirdError.unknownError))
              return
          }

          do {
              let tokenResponse = try JSONDecoder().decode(Token.self, from: responseData)
              completion(.success(tokenResponse))
          } catch {
              completion(.failure(LovebirdError.decodeError))
          }
      }.resume()
  }

}

// data.code가 1101일때
// accesstoken이 만료된 경우 or refreshtoken이 만료된 경우
// 1번,2번 모두 recreate api호출 -> 응답이 성공이면 access만 만료됐던거라 다시 받아온 응답값으로 수정해줌
// 응답이 실패면 refresh도 만료됐던거라 로그인홈으로 돌아가게 함

class AuthInterceptor: RequestInterceptor {

  @Dependency(\.userData) var userData

  static let shared = AuthInterceptor()

  private init() {}

  func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
    guard urlRequest.url?.absoluteString.hasPrefix(Config.baseURL) == true else {
      completion(.success(urlRequest))
      return
    }

    let accessToken = userData.accessToken.value
    let refreshToken = userData.accessToken.value

    var urlRequest = urlRequest
    urlRequest.setValue(accessToken, forHTTPHeaderField: "Authorization")
    urlRequest.setValue(refreshToken, forHTTPHeaderField: "Refresh")

    completion(.success(urlRequest))
  }

  func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
    print("retry 진입")
    guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 400
    else {
      completion(.doNotRetryWithError(error))
      return
    }

    // 1101인거 어떻게 알지??..

    callRecreateAPI { result in
      switch result {
      case .success:
        print("Retry-토큰 재발급 성공")
        completion(.retry)
      case .failure(let error):
        // 갱신실패 - 로그아웃
        completion(.doNotRetryWithError(error))
      }
    }
  }

  func callRecreateAPI(completion: @escaping (Result<Token, Error>) -> Void) {
      guard let url = URL(string: "https://dev-app-api.lovebird-wooda.com/api/v1/auth/recreate") else {
          completion(.failure(LovebirdError.internalServerError))
          return
      }

      let refreshToken = userData.refreshToken.value

      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
      request.setValue(refreshToken, forHTTPHeaderField: "Refresh")

      URLSession.shared.dataTask(with: request) { data, response, error in
          if let error = error {
              completion(.failure(error))
              return
          }

          guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
              completion(.failure(LovebirdError.unknownError))
              return
          }

          guard let responseData = data else {
              completion(.failure(LovebirdError.unknownError))
              return
          }

          do {
              let tokenResponse = try JSONDecoder().decode(Token.self, from: responseData)
              completion(.success(tokenResponse))
          } catch {
              completion(.failure(LovebirdError.decodeError))
          }
      }.resume()
  }
}
