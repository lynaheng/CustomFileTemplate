import UIKit

class ___FILEBASENAMEASIDENTIFIER___: UIViewController {
    
    let viewModel: ___VARIABLE_productName___ViewModel
    let mainView: ___VARIABLE_productName___View
    
    init() {
        viewModel = ___VARIABLE_productName___ViewModel(withModel: ___VARIABLE_productName___Model())
        mainView = ___VARIABLE_productName___View()
        super.init(nibName: nil, bundle: nil)
        
        mainView.configure(with: viewModel)
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
      
    }
}
