import Foundation
import UIKit

class GradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private let timingFunction = CAMediaTimingFunction(name: .linear)
    private var currentGradientIndex = 0
    private var nextGradientIndex = 1
    private let gradientAnimationKey = "gradientAnimation"
    private var isAnimating = true
    
    private var gradients: [[CGColor]] = {
        var gradientColors: [[CGColor]] = []
        for _ in 0..<2 {
            var colors: [CGColor] = []
            for _ in 0..<5 {
                colors.append(UIColor.random().cgColor)
            }
            gradientColors.append(colors)
        }
        return gradientColors
    }()

    private var currentGradient: [CGColor] {
        return gradients[currentGradientIndex]
    }
    private var nextGradient: [CGColor] {
        return gradients[nextGradientIndex]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGradient()
    }

    private func animateToNextGradient() {
        isAnimating = true
        let newNextGradient: [CGColor] = {
            var colors: [CGColor] = []
            for _ in 0..<7 {
                colors.append(UIColor.random().cgColor)
            }
            return colors
        }()
        gradients[nextGradientIndex] = newNextGradient
        let gradientAnimation = CABasicAnimation(keyPath: "colors")
        gradientAnimation.fromValue = currentGradient
        gradientAnimation.toValue = nextGradient
        gradientAnimation.duration = 5.0
        gradientAnimation.delegate = self
        gradientAnimation.timingFunction = timingFunction
        gradientLayer.add(gradientAnimation, forKey: gradientAnimationKey)
    }
    
    private func setupGradient() {
        layer.addSublayer(gradientLayer)
        gradientLayer.colors = currentGradient
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        let startPointAnimation = CABasicAnimation(keyPath: "startPoint")
        startPointAnimation.fromValue = gradientLayer.startPoint
        startPointAnimation.repeatCount = .infinity
        gradientLayer.add(startPointAnimation, forKey: nil)
        animateToNextGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

extension GradientView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
            let tempIndex = currentGradientIndex
            currentGradientIndex = nextGradientIndex
            nextGradientIndex = tempIndex
            animateToNextGradient()
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}
