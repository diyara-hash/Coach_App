import 'package:haptic_feedback/haptic_feedback.dart';

class AppHaptics {
  /// Sabit butonlar veya küçük işlemler için (ör: sekmeler arası geçiş, check)
  static Future<void> light() async {
    final canVibrate = await Haptics.canVibrate();
    if (canVibrate) {
      await Haptics.vibrate(HapticsType.light);
    }
  }

  /// Uyarı durumları veya önemli eylemler için (ör: silme işlemi öncesi)
  static Future<void> warning() async {
    final canVibrate = await Haptics.canVibrate();
    if (canVibrate) {
      await Haptics.vibrate(HapticsType.warning);
    }
  }

  /// Başarılı işlemler için (ör: form kaydetme)
  static Future<void> success() async {
    final canVibrate = await Haptics.canVibrate();
    if (canVibrate) {
      await Haptics.vibrate(HapticsType.success);
    }
  }

  /// Hata durumları için (ör: form validation hatası)
  static Future<void> error() async {
    final canVibrate = await Haptics.canVibrate();
    if (canVibrate) {
      await Haptics.vibrate(HapticsType.error);
    }
  }

  /// Ağır işlemler veya ciddi etkileşimler için (ör: büyük bir veri silme veya kaydetme)
  static Future<void> heavy() async {
    final canVibrate = await Haptics.canVibrate();
    if (canVibrate) {
      await Haptics.vibrate(HapticsType.heavy);
    }
  }

  static Future<bool> canVibrate() async {
    return await Haptics.canVibrate();
  }
}
