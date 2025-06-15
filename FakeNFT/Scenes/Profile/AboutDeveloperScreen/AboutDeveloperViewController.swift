import UIKit
import WebKit

final class AboutDeveloperViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var backButton: UIButton = {
        let button = UIButton()
        if let imageButton = UIImage(named: "back_button")?.withRenderingMode(.alwaysTemplate) {
            button.setImage(
                imageButton,
                for: .normal
            )
            button.tintColor = .background
            button.addTarget(
                self,
                action: #selector(didTapBackButton),
                for: .touchUpInside
            )
        }
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Web Elements
    var urlString: String?
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView(
            frame: self.view.bounds
        )
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(
            progressViewStyle: .default
        )
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        return progressView
    }()
    
    // MARK: - Life Cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadURL()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress)
        )
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(
            WKWebView.estimatedProgress
        ) {
            updateProgress()
        } else {
            super.observeValue(
                forKeyPath: keyPath,
                of: object,
                change: change,
                context: context
            )
        }
    }
    
    // MARK: - Private Methods
    @objc
    private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func loadURL() {
        guard let urlString = urlString,
              let url = URL(
                string: urlString
              ) else {
            print("Некорректный URL")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

// MARK: - ViewConfigurable
extension AboutDeveloperViewController: ViewConfigurable {
    func addSubviews() {
        let subViews = [webView, progressView]
        subViews.forEach { view.addSubview($0) }
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    private func setupView() {
        view.backgroundColor = .background
        setupNavBar()
        configureView()
    }
}

// MARK: - WKNavigationDelegate
extension AboutDeveloperViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        updateProgress()
    }
    
    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        updateProgress()
        print("Ошибка загрузки: \(error.localizedDescription)")
    }
}

