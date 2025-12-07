import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/contact.dart';

final contactsProvider = Provider<List<Contact>>((ref) {
  // Mock data for now
  return [
    const Contact(
      id: '1',
      name: 'Alice Johnson',
      avatarUrl: '',
      status: AvailabilityStatus.available,
      statusMessage: 'Free to chat!',
    ),
    const Contact(
      id: '2',
      name: 'Bob Smith',
      avatarUrl: '',
      status: AvailabilityStatus.busy,
      statusMessage: 'In a meeting',
    ),
    const Contact(
      id: '3',
      name: 'Carol Williams',
      avatarUrl: '',
      status: AvailabilityStatus.available,
    ),
    const Contact(
      id: '4',
      name: 'David Brown',
      avatarUrl: '',
      status: AvailabilityStatus.away,
      statusMessage: 'Be right back',
    ),
    const Contact(
      id: '5',
      name: 'Emma Davis',
      avatarUrl: '',
      status: AvailabilityStatus.offline,
    ),
    const Contact(
      id: '6',
      name: 'Frank Miller',
      avatarUrl: '',
      status: AvailabilityStatus.available,
      statusMessage: 'Working from home',
    ),
    const Contact(
      id: '7',
      name: 'Grace Lee',
      avatarUrl: '',
      status: AvailabilityStatus.offline,
    ),
    const Contact(
      id: '8',
      name: 'Henry Wilson',
      avatarUrl: '',
      status: AvailabilityStatus.busy,
    ),
  ];
});

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final filteredContactsProvider = Provider<List<Contact>>((ref) {
  final contacts = ref.watch(contactsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  if (query.isEmpty) {
    return contacts;
  }

  return contacts
      .where((contact) => contact.name.toLowerCase().contains(query))
      .toList();
});
