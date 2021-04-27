import Foundation

import AWSLambdaEvents
import AWSLambdaRuntime

import SotoS3
import SotoCognitoIdentity

// MARK: - Run Lambda

// hard reference to an AWS Client
let client = AWSClient(
    httpClientProvider: .createNew
)

struct BucketList : Encodable {
    init() {
        self.buckets = []
    }
    var buckets : [String]
}

extension BucketList {
    func asJSONString() -> String {
        let jsonData = try! JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8)!
    }
}

// Support API Gateway's Http API
public typealias HttpApiRequest = APIGateway.V2.Request
public typealias HttpApiResponse = APIGateway.V2.Response

// set LOCAL_LAMBDA_SERVER_ENABLED env variable to "true" to start
// a local server simulator which will allow local debugging

Lambda.run { (context: Lambda.Context, request: HttpApiRequest, callback: @escaping (Result<HttpApiResponse, Error>) -> Void) in
    
    print(request.rawPath)
    print("reading s3")

    // need to prefix with SotoS3 because there is another S3 struct in AWSLambdaEvents
    let s3 = SotoS3.S3(client: client, region: .euwest1)

    let _ = s3.listBuckets()
        .map { (response: SotoS3.S3.ListBucketsOutput) -> BucketList in
            var results = BucketList()
            if let buckets = response.buckets {
                for b in buckets {
                    results.buckets.append(b.name ?? "no bucket name : \(b)")
                }
            }
            return results
        }
        .always { result in
            switch result {
                case .failure(let error):
                    callback(.success(HttpApiResponse(statusCode: .internalServerError, body: "\(error)")))
                    break
                case .success(let response):
                    callback(.success(HttpApiResponse(statusCode: .ok, body: response.asJSONString())))
                    break
            }
        }
}
