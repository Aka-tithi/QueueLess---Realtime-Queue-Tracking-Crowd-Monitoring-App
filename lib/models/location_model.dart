class LocationModel {
  final String id;
  final String name;
  final String address;
  final String category;
  final int queueCount;
  final int waitTimeMinutes;
  final String status; // 'empty' | 'moderate' | 'busy'
  final double rating;
  final String icon;

  LocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.category,
    required this.queueCount,
    required this.waitTimeMinutes,
    required this.status,
    required this.rating,
    required this.icon,
  });
}

final List<LocationModel> mockLocations = [
  LocationModel(
    id: '1',
    name: 'Brac Bank Gulshan Branch',
    address: 'Gulshan, Dhaka',
    category: 'Banking',
    queueCount: 45,
    waitTimeMinutes: 20,
    status: 'busy',
    rating: 4.2,
    icon: '🏦',
  ),
  LocationModel(
    id: '2',
    name: 'Central Hospital',
    address: 'Motijheel, Dhaka',
    category: 'Healthcare',
    queueCount: 32,
    waitTimeMinutes: 15,
    status: 'moderate',
    rating: 4.5,
    icon: '🏥',
  ),
  LocationModel(
    id: '3',
    name: 'DMV Office',
    address: 'Dhanmondi, Dhaka',
    category: 'Government',
    queueCount: 18,
    waitTimeMinutes: 10,
    status: 'moderate',
    rating: 3.8,
    icon: '🏢',
  ),
];
