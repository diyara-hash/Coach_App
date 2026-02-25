import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class AppHaptics {
  /// Sabit ve hafif dokunma hissi (Örn: toggle değişiklikleri)
  static void lightImpact() {
    if (!kIsWeb) HapticFeedback.lightImpact();
  }

  /// Daha belirgin dokunma hissi (Örn: form onayı, geçerli işlem)
  static void mediumImpact() {
    if (!kIsWeb) HapticFeedback.mediumImpact();
  }

  /// Güçlü dokunma hissi (Örn: Hata, uyarı)
  static void heavyImpact() {
    if (!kIsWeb) HapticFeedback.heavyImpact();
  }

  /// Kısa "tık" hissi (Örn: Tab geçişleri)
  static void selectionClick() {
    if (!kIsWeb) HapticFeedback.selectionClick();
  }
}
