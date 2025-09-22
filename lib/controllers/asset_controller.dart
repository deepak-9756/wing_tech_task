// controllers/asset_controller.dart
import 'package:get/get.dart';
import 'package:wing_tech_task/models/assets_model.dart';
 import '../services/firebase_service.dart';

class AssetController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  
  final RxList<Asset> assets = <Asset>[].obs;
  final RxInt totalAssets = 0.obs;
  final RxInt availableAssets = 0.obs;
  final RxInt checkedOutAssets = 0.obs;
  final RxInt overdueAssets = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAssets();
    loadOverdueAssets();
  }

  void loadAssets() {
    _firebaseService.getAssets().listen((assetList) {
      assets.value = assetList;
      totalAssets.value = assetList.length;
      availableAssets.value = assetList.where((asset) => asset.isAvailable).length;
      checkedOutAssets.value = assetList.where((asset) => !asset.isAvailable).length;
    });
  }

  void loadOverdueAssets() {
    _firebaseService.getOverdueAssets().listen((overdueList) {
      overdueAssets.value = overdueList.length;
    });
  }

  Future<Asset?> getAssetByQR(String qrCode) async {
    return assets.firstWhereOrNull((asset) => asset.qrCode == qrCode);
  }

  Future<void> addAsset(Asset asset) async {
    await _firebaseService.addAsset(asset);
  }

  Future<void> checkOutAsset(String assetId, String userName, String userEmail, DateTime expectedReturn) async {
    await _firebaseService.checkOutAsset(assetId, userName, userEmail, expectedReturn);
  }

  Future<void> checkInAsset(String assetId) async {
    await _firebaseService.checkInAsset(assetId);
  }
}
