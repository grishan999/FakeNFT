import UIKit
import WebKit

//  WEBVIEW CONTROLLER для Пользовательского соглашения

final class WebViewController: UIViewController {
    
    // MARK: - Properties
    
    private let url: URL
    private let pageTitle: String
    
    // MARK: - UI Elements
    
    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.backgroundColor = .white
        return webView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .black
        progressView.trackTintColor = .lightGray
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        return progressView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .black
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Init
    
    init(url: URL, title: String = "Веб-страница") {
        self.url = url
        self.pageTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        loadWebPage()
    }
    
    deinit {
        //  Останавливаем таймер при деинициализации
        stopProgressTimer()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(webView)
        view.addSubview(progressView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            // Progress view
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2),
            
            // Web view
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigation() {
        title = pageTitle
        
        //  Кнопка "Назад"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Back Icon"),
            style: .plain,
            target: self,
            action: #selector(dismissViewController)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        //  Кнопка "Обновить" (опционально)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshWebView)
        )
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    private func loadWebPage() {
        activityIndicator.startAnimating()
        progressView.isHidden = false
        progressView.progress = 0.0
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        print(" Загружаем URL: \(url.absoluteString)")
    }
    
    private var progressTimer: Timer?
    
    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.progressView.progress = Float(self.webView.estimatedProgress)
                
                // Скрываем прогресс если загрузка завершена
                if !self.webView.isLoading && self.webView.estimatedProgress >= 1.0 {
                    self.progressView.isHidden = true
                    self.stopProgressTimer()
                }
            }
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    // MARK: - Actions
    
    @objc private func dismissViewController() {
        dismiss(animated: true)
    }
    
    @objc private func refreshWebView() {
        webView.reload()
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(" Начата загрузка веб-страницы")
        activityIndicator.startAnimating()
        progressView.isHidden = false
        progressView.progress = 0.0
        startProgressTimer()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(" Веб-страница загружена успешно")
        activityIndicator.stopAnimating()
        
        //  Плавно скрываем прогресс
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.progressView.isHidden = true
            self.stopProgressTimer()
        }
        
        //  Обновляем заголовок страницы
        if let pageTitle = webView.title, !pageTitle.isEmpty {
            title = pageTitle
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ Ошибка загрузки веб-страницы: \(error.localizedDescription)")
        activityIndicator.stopAnimating()
        progressView.isHidden = true
        stopProgressTimer()
        showError(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(" Ошибка предварительной загрузки: \(error.localizedDescription)")
        activityIndicator.stopAnimating()
        progressView.isHidden = true
        stopProgressTimer()
        showError(error.localizedDescription)
    }
    
    // MARK: - Error Handling
    
    private func showError(_ message: String) {
        stopProgressTimer()
        
        let alert = UIAlertController(
            title: "Ошибка загрузки",
            message: "Не удалось загрузить страницу: \(message)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { _ in
            self.loadWebPage()
        })
        
        alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel) { _ in
            self.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
}

//  СТАТИЧЕСКИЙ МЕТОД для удобного создания

extension WebViewController {
    
    static func presentTermsOfUse(from viewController: UIViewController) {
        guard let url = URL(string: "https://yandex.ru/legal/practicum_termsofuse/") else {
            print(" Неверный URL для пользовательского соглашения")
            return
        }
        
        let webVC = WebViewController(url: url, title: "Пользовательское соглашение")
        let navController = UINavigationController(rootViewController: webVC)
        navController.modalPresentationStyle = .pageSheet
        
        viewController.present(navController, animated: true)
    }
}
