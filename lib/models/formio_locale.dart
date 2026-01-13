/// Localization/Internationalization configuration for Form.io Flutter.
///
/// Contains all user-facing strings used in components.
/// Create custom instances for different languages.
library;

class FormioLocale {
  // Buttons & Actions
  final String submit;
  final String cancel;
  final String clear;
  final String undo;
  final String next;
  final String previous;
  final String complete;
  final String add;
  final String addAnother;
  final String addEntry;
  final String edit;
  final String save;
  final String remove;
  final String delete;

  // File Component
  final String uploadFile;
  final String noFileSelected;
  final String fileSelected;
  final String filesSelected;

  // DataSource
  final String fetching;
  final String dataSourceError;

  // DataGrid & EditGrid
  final String removeRow;
  final String editRow;
  final String saveRow;
  final String cancelEdit;

  // DataTable
  final String showing;
  final String of;
  final String rowsPerPage;
  final String rowSelected;
  final String rowsSelected;
  final String noDataAvailable;

  // Wizard & DynamicWizard
  final String step;
  final String stepOf;

  // Generic
  final String required;
  final String isRequired;
  final String noData;
  final String noDataToReview;
  final String noOptions;
  final String empty;
  final String none;
  final String yes;
  final String no;
  final String actions;

  // Input Helpers
  final String typeAndPressEnter;
  final String typeToAddTag;
  final String searchPlaceholder;

  // Validation Messages
  final String fieldRequired;
  final String invalidEmail;
  final String invalidUrl;
  final String invalidNumber;
  final String mustBeNumber;

  // Signature & Sketchpad
  final String clearSignature;
  final String clearCanvas;
  final String undoLastStroke;
  final String color;
  final String size;
  final String eraser;

  // Review Page
  final String review;
  final String reviewYourSubmission;

  // Wizard
  final String noStepsConfigured;
  final String noEntriesAdded;

  const FormioLocale({
    // Buttons & Actions
    this.submit = 'Submit',
    this.cancel = 'Cancel',
    this.clear = 'Clear',
    this.undo = 'Undo',
    this.next = 'Next',
    this.previous = 'Previous',
    this.complete = 'Complete',
    this.add = 'Add',
    this.addAnother = 'Add Another',
    this.addEntry = 'Add Entry',
    this.edit = 'Edit',
    this.save = 'Save',
    this.remove = 'Remove',
    this.delete = 'Delete',

    // File
    this.uploadFile = 'Upload File',
    this.noFileSelected = 'No file selected',
    this.fileSelected = 'file selected',
    this.filesSelected = 'files selected',

    // DataSource
    this.fetching = 'Fetching',
    this.dataSourceError = 'DataSource Error',

    // DataGrid
    this.removeRow = 'Remove Row',
    this.editRow = 'Edit Row',
    this.saveRow = 'Save Row',
    this.cancelEdit = 'Cancel Edit',

    // DataTable
    this.showing = 'Showing',
    this.of = 'of',
    this.rowsPerPage = 'Rows per page',
    this.rowSelected = 'row selected',
    this.rowsSelected = 'rows selected',
    this.noDataAvailable = 'No data available',

    // Wizard
    this.step = 'Step',
    this.stepOf = 'of',

    // Generic
    this.required = 'required',
    this.isRequired = 'is required',
    this.noData = 'No data',
    this.noDataToReview = 'No data to review',
    this.noOptions = 'No options',
    this.empty = '(empty)',
    this.none = '(none)',
    this.yes = 'Yes',
    this.no = 'No',
    this.actions = 'Actions',

    // Input
    this.typeAndPressEnter = 'Type and press Enter',
    this.typeToAddTag = 'Type and press Enter to add tag',
    this.searchPlaceholder = 'Search...',

    // Validation
    this.fieldRequired = 'This field is required',
    this.invalidEmail = 'Invalid email address',
    this.invalidUrl = 'Invalid URL',
    this.invalidNumber = 'Invalid number',
    this.mustBeNumber = 'Must be a number',

    // Signature & Sketchpad
    this.clearSignature = 'Clear',
    this.clearCanvas = 'Clear',
    this.undoLastStroke = 'Undo',
    this.color = 'Color',
    this.size = 'Size',
    this.eraser = 'Eraser',

    // Review
    this.review = 'Review',
    this.reviewYourSubmission = 'Review Your Submission',

    // Wizard
    this.noStepsConfigured = 'No wizard steps configured',
    this.noEntriesAdded = 'No entries added yet',
  });

