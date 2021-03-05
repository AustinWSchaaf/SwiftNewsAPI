# SwiftNewsAPI for iOS

A Swift wrapper for [News API](https://newsapi.org/)

## Adding to your project
For directions on how to add package dependencies to your project visit [Apple's instructions](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app). 
After successfully instailling the package, import the module like so.
````swift
import SwiftNewsAPI
````

## Usage
create a NewsAPI class and pass in your api key
````swift
let news = NewAPI(apiKey: "yourKey")
````
create your desired request and look over [News API documentation](https://newsapi.org/docs) for passing in the right params
````swift 
let everything = EverythingRequest(q: "politics")
let headlines = TopHeadlinesRequest(country: "us", category: "sports")
let sources = SourcesRequest() 
````
pass in your request 
````swift 
news.get(everything) { (data, res, error) in
    if let error = error {
        print(error.localizedDescription)
    }

    // do something with data
    if let data = data as? EverythingResponse{
        print("status: \(data.status) count: \(data.articles.count)")
    }else if let data = data as? TopHeadlinesResponse{
        print("status: \(data.status) count: \(data.articles.count)")
    }else if let data = data as? SourcesResponse{
        print("status: \(data.status) count: \(data.sources.count)")
    }
}
````

