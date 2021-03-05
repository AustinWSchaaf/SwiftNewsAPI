import Foundation

// Helper stuff

public class Request{
    private static let session = URLSession.shared
    
    public static func http(_ url: URL, completion: @escaping (Data?,URLResponse?,Error?)->()){
//        session.invalidateAndCancel()

        session.dataTask(with: url) { (data, response, error) in
            completion(data, response, error)
        }.resume()
    }
}

// News API Class

public class NewsAPI{
    private let key: String
    
    public init(apiKey: String) {
        self.key = apiKey
    }
    
    public func get(_ request: NewsAPIRequest, completion: @escaping (NewsApiResponse?,URLResponse?,Error?) -> ()){
        guard let url = getURL(request) else { return }
        
        Request.http(url) { (data, res, error) in
            if let error = error{
                completion(nil,nil,error)
            }
            guard let data = data else { return }
            do{
                var results: NewsApiResponse!
                
                switch request{
                case is EverythingRequest:
                    results = try JSONDecoder().decode(EverythingResponse.self, from: data)
                case is TopHeadlinesRequest:
                    results = try JSONDecoder().decode(TopHeadlinesResponse.self, from: data)
                case is SourcesRequest:
                    results = try JSONDecoder().decode(SourcesResponse.self, from: data)
                default:
                    break
                }
                completion(results,res,error)
            }catch let error{
                completion(nil,nil,error)
            }
        }
    }
    
    private func getURL(_ query: NewsAPIRequest)->URL?{
        return URL(string: query.url+key)
    }
}

// News API Request Models

public protocol NewsAPIRequest {
    var url: String { get }
}

public struct EverythingRequest: NewsAPIRequest{
    private let q: String
    private let qInTitle: String
    private let sources: String
    private let domains: String
    private let excludeDomains: String
    private let from: String
    private let to: String
    private let language: String
    private let sortBy: String
    private let pageSize: Int
    private let page: Int
    
    public init(q: String, qInTitle: String? = nil, sources: [String]? = nil, domains: [String]? = nil, excludedDomains: [String]? = nil, from: String? = nil, to: String? = nil, language: String? = nil, sortBy: String = "publishedAt", pageSize: Int = 100, page: Int = 1 ) {
        
        self.q = q
        self.qInTitle = qInTitle ?? ""
        self.sources = sources?.joined(separator: ",") ?? ""
        self.domains = domains?.joined(separator: ",") ?? ""
        self.excludeDomains = excludedDomains?.joined(separator: ",") ?? ""
        self.from = from ?? ""
        self.to = to ?? ""
        self.language = language ?? ""
        self.sortBy = sortBy
        self.pageSize = pageSize
        self.page = page
    }
    
    public var url: String{
        return "https://newsapi.org/v2/everything?q=\(q)&qInTitle=\(qInTitle)&sources=\(sources)&domains\(domains)&excludedDomains=\(excludeDomains)&from=\(from)&to=\(to)&language=\(language)&sortBy=\(sortBy)&pageSize=\(pageSize)&page=\(page)&apiKey="
    }
}

public struct TopHeadlinesRequest: NewsAPIRequest{
    private let country: String
    private let category: String
    private let sources: String
    private let q: String
    private let pageSize: Int
    private let page: Int
    
    public init(sources: [String]? = nil, q: String? = nil, pageSize: Int = 20, page: Int = 1){
        self.country = ""
        self.category = ""
        self.q = q ?? ""
        self.pageSize = pageSize
        self.page = page
        self.sources = sources?.joined(separator: ",") ?? ""
    }
    
    public init(country: String? = nil, category: String? = nil, q: String? = nil, pageSize: Int = 20, page: Int = 1){
        self.country = country ?? ""
        self.category = category ?? ""
        self.q = q ?? ""
        self.pageSize = pageSize
        self.page = page
        self.sources = ""
    }
    
    public var url: String{
       return "https://newsapi.org/v2/top-headlines?country=\(country)&category=\(category)&sources=\(sources)&q=\(q)&pageSize=\(pageSize)&page=\(page)&apiKey="
    }
}

public struct SourcesRequest: NewsAPIRequest{
    private let category: String
    private let language: String
    private let country: String
    
    public init(category: String? = nil, language: String? = nil, country: String? = nil) {
        self.category = category != nil ? "category=\(category!)&" : ""
        self.language = language != nil ? "language=\(language!)&" : ""
        self.country = country != nil ? "country=\(country!)&" : ""
    }
    
    public var url: String{
        return "https://newsapi.org/v2/sources?\(category)\(language)\(country)apiKey="
    }
}

// News API Request Models

public protocol NewsApiResponse {}

public struct EverythingResponse: NewsApiResponse, Decodable{
    public let status: String
    public let totalResults: Int
    public let articles: [Article]
}

public struct Article: Decodable{
    public let source: Source
    public let author: String?
    public let title: String
    public let description: String?
    public let url: String
    public let urlToImage: String?
    public let publishedAt: String?
    public let content: String?
    
    
    public struct Source: Decodable{
        public let id: String?
        public let name: String
    }
}

public struct TopHeadlinesResponse: NewsApiResponse, Decodable{
    public let status: String
    public let totalResults: Int
    public let articles: [Article]
}

public struct SourcesResponse: NewsApiResponse, Decodable{
    public let status: String
    public let sources: [Source]
    
    public struct Source: Decodable{
        public let id: String
        public let name: String
        public let description: String
        public let url: String
        public let category: String
        public let language: String
        public let country: String
    }
}
