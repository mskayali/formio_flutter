import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:formio/models/formio_localizations.dart';

/// Turkish implementation of [FormioLocalizations].
class TurkishFormioLocalizations implements FormioLocalizations {
  const TurkishFormioLocalizations();

  @override
  String get submit => 'Gönder';
  @override
  String get cancel => 'İptal';
  @override
  String get clear => 'Temizle';
  @override
  String get undo => 'Geri Al';
  @override
  String get next => 'İleri';
  @override
  String get previous => 'Geri';
  @override
  String get complete => 'Tamamla';
  @override
  String get add => 'Ekle';
  @override
  String get addAnother => 'Başka Ekle';
  @override
  String get addEntry => 'Giriş Ekle';
  @override
  String get edit => 'Düzenle';
  @override
  String get save => 'Kaydet';
  @override
  String get remove => 'Kaldır';
  @override
  String get delete => 'Sil';

  @override
  String get uploadFile => 'Dosya Yükle';
  @override
  String get noFileSelected => 'Dosya seçilmedi';
  @override
  String get fileSelected => 'dosya seçildi';
  @override
  String get filesSelected => 'dosya seçildi';

  @override
  String get fetching => 'Yükleniyor';
  @override
  String get dataSourceError => 'Veri Kaynağı Hatası';

  @override
  String get removeRow => 'Satırı Kaldır';
  @override
  String get editRow => 'Satırı Düzenle';
  @override
  String get saveRow => 'Satırı Kaydet';
  @override
  String get cancelEdit => 'Düzenlemeyi İptal Et';

  @override
  String get showing => 'Gösterilen';
  @override
  String get of => '/';
  @override
  String get rowsPerPage => 'Sayfa başına satır';
  @override
  String get rowSelected => 'satır seçildi';
  @override
  String get rowsSelected => 'satır seçildi';
  @override
  String get noDataAvailable => 'Veri yok';

  @override
  String get step => 'Adım';
  @override
  String get stepOf => '/';

  @override
  String get required => 'gerekli';
  @override
  String get isRequired => 'gereklidir';
  @override
  String get noData => 'Veri yok';
  @override
  String get noDataToReview => 'İncelenecek veri yok';
  @override
  String get noOptions => 'Seçenek yok';
  @override
  String get empty => '(boş)';
  @override
  String get none => '(yok)';
  @override
  String get yes => 'Evet';
  @override
  String get no => 'Hayır';
  @override
  String get actions => 'İşlemler';

  @override
  String get typeAndPressEnter => 'Yazın ve Enter\'a basın';
  @override
  String get typeToAddTag => 'Etiket eklemek için yazın ve Enter\'a basın';
  @override
  String get searchPlaceholder => 'Ara...';

  @override
  String get fieldRequired => 'Bu alan gereklidir';
  @override
  String get invalidEmail => 'Geçersiz e-posta adresi';
  @override
  String get invalidUrl => 'Geçersiz URL';
  @override
  String get invalidNumber => 'Geçersiz sayı';
  @override
  String get mustBeNumber => 'Sayı olmalıdır';

  @override
  String get clearSignature => 'Temizle';
  @override
  String get clearCanvas => 'Temizle';
  @override
  String get undoLastStroke => 'Geri Al';
  @override
  String get color => 'Renk';
  @override
  String get size => 'Boyut';
  @override
  String get eraser => 'Silgi';

  @override
  String get review => 'İnceleme';
  @override
  String get reviewYourSubmission => 'Gönderiminizi İnceleyin';

  @override
  String get noStepsConfigured => 'Adım yapılandırılmamış';
  @override
  String get noEntriesAdded => 'Henüz giriş eklenmedi';

  @override
  String getRequiredMessage(String fieldLabel) => '$fieldLabel $isRequired.';

  @override
  String getFileCountMessage(int count) {
    if (count == 0) return noFileSelected;
    if (count == 1) return '1 $fileSelected';
    return '$count $filesSelected';
  }

  @override
  String getShowingMessage(int start, int end, int total) => '$showing $start-$end $of $total';

  @override
  String getSelectedRowsMessage(int count) {
    if (count == 1) return '1 $rowSelected';
    return '$count $rowsSelected';
  }

  @override
  String getStepMessage(int current, int total) => '$step $current $stepOf $total';

  /// Creates an object that provides Turkish resource values for Form.io widgets.
  static Future<FormioLocalizations> load(Locale locale) {
    return SynchronousFuture<FormioLocalizations>(const TurkishFormioLocalizations());
  }

  /// A [LocalizationsDelegate] for Turkish Form.io localizations.
  static const LocalizationsDelegate<FormioLocalizations> delegate = _TurkishFormioLocalizationsDelegate();
}

class _TurkishFormioLocalizationsDelegate extends LocalizationsDelegate<FormioLocalizations> {
  const _TurkishFormioLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tr';

  @override
  Future<FormioLocalizations> load(Locale locale) => TurkishFormioLocalizations.load(locale);

  @override
  bool shouldReload(_TurkishFormioLocalizationsDelegate old) => false;

  @override
  String toString() => 'TurkishFormioLocalizations.delegate(tr_TR)';
}
