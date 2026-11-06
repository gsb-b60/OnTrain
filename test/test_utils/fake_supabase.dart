import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// A minimal PostgREST filter builder that records calls and resolves to [rows].
///
/// The repositories under test only use chainable filters and then await the
/// builder, so a recording fake is enough and keeps the tests independent of
/// Supabase's generated mocks.
class FakePostgrestFilterBuilder<T> implements PostgrestFilterBuilder<T> {
  FakePostgrestFilterBuilder(this.response) : error = null;

  FakePostgrestFilterBuilder.error(this.error) : response = null;

  final T? response;
  final Object? error;
  final List<Invocation> invocations = [];

  List<List<Object?>> callsTo(Symbol member) => invocations
      .where((invocation) => invocation.memberName == member)
      .map((invocation) => invocation.positionalArguments)
      .toList();

  T _responseAfterFilters() {
    final rows = response;
    if (rows is! PostgrestList) return rows as T;

    var filtered = rows as PostgrestList;
    for (final invocation in invocations) {
      final args = invocation.positionalArguments;
      if (invocation.memberName == #eq) {
        filtered = filtered
            .where((row) => row[args[0] as String] == args[1])
            .toList();
      } else if (invocation.memberName == #isFilter) {
        filtered = filtered
            .where((row) => row[args[0] as String] == args[1])
            .toList();
      } else if (invocation.memberName == #not &&
          args[1] == 'is' &&
          args[2] == null) {
        filtered = filtered
            .where((row) => row[args[0] as String] != null)
            .toList();
      }
    }
    return filtered as T;
  }

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) {
    final future = error == null
        ? Future<T>.value(_responseAfterFilters())
        : Future<T>.error(error!);
    return future.then(onValue, onError: onError);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    invocations.add(invocation);
    return this;
  }
}

/// A query builder whose [select] returns [filter].
///
/// Other query builder methods are intentionally unsupported: the tests assert
/// the exact query shape instead of silently accepting unexpected calls.
class FakeSupabaseQueryBuilder implements SupabaseQueryBuilder {
  FakeSupabaseQueryBuilder(this.filter);

  final FakePostgrestFilterBuilder<PostgrestList> filter;
  final List<String> selectedColumns = [];

  @override
  PostgrestFilterBuilder<PostgrestList> select([String columns = '*']) {
    selectedColumns.add(columns);
    return filter;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnsupportedError(
      'Unexpected query builder call: ${invocation.memberName}',
    );
  }
}
