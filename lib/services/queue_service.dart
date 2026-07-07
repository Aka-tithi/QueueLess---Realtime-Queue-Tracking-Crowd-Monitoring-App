import 'package:supabase_flutter/supabase_flutter.dart';

class QueueService {
  final _supabase = Supabase.instance.client;

  /// নির্দিষ্ট লোকেশনের লাইভ কিউ ডেটা ট্র্যাক করার জন্য Stream
  Stream<List<Map<String, dynamic>>> streamLocationQueue(String locationId) {
    return _supabase
        .from('locations')
        .stream(primaryKey: ['id'])
        .eq('id', locationId);
  }
}
