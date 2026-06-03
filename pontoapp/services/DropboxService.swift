//
//  DropboxService.swift
//  pontoapp
//
//  Created by Erick Costa on 18/12/25.
//

import Foundation

class DropboxService {
    private let apiKey = EnviromentVariables.dropboxApiKey
    private let appSecret = EnviromentVariables.dropboxAppSecret
    private let acessToken = EnviromentVariables.dropboxAcessToken
    private let refreshToken = EnviromentVariables.dropboxRefreshToken

    private func getRefreshToken(completion: @escaping(String?) -> Void){
        let url = URL(string: "https://api.dropbox.com/oauth2/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let bodyParams = "grant_type=refresh_token&refresh_token=\(refreshToken)&client_id=\(apiKey)&client_secret=\(appSecret)"
        request.httpBody = bodyParams.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { completion(nil); return }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let newAccessToken = json["access_token"] as? String {
                print("Token renovado com sucesso!")
                completion(newAccessToken)
            } else {
                print("Erro ao renovar token: \(String(data: data, encoding: .utf8) ?? "")")
                completion(nil)
            }
        }.resume()
    }
    
    func uploadFileAndGetLink(studentId: String, studentName: String, fileData: Data, fileName: String, completion: @escaping(String?) -> Void) {
        print("Inicio do envio de arquivos para o dropbox")
        
        getRefreshToken { newAccessToken in
            guard let token = newAccessToken else {
                print("ERRO CRÍTICO: Não foi possível renovar o token.")
                completion(nil)
                return
            }
            
            self.uploadFile(studentId: studentId, studentName: studentName, token: token, data: fileData, fileName: fileName) { path in
                guard let path = path else {
                    print("ERRO AO SUBIR ARQUIVO NO DROPBOX")
                    completion(nil)
                    return
                }
                
                print("Caminho encontrado: \(path)")
                print("Criando link para compartilhamento...")
                self.createSharedLink(token: token, path: path) { url in
                    completion(url)
                }
            }
        }
    }
    
    private func uploadFile(studentId: String, studentName: String, token: String , data: Data, fileName: String, completion: @escaping(String?) -> Void) {
        let url = URL(string: "https://content.dropboxapi.com/2/files/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        let uniqueFileName = "\(UUID().uuidString)_\(fileName)"

        let sanitizedName = studentName.trimingWhitespaces()
        let fullPath = "/\(Date.classDurationInYears())/\(sanitizedName)-\(studentId)/\(uniqueFileName)"

        let args: [String: Any] = [
            "path": fullPath,
            "mode": "add",
            "autorename": true,
            "mute": false
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: args, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
               request.setValue(jsonString, forHTTPHeaderField: "Dropbox-API-Arg")
        }
        
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }
            
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let path = json["path_lower"] as? String {
                print("Arquivo salvo em: \(path)")
                completion(path)
            } else {
                print("Erro ao ler resposta do upload: \(String(data: data, encoding: .utf8) ?? "")")
                completion(nil)
            }
        }.resume()
    }
    
    private func createSharedLink(token: String, path: String, completion: @escaping(String?) -> Void) {
        let url = URL(string: "https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "path": path,
            "settings": [
                "requested_visibility": "public"
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let urlString = json["url"] as? String {

                let directLink = urlString.replacingOccurrences(of: "dl=0", with: "dl=1")
                completion(directLink)
            } else {
                print("Erro ao gerar link: \(String(data: data, encoding: .utf8) ?? "")")
                completion(nil)
            }
        }.resume()
    }
}
