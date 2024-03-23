import UIKit
import Foundation

class GradientView: UIView {
    
    private let Gradient_Layer = CAGradientLayer()
    private let Gradient_Timing = CAMediaTimingFunction(name: .linear)
    private var Current_Gradient_Index = 0
    private var Next_Gradient_Index = 1
    private let Gradient_Animation_Key = "Gradient_Animation"
    private var Is_Animating = true
    
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
        return gradients[Current_Gradient_Index]
    }
    private var nextGradient: [CGColor] {
        return gradients[Next_Gradient_Index]
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
        Is_Animating = true
        let newNextGradient: [CGColor] = {
            var colors: [CGColor] = []
            for _ in 0..<7 {
                colors.append(UIColor.random().cgColor)
            }
            return colors
        }()
        gradients[Next_Gradient_Index] = newNextGradient
        let Gradient_Animations = CABasicAnimation(keyPath: "colors")
        Gradient_Animations.fromValue = currentGradient
        Gradient_Animations.toValue = nextGradient
        Gradient_Animations.duration = 5.0
        Gradient_Animations.delegate = self
        Gradient_Animations.timingFunction = Gradient_Timing
        Gradient_Layer.add(Gradient_Animations, forKey: Gradient_Animation_Key)
    }
    
    private func setupGradient() {
        layer.addSublayer(Gradient_Layer)
        Gradient_Layer.colors = currentGradient
        Gradient_Layer.startPoint = CGPoint(x: 0.5, y: 0)
        Gradient_Layer.endPoint = CGPoint(x: 0.5, y: 1)
        let startPointAnimation = CABasicAnimation(keyPath: "startPoint")
        startPointAnimation.fromValue = Gradient_Layer.startPoint
        startPointAnimation.repeatCount = .infinity
        Gradient_Layer.add(startPointAnimation, forKey: nil)
        animateToNextGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        Gradient_Layer.frame = bounds
    }
}

extension GradientView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
            let tempIndex = Current_Gradient_Index
            Current_Gradient_Index = Next_Gradient_Index
            Next_Gradient_Index = tempIndex
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
