final class AppLifecycleDraftHandler {
  AppLifecycleDraftHandler();

  String? _pendingPosDraftJson;
  String? _pendingStockDraftJson;
  DateTime? _draftSavedAt;

  bool get hasRecoverableDraft =>
      _pendingPosDraftJson != null || _pendingStockDraftJson != null;

  String? get pendingPosDraftJson => _pendingPosDraftJson;
  String? get pendingStockDraftJson => _pendingStockDraftJson;
  DateTime? get draftSavedAt => _draftSavedAt;

  void savePosDraft(String draftJson) {
    _pendingPosDraftJson = draftJson;
    _draftSavedAt = DateTime.now();
  }

  void saveStockDraft(String draftJson) {
    _pendingStockDraftJson = draftJson;
    _draftSavedAt = DateTime.now();
  }

  void clearPosDraft() {
    _pendingPosDraftJson = null;
    if (_pendingStockDraftJson == null) {
      _draftSavedAt = null;
    }
  }

  void clearStockDraft() {
    _pendingStockDraftJson = null;
    if (_pendingPosDraftJson == null) {
      _draftSavedAt = null;
    }
  }

  void clearAllDrafts() {
    _pendingPosDraftJson = null;
    _pendingStockDraftJson = null;
    _draftSavedAt = null;
  }
}
