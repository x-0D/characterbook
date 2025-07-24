import 'package:hive/hive.dart';
import 'package:characterbook/models/folder_model.dart';

class FolderService {
  final Box<Folder> _folderBox;

  FolderService(this._folderBox);

  Future<Folder> createFolder({
    required String name,
    required FolderType type,
    String? parentId,
    int? colorValue,
  }) async {
    final folder = Folder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      parentId: parentId,
      colorValue: colorValue,
    );
    await _folderBox.put(folder.id, folder);
    return folder;
  }

  List<Folder> getFoldersByType(FolderType type, {String? parentId}) {
    return _folderBox.values
        .where((folder) => folder.type == type && folder.parentId == parentId)
        .toList();
  }

  Folder? getFolderById(String id) {
    return _folderBox.get(id);
  }

  Future<void> updateFolder(Folder folder) async {
    folder.updatedAt = DateTime.now();
    await _folderBox.put(folder.id, folder);
  }

  Future<void> deleteFolder(String id) async {
    final hasSubfolders = _folderBox.values.any((f) => f.parentId == id);
    if (hasSubfolders) {
      throw Exception('Нельзя удалить папку, содержащую вложенные папки');
    }
    
    await _folderBox.delete(id);
  }

  Future<void> addToFolder(String folderId, String contentId) async {
    final folder = _folderBox.get(folderId);
    if (folder != null) {
      if (!folder.contentIds.contains(contentId)) {
        folder.contentIds.add(contentId);
        await updateFolder(folder);
      }
    }
  }

  Future<void> removeFromFolder(String folderId, String contentId) async {
    final folder = _folderBox.get(folderId);
    if (folder != null) {
      folder.contentIds.remove(contentId);
      await updateFolder(folder);
    }
  }

  Future<void> moveBetweenFolders(
    String contentId,
    String fromFolderId,
    String toFolderId,
  ) async {
    await removeFromFolder(fromFolderId, contentId);
    await addToFolder(toFolderId, contentId);
  }

  List<String> getFolderContents(String folderId) {
    return _folderBox.get(folderId)?.contentIds ?? [];
  }

  List<Folder> searchFolders(String query, {FolderType? type}) {
    return _folderBox.values
        .where((folder) => 
          folder.name.toLowerCase().contains(query.toLowerCase()) &&
          (type == null || folder.type == type))
        .toList();
  }
}