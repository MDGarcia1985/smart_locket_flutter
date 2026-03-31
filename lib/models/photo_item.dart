import 'package:hive/hive.dart';
part 'photo_item.g.dart';

@HiveType(typeId: 1)
class PhotoItem extends HiveObject {
  @HiveField(0) String id;        // uuid or filename
  @HiveField(1) String path;      // local path on device
  @HiveField(2) int width;
  @HiveField(3) int height;
  @HiveField(4) DateTime addedAt;

  PhotoItem(this.id, this.path, this.width, this.height, this.addedAt);
}