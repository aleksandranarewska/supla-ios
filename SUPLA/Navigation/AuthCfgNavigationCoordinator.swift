/*
 Copyright (C) AC SOFTWARE SP. Z O.O.
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */
import UIKit
import RxSwift

class AuthCfgNavigationCoordinator: BaseNavigationCoordinator {
    override var wantsAnimatedTransitions: Bool {
        return !_immediate
    }
    override var viewController: UIViewController {
        return _viewController
    }
    
    private let _immediate: Bool
    private let _disposeBag = DisposeBag()
    
    private lazy var _viewController: AuthVC = {
        return AuthVC(navigationCoordinator: self)
    }()
    
    init(immediate: Bool) {
        _immediate = immediate
    }
    
    override func start(from parent: NavigationCoordinator?) {
        super.start(from: parent)
        _viewController.viewModel.initiateSignup.subscribe { _ in
            let cavc = SACreateAccountVC(nibName: "CreateAccountVC", bundle: nil)
            self.startFlow(coordinator: PresentationNavigationCoordinator(viewController: cavc))
        }.disposed(by: _disposeBag)
    }
}
extension AuthCfgNavigationCoordinator: AuthConfigActionHandler {
    func didFinish(shouldReauthenticate: Bool) {
        finish()
        if shouldReauthenticate || !SAApp.isClientRegistered(),
            let main = parentCoordinator as? MainNavigationCoordinator {
            main.showStatusView(progress: 0)
        }
    }
}