  /// Turkish locale
  factory FormioLocale.tr() => const FormioLocale(
        submit: 'Gönder',
        cancel: 'İptal',
        clear: 'Temizle',
        undo: 'Geri Al',
        next: 'İleri',
        previous: 'Geri',
        complete: 'Tamamla',
        add: 'Ekle',
        addAnother: 'Başka Ekle',
        addEntry: 'Giriş Ekle',
        edit: 'Düzenle',
        save: 'Kaydet',
        remove: 'Kaldır',
        delete: 'Sil',
        uploadFile: 'Dosya Yükle',
        noFileSelected: 'Dosya seçilmedi',
        fileSelected: 'dosya seçildi',
        filesSelected: 'dosya seçildi',
        fetching: 'Yükleniyor',
        dataSourceError: 'Veri Kaynağı Hatası',
        removeRow: 'Satırı Kaldır',
        editRow: 'Satırı Düzenle',
        saveRow: 'Satırı Kaydet',
        cancelEdit: 'Düzenlemeyi İptal Et',
        showing: 'Gösterilen',
        of: '/',
        rowsPerPage: 'Sayfa başına satır',
        rowSelected: 'satır seçildi',
        rowsSelected: 'satır seçildi',
        noDataAvailable: 'Veri yok',
        step: 'Adım',
        stepOf: '/',
        required: 'gerekli',
        isRequired: 'gereklidir',
        noData: 'Veri yok',
        noDataToReview: 'İncelenecek veri yok',
        noOptions: 'Seçenek yok',
        empty: '(boş)',
        none: '(yok)',
        yes: 'Evet',
        no: 'Hayır',
        actions: 'İşlemler',
        typeAndPressEnter: 'Yazın ve Enter\'a basın',
        typeToAddTag: 'Etiket eklemek için yazın ve Enter\'a basın',
        searchPlaceholder: 'Ara...',
        fieldRequired: 'Bu alan gereklidir',
        invalidEmail: 'Geçersiz e-posta adresi',
        invalidUrl: 'Geçersiz URL',
        invalidNumber: 'Geçersiz sayı',
        mustBeNumber: 'Sayı olmalıdır',
        clearSignature: 'Temizle',
        clearCanvas: 'Temizle',
        undoLastStroke: 'Geri Al',
        color: 'Renk',
        size: 'Boyut',
        eraser: 'Silgi',
        review: 'İnceleme',
        reviewYourSubmission: 'Gönderiminizi İnceleyin',
        noStepsConfigured: 'Adım yapılandırılmamış',
        noEntriesAdded: 'Henüz giriş eklenmedi',
      );

  /// Get required message for a field
  String getRequiredMessage(String fieldLabel) => '$fieldLabel $isRequired.';

  /// Get file count message
  String getFileCountMessage(int count) {
    if (count == 0) return noFileSelected;
    if (count == 1) return '1 $fileSelected';
    return '$count $filesSelected';
  }

  /// Get showing range message for DataTable
  String getShowingMessage(int start, int end, int total) => '$showing $start-$end $of $total';

  /// Get selected rows message
  String getSelectedRowsMessage(int count) {
    if (count == 1) return '1 $rowSelected';
    return '$count $rowsSelected';
  }

  /// Get step progress message
  String getStepMessage(int current, int total) => '$step $current $stepOf $total';
}
