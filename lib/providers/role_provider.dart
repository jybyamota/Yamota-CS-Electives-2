import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_provider.dart';

final isAdminProvider = FutureProvider<bool>((ref) async {
  final client = ref.watch(supabaseProvider);
  if (client.auth.currentUser == null) return false;
  final response = await client.rpc('is_admin');
  return response == true;
});
