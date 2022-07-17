class Default {
  String getPlantUrl() {
    return 'https://firebasestorage.googleapis.com/v0/b/garden-74604.appspot.com/o/assets-images%2Fplant.png?alt=media&token=680ea0ef-1fbe-435a-82b4-31233550bb22';
  }

  String getUserUrl() {
    return 'https://firebasestorage.googleapis.com/v0/b/garden-74604.appspot.com/o/assets-images%2Fuser.png?alt=media&token=f5541b65-3649-4f00-99c9-74c3a9817992';
  }

  String getId() {
    return DateTime.now()
        .toString()
        .replaceAll(' ', '')
        .replaceAll(':', '')
        .replaceAll('-', '')
        .replaceAll('.', '')
        .toString();
  }
}
