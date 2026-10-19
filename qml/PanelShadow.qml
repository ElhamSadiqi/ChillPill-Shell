import QtQuick
import QtQuick.Effects

// assigned to layer.effect of a surface Rectangle
MultiEffect {
  shadowEnabled: true
  shadowBlur: 0.80
  shadowVerticalOffset: 8 * Config.dpiScale
  shadowColor: Theme.shadowSoft
}
