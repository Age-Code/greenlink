class ApiPaths {
  // Auth
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';

  // User
  static const String userMe = '/users/me';

  // Home
  static const String home = '/home';

  // UserItem
  static const String userItems = '/user-items';
  static String equipPot(int userItemId) => '/user-items/$userItemId/equip-pot';
  static String unequipPot(int userItemId) => '/user-items/$userItemId/unequip-pot';
  static String useNutrient(int userItemId) => '/user-items/$userItemId/use-nutrient';

  // UserPlant
  static const String userPlants = '/user-plants';
  static String userPlantDetail(int userPlantId) => '/user-plants/$userPlantId';
  static String harvestUserPlant(int userPlantId) => '/user-plants/$userPlantId/harvest';

  // Collection
  static const String collections = '/collections';
  static String collectionDetail(int plantId) => '/collections/$plantId';

  // Quest
  static const String userQuests = '/user-quests';
  static String userQuestDetail(int userQuestId) => '/user-quests/$userQuestId';
  static String receiveQuestReward(int userQuestId) => '/user-quests/$userQuestId/reward';

  // Attend
  static const String attends = '/attends';
  static const String attendToday = '/attends/today';
}
