import 'package:ontrain/core/cancellation_policy.dart';
import 'package:ontrain/data/object/booking.dart';
import 'package:ontrain/data/object/dispute.dart';
import 'package:ontrain/data/object/payment.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/data/object/service_package.dart';
import 'package:ontrain/data/object/time_slot.dart';
import 'package:ontrain/data/object/user.dart';
import 'package:ontrain/data/enum/disputeStatus.dart';
import 'package:ontrain/model/error.dart';
import 'package:ontrain/model/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingRepository {
  final SupabaseClient _supabaseClient;

  BookingRepository({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<Result<List<Booking>>> fetchBookingByPTID(String ptId) async {
    try {
      final response = await _supabaseClient
          .from('bookings')
          .select('''
            *,
            pt_profiles!inner (
              *,
              profiles!inner (
                id,
                email,
                full_name,
                avatar_url,
                phone,
                is_verified
              )
            ),
            profiles!inner (
              id,
              email,
              full_name,
              avatar_url,
              phone,
              is_verified
            )
          ''')
          .eq('pt_id', ptId);

      final bookings = response.map((e) {
        final ptProfile = e['pt_profiles'] as Map<String, dynamic>?;
        final clientProfile = e['profiles'] as Map<String, dynamic>?;
        final pt = ptProfile != null && ptProfile['profiles'] != null
            ? PT.fromMap({
                ...ptProfile,
                ...ptProfile['profiles'] as Map<String, dynamic>,
              })
            : null;
        final client = clientProfile != null
            ? UserData.fromMap(clientProfile)
            : null;
        return Booking.fromMap({
          ...e,
          if (pt != null) 'PT': pt.toMap(),
          if (client != null) 'client': client.toMap(),
        });
      }).toList();

      return Result.success(bookings);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error fetching bookings: $e', code: 500),
      );
    }
  }

  Future<Result<List<Booking>>> fetchBookingsByClientId(String clientId) async {
    try {
      final response = await _supabaseClient
          .from('bookings')
          .select('''
            *,
            pt_profiles!inner (
              *,
              profiles!inner (
                id,
                email,
                full_name,
                avatar_url,
                phone,
                is_verified
              )
            ),
            profiles!inner (
              id,
              email,
              full_name,
              avatar_url,
              phone,
              is_verified
            )
          ''')
          .eq('client_id', clientId);

      final bookings = response.map((e) {
        final ptProfile = e['pt_profiles'] as Map<String, dynamic>?;
        final clientProfile = e['profiles'] as Map<String, dynamic>?;
        final pt = ptProfile != null && ptProfile['profiles'] != null
            ? PT.fromMap({
                ...ptProfile,
                ...ptProfile['profiles'] as Map<String, dynamic>,
              })
            : null;
        final client = clientProfile != null
            ? UserData.fromMap(clientProfile)
            : null;
        return Booking.fromMap({
          ...e,
          if (pt != null) 'PT': pt.toMap(),
          if (client != null) 'client': client.toMap(),
        });
      }).toList();

      return Result.success(bookings);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error fetching bookings: $e', code: 500),
      );
    }
  }

  Future<Result<Booking>> createBooking(Booking booking) async {
    try {
      // Use the RPC for atomic booking creation
      final bookingId = await _supabaseClient.rpc('create_booking', params: {
        'p_slot_id': booking.servicePackageId, // Note: servicePackageId is actually the time_slot id
        'p_price_cents': booking.priceCents,
        'p_platform_commission_percent': booking.platformCommissionPercent,
        'p_platform_commission_fixed_cents': booking.platformCommissionFixedCents,
        'p_pt_earnings_cents': booking.ptEarningsCents,
      });

      final response = await _supabaseClient
          .from('bookings')
          .select('''
            *,
            pt_profiles!inner (
              *,
              profiles!inner (
                id,
                email,
                full_name,
                avatar_url,
                phone,
                is_verified
              )
            ),
            profiles!inner (
              id,
              email,
              full_name,
              avatar_url,
              phone,
              is_verified
            )
          ''')
          .eq('id', bookingId)
          .single();

      final ptProfile = response['pt_profiles'] as Map<String, dynamic>?;
      final clientProfile = response['profiles'] as Map<String, dynamic>?;
      final pt = ptProfile != null && ptProfile['profiles'] != null
          ? PT.fromMap({
              ...ptProfile,
              ...ptProfile['profiles'] as Map<String, dynamic>,
            })
          : null;
      final client = clientProfile != null
          ? UserData.fromMap(clientProfile)
          : null;

      return Result.success(Booking.fromMap({
        ...response,
        if (pt != null) 'PT': pt.toMap(),
        if (client != null) 'client': client.toMap(),
      }));
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error creating booking: $e', code: 500),
      );
    }
  }

  Future<Result<void>> updateBooking(Booking booking) async {
    try {
      await _supabaseClient
          .from('bookings')
          .update(booking.toMap())
          .eq('id', booking.id!);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error updating booking: $e', code: 500),
      );
    }
  }

  Future<Result<List<ServicePackage>>> fetchServicePackages(String ptId) async {
    try {
      final response = await _supabaseClient
          .from('service_packages')
          .select()
          .eq('pt_id', ptId)
          .eq('is_active', true);

      final packages = response
          .map((e) => ServicePackage.fromMap(e))
          .toList();

      return Result.success(packages);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error fetching service packages: $e', code: 500),
      );
    }
  }

  Future<Result<List<TimeSlot>>> fetchAvailableSlots({
    required String ptId,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      dynamic query = _supabaseClient
          .from('time_slots')
          .select('*, service_packages(*)')
          .eq('pt_id', ptId)
          .eq('is_available', true)
          .eq('is_booked', false);

      if (from != null) {
        query = query.gte('start_at', from.toIso8601String());
      }
      if (to != null) {
        query = query.lte('start_at', to.toIso8601String());
      }

      query = query.order('start_at');

      final response = await query;

      final slots = response.map((e) => TimeSlot.fromMap(e)).toList();

      return Result.success(slots);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error fetching available slots: $e', code: 500),
      );
    }
  }

  Future<Result<List<TimeSlot>>> fetchSlotsForDate({
    required String ptId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return fetchAvailableSlots(ptId: ptId, from: startOfDay, to: endOfDay);
  }

  Future<Result<void>> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    try {
      await _supabaseClient
          .from('bookings')
          .update({'status': status})
          .eq('id', bookingId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error updating booking status: $e', code: 500),
      );
    }
  }

  Future<Result<void>> cancelBooking({
    required String bookingId,
    required String cancelledBy,
    String? reason,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      await _supabaseClient
          .from('bookings')
          .update({
            'status': 'cancelled_by_$cancelledBy',
            'cancelled_by': cancelledBy,
            'cancelled_at': now,
            'cancellation_reason': reason,
          })
          .eq('id', bookingId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error cancelling booking: $e', code: 500),
      );
    }
  }

  Future<Result<void>> markNoShow({
    required String bookingId,
    required String noShowBy,
  }) async {
    try {
      final status = noShowBy == 'client'
          ? 'no_show_client'
          : 'no_show_pt';
      await _supabaseClient
          .from('bookings')
          .update({
            'status': status,
            'no_show_by': noShowBy,
          })
          .eq('id', bookingId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error marking no-show: $e', code: 500),
      );
    }
  }

  /// Cancels a booking with fee calculation based on policy.
  /// Returns the updated booking with fee info, and creates refund payment if applicable.
  Future<Result<Booking>> cancelBookingWithFee({
    required String bookingId,
    required String cancelledBy, // 'client' | 'pt' | 'admin'
    String? reason,
    required CancellationPolicy policy,
  }) async {
    try {
      // Fetch booking first
      final bookingResponse = await _supabaseClient
          .from('bookings')
          .select('''
            *,
            pt_profiles!inner (
              *,
              profiles!inner (
                id, email, full_name, avatar_url, phone, is_verified
              )
            ),
            profiles!inner (
              id, email, full_name, avatar_url, phone, is_verified
            )
          ''')
          .eq('id', bookingId)
          .single();

      final booking = Booking.fromMap(bookingResponse);
      final now = DateTime.now();

      // Calculate fee
      final (feeCents, reasonCode) = policy.calculateFee(
        priceCents: booking.priceCents,
        sessionStart: booking.startAt,
        cancelledAt: now,
        cancelledBy: cancelledBy,
      );

      final refundAmountCents = booking.priceCents - feeCents;

      // Update booking with cancellation info
      final status = cancelledBy == 'admin' ? 'cancelled_by_admin' : 'cancelled_by_$cancelledBy';
      await _supabaseClient
          .from('bookings')
          .update({
            'status': status,
            'cancelled_by': cancelledBy,
            'cancelled_at': now.toIso8601String(),
            'cancellation_reason': reason ?? reasonCode,
            'cancellation_fee_cents': feeCents,
          })
          .eq('id', bookingId);

      // If there's a refund amount, create a refund payment record
      if (refundAmountCents > 0) {
        final paymentId = await _supabaseClient
            .from('payments')
            .insert({
              'booking_id': bookingId,
              'client_id': booking.clientId,
              'amount_cents': refundAmountCents,
              'platform_commission_cents': feeCents,
              'pt_amount_cents': 0,
              'payment_method': 'stripe',
              'status': 'refunded',
              'external_payment_id': 'refund_${DateTime.now().millisecondsSinceEpoch}',
            })
            .select('id')
            .single()
            .then((r) => r['id'] as String);

        // Update payment_status on booking
        await _supabaseClient
            .from('bookings')
            .update({'payment_status': 'refunded'})
            .eq('id', bookingId);
      } else if (feeCents >= booking.priceCents) {
        // Full fee, no refund
        await _supabaseClient
            .from('bookings')
            .update({'payment_status': 'no_refund'})
            .eq('id', bookingId);
      }

      // Return updated booking
      final updatedResponse = await _supabaseClient
          .from('bookings')
          .select('''
            *,
            pt_profiles!inner (
              *,
              profiles!inner (
                id, email, full_name, avatar_url, phone, is_verified
              )
            ),
            profiles!inner (
              id, email, full_name, avatar_url, phone, is_verified
            )
          ''')
          .eq('id', bookingId)
          .single();

      return Result.success(Booking.fromMap(updatedResponse));
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error cancelling booking: $e', code: 500),
      );
    }
  }

  Future<Result<void>> markNoShowWithFee({
    required String bookingId,
    required String noShowBy, // 'client' | 'pt'
    required CancellationPolicy policy,
  }) async {
    try {
      final bookingResponse = await _supabaseClient
          .from('bookings')
          .select()
          .eq('id', bookingId)
          .single();

      final booking = Booking.fromMap(bookingResponse);
      final now = DateTime.now();

      // No-show fee = 100% of price
      final (feeCents, reasonCode) = policy.calculateFee(
        priceCents: booking.priceCents,
        sessionStart: booking.startAt,
        cancelledAt: now,
        cancelledBy: noShowBy,
        isNoShow: true,
      );

      final status = noShowBy == 'client' ? 'no_show_client' : 'no_show_pt';
      await _supabaseClient
          .from('bookings')
          .update({
            'status': status,
            'no_show_by': noShowBy,
            'cancellation_fee_cents': feeCents,
            'cancellation_reason': reasonCode,
            'payment_status': 'no_refund',
          })
          .eq('id', bookingId);

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error marking no-show: $e', code: 500),
      );
    }
  }

  Future<Result<Dispute>> createDispute({
    required String bookingId,
    required String raisedBy,
    required String againstUserId,
    required String reason,
  }) async {
    try {
      final response = await _supabaseClient
          .from('disputes')
          .insert({
            'booking_id': bookingId,
            'raised_by': raisedBy,
            'against_user_id': againstUserId,
            'reason': reason,
            'status': 'open',
          })
          .select()
          .single();

      // Also update booking status to disputed
      await _supabaseClient
          .from('bookings')
          .update({'status': 'disputed'})
          .eq('id', bookingId);

      return Result.success(Dispute.fromMap(response));
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error creating dispute: $e', code: 500),
      );
    }
  }

  Future<Result<List<Dispute>>> fetchDisputesByUser(String userId) async {
    try {
      final response = await _supabaseClient
          .from('disputes')
          .select('*, bookings(*)')
          .or('raised_by.eq.$userId,and_user_id.eq.$userId')
          .order('created_at', ascending: false);

      final disputes = response.map((e) => Dispute.fromMap(e)).toList();
      return Result.success(disputes);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error fetching disputes: $e', code: 500),
      );
    }
  }

  Future<Result<void>> resolveDispute({
    required String disputeId,
    required DisputeStatus resolution,
    String? resolutionNotes,
    String? resolvedBy,
  }) async {
    try {
      final updateData = {
        'status': resolution.dbValue,
        'resolved_at': DateTime.now().toIso8601String(),
      };
      if (resolutionNotes != null) {
        updateData['resolution_notes'] = resolutionNotes;
      }
      if (resolvedBy != null) {
        updateData['resolved_by'] = resolvedBy;
      }

      await _supabaseClient
          .from('disputes')
          .update(updateData)
          .eq('id', disputeId);

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error resolving dispute: $e', code: 500),
      );
    }
  }

  Future<Result<void>> fetchCancellationPolicy() async {
    // This can be used to fetch policy from platform_settings if needed
    // For now, the controller passes it directly
    return Result.success(null);
  }
}