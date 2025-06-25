import Foundation

extension String {
    func extractNFTName(
        from urlString: String
    ) -> String? {
        let pattern = #"\/([^\/]+)\/\d+\.png$"#
        let regex = try? NSRegularExpression(
            pattern: pattern,
            options: []
        )
        let nsString = urlString as NSString
        let results = regex?.firstMatch(
            in: urlString,
            options: [],
            range: NSRange(
                location: 0,
                length: nsString.length
            )
        )
        
        if let range = results?.range(at: 1) {
            return nsString.substring(
                with: range
            )
        }
        return nil
    }
}


