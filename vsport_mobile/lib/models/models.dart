/// Model tương ứng 1-1 với DTO backend (org.example.dto.api.ApiDtos).
/// Chỉ parse — không chứa business logic (nghiệp vụ nằm hoàn toàn ở server).

int _int(dynamic v) => v == null ? 0 : (v is int ? v : int.tryParse('$v') ?? 0);
int? _intOrNull(dynamic v) => v == null ? null : (v is int ? v : int.tryParse('$v'));
double _double(dynamic v) => v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);
double? _doubleOrNull(dynamic v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
bool _bool(dynamic v) => v == true;
String? _str(dynamic v) => v?.toString();

class Customer {
  Customer({
    required this.accountId,
    this.fullName,
    this.email,
    this.phone,
    this.avatar,
    this.gender,
    this.dateOfBirth,
    this.reputationScore = 0,
    this.reputationLabel,
    this.canBook = true,
    this.favoriteSportId,
  });

  final int accountId;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? gender;
  final String? dateOfBirth;
  final int reputationScore;
  final String? reputationLabel;
  final bool canBook;
  final int? favoriteSportId;

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        accountId: _int(j['accountId']),
        fullName: _str(j['fullName']),
        email: _str(j['email']),
        phone: _str(j['phone']),
        avatar: _str(j['avatar']),
        gender: _str(j['gender']),
        dateOfBirth: _str(j['dateOfBirth']),
        reputationScore: _int(j['reputationScore']),
        reputationLabel: _str(j['reputationLabel']),
        canBook: j['canBook'] != false,
        favoriteSportId: _intOrNull(j['favoriteSportId']),
      );
}

class Sport {
  Sport({required this.sportId, required this.name, this.courtCount = 0, this.facilityCount = 0});

  final int sportId;
  final String name;
  final int courtCount;
  final int facilityCount;

  factory Sport.fromJson(Map<String, dynamic> j) => Sport(
        sportId: _int(j['sportId']),
        name: _str(j['name']) ?? '',
        courtCount: _int(j['courtCount']),
        facilityCount: _int(j['facilityCount']),
      );
}

class FacilitySummary {
  FacilitySummary({
    required this.facilityId,
    required this.name,
    this.address,
    this.image,
    this.distanceKm,
    this.openNow = false,
    this.openTime,
    this.closeTime,
    this.minPrice = 0,
    this.readyCourtCount = 0,
    this.sports = const [],
    this.hasPromotion = false,
  });

  final int facilityId;
  final String name;
  final String? address;
  final String? image;
  final double? distanceKm;
  final bool openNow;
  final String? openTime;
  final String? closeTime;
  final double minPrice;
  final int readyCourtCount;
  final List<String> sports;
  final bool hasPromotion;

  factory FacilitySummary.fromJson(Map<String, dynamic> j) => FacilitySummary(
        facilityId: _int(j['facilityId']),
        name: _str(j['name']) ?? '',
        address: _str(j['address']),
        image: _str(j['image']),
        distanceKm: _doubleOrNull(j['distanceKm']),
        openNow: _bool(j['openNow']),
        openTime: _str(j['openTime']),
        closeTime: _str(j['closeTime']),
        minPrice: _double(j['minPrice']),
        readyCourtCount: _int(j['readyCourtCount']),
        sports: (j['sports'] as List?)?.map((e) => '$e').toList() ?? const [],
        hasPromotion: _bool(j['hasPromotion']),
      );
}

class FacilityDetail {
  FacilityDetail({
    required this.facilityId,
    required this.name,
    this.address,
    this.phone,
    this.description,
    this.image,
    this.openTime,
    this.closeTime,
    this.openNow = false,
    this.courts = const [],
    this.sports = const [],
    this.promotions = const [],
  });

  final int facilityId;
  final String name;
  final String? address;
  final String? phone;
  final String? description;
  final String? image;
  final String? openTime;
  final String? closeTime;
  final bool openNow;
  final List<Court> courts;
  final List<Sport> sports;
  final List<Promotion> promotions;

  factory FacilityDetail.fromJson(Map<String, dynamic> j) => FacilityDetail(
        facilityId: _int(j['facilityId']),
        name: _str(j['name']) ?? '',
        address: _str(j['address']),
        phone: _str(j['phone']),
        description: _str(j['description']),
        image: _str(j['image']),
        openTime: _str(j['openTime']),
        closeTime: _str(j['closeTime']),
        openNow: _bool(j['openNow']),
        courts: (j['courts'] as List?)?.map((e) => Court.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
        sports: (j['sports'] as List?)?.map((e) => Sport.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
        promotions:
            (j['promotions'] as List?)?.map((e) => Promotion.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      );
}

class Court {
  Court({
    required this.courtId,
    required this.name,
    this.facilityId = 0,
    this.courtTypeName,
    this.sportName,
    this.status,
    this.image,
    this.priceWithoutLight,
    this.priceWithLight,
  });

  final int courtId;
  final String name;
  final int facilityId;
  final String? courtTypeName;
  final String? sportName;
  final String? status;
  final String? image;
  final double? priceWithoutLight;
  final double? priceWithLight;

  factory Court.fromJson(Map<String, dynamic> j) => Court(
        courtId: _int(j['courtId']),
        name: _str(j['name']) ?? '',
        facilityId: _int(j['facilityId']),
        courtTypeName: _str(j['courtTypeName']),
        sportName: _str(j['sportName']),
        status: _str(j['status']),
        image: _str(j['image']),
        priceWithoutLight: _doubleOrNull(j['priceWithoutLight']),
        priceWithLight: _doubleOrNull(j['priceWithLight']),
      );
}

class Slot {
  Slot({required this.startTime, required this.endTime, required this.available, this.reason, this.price});

  final String startTime;
  final String endTime;
  final bool available;
  final String? reason;
  final double? price;

  factory Slot.fromJson(Map<String, dynamic> j) => Slot(
        startTime: _str(j['startTime']) ?? '',
        endTime: _str(j['endTime']) ?? '',
        available: _bool(j['available']),
        reason: _str(j['reason']),
        price: _doubleOrNull(j['price']),
      );
}

class Availability {
  Availability({
    required this.courtId,
    this.courtName,
    required this.date,
    this.openTime,
    this.closeTime,
    this.slots = const [],
  });

  final int courtId;
  final String? courtName;
  final String date;
  final String? openTime;
  final String? closeTime;
  final List<Slot> slots;

  factory Availability.fromJson(Map<String, dynamic> j) => Availability(
        courtId: _int(j['courtId']),
        courtName: _str(j['courtName']),
        date: _str(j['date']) ?? '',
        openTime: _str(j['openTime']),
        closeTime: _str(j['closeTime']),
        slots: (j['slots'] as List?)?.map((e) => Slot.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      );
}

class Booking {
  Booking({
    required this.bookingId,
    required this.courtId,
    this.courtName,
    this.facilityName,
    this.facilityAddress,
    this.sportName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    this.status,
    this.totalAmount,
    this.note,
    this.image,
    this.holdRemainingSeconds,
    this.cancellable = false,
    this.payable = false,
  });

  final int bookingId;
  final int courtId;
  final String? courtName;
  final String? facilityName;
  final String? facilityAddress;
  final String? sportName;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String? status;
  final double? totalAmount;
  final String? note;
  final String? image;
  final int? holdRemainingSeconds;
  final bool cancellable;
  final bool payable;

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        bookingId: _int(j['bookingId']),
        courtId: _int(j['courtId']),
        courtName: _str(j['courtName']),
        facilityName: _str(j['facilityName']),
        facilityAddress: _str(j['facilityAddress']),
        sportName: _str(j['sportName']),
        bookingDate: _str(j['bookingDate']) ?? '',
        startTime: _str(j['startTime']) ?? '',
        endTime: _str(j['endTime']) ?? '',
        status: _str(j['status']),
        totalAmount: _doubleOrNull(j['totalAmount']),
        note: _str(j['note']),
        image: _str(j['image']),
        holdRemainingSeconds: _intOrNull(j['holdRemainingSeconds']),
        cancellable: _bool(j['cancellable']),
        payable: _bool(j['payable']),
      );
}

class PaymentInfo {
  PaymentInfo({
    required this.bookingId,
    required this.amount,
    this.qrPayload,
    this.checkoutUrl,
    this.accountNumber,
    this.accountName,
    this.description,
    this.expiresAtEpoch,
  });

  final int bookingId;
  final double amount;
  final String? qrPayload;
  final String? checkoutUrl;
  final String? accountNumber;
  final String? accountName;
  final String? description;
  final int? expiresAtEpoch;

  factory PaymentInfo.fromJson(Map<String, dynamic> j) => PaymentInfo(
        bookingId: _int(j['bookingId']),
        amount: _double(j['amount']),
        qrPayload: _str(j['qrPayload']),
        checkoutUrl: _str(j['checkoutUrl']),
        accountNumber: _str(j['accountNumber']),
        accountName: _str(j['accountName']),
        description: _str(j['description']),
        expiresAtEpoch: _intOrNull(j['expiresAtEpoch']),
      );
}

class PaymentStatus {
  PaymentStatus({required this.status, required this.paid, this.message, this.remainingSeconds = 0});

  final String status;
  final bool paid;
  final String? message;
  final int remainingSeconds;

  factory PaymentStatus.fromJson(Map<String, dynamic> j) => PaymentStatus(
        status: _str(j['status']) ?? 'pending',
        paid: _bool(j['paid']),
        message: _str(j['message']),
        remainingSeconds: _int(j['remainingSeconds']),
      );
}

class Promotion {
  Promotion({required this.promotionId, required this.code, this.description, this.discountType, this.discountValue = 0, this.image});

  final int promotionId;
  final String code;
  final String? description;
  final String? discountType;
  final double discountValue;
  final String? image;

  factory Promotion.fromJson(Map<String, dynamic> j) => Promotion(
        promotionId: _int(j['promotionId']),
        code: _str(j['code']) ?? '',
        description: _str(j['description']),
        discountType: _str(j['discountType']),
        discountValue: _double(j['discountValue']),
        image: _str(j['image']),
      );
}

class AppNotification {
  AppNotification({required this.notificationId, this.title, this.content, this.type, this.read = false, this.sentAt});

  final int notificationId;
  final String? title;
  final String? content;
  final String? type;
  final bool read;
  final String? sentAt;

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        notificationId: _int(j['notificationId']),
        title: _str(j['title']),
        content: _str(j['content']),
        type: _str(j['type']),
        read: _bool(j['read']),
        sentAt: _str(j['sentAt']),
      );
}

class NotificationPage {
  NotificationPage({required this.total, required this.unread, required this.items});

  final int total;
  final int unread;
  final List<AppNotification> items;

  factory NotificationPage.fromJson(Map<String, dynamic> j) => NotificationPage(
        total: _int(j['total']),
        unread: _int(j['unread']),
        items: (j['items'] as List?)
                ?.map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

class QrProduct {
  QrProduct({required this.productId, required this.name, this.price = 0, this.unit, this.stock = 0});

  final int productId;
  final String name;
  final double price;
  final String? unit;
  final int stock;

  factory QrProduct.fromJson(Map<String, dynamic> j) => QrProduct(
        productId: _int(j['productId']),
        name: _str(j['name']) ?? '',
        price: _double(j['price']),
        unit: _str(j['unit']),
        stock: _int(j['stock']),
      );
}

class QrContext {
  QrContext({
    required this.resultCode,
    this.message,
    this.available = false,
    this.courtId,
    this.courtName,
    this.facilityName,
    this.sportName,
    this.sessionToken,
    this.availableActions = const [],
    this.products = const [],
    this.activeBookingId,
  });

  final String resultCode;
  final String? message;
  final bool available;
  final int? courtId;
  final String? courtName;
  final String? facilityName;
  final String? sportName;
  final String? sessionToken;
  final List<String> availableActions;
  final List<QrProduct> products;
  final int? activeBookingId;

  factory QrContext.fromJson(Map<String, dynamic> j) => QrContext(
        resultCode: _str(j['resultCode']) ?? 'NOT_FOUND',
        message: _str(j['message']),
        available: _bool(j['available']),
        courtId: _intOrNull(j['courtId']),
        courtName: _str(j['courtName']),
        facilityName: _str(j['facilityName']),
        sportName: _str(j['sportName']),
        sessionToken: _str(j['sessionToken']),
        availableActions: (j['availableActions'] as List?)?.map((e) => '$e').toList() ?? const [],
        products: (j['products'] as List?)?.map((e) => QrProduct.fromJson(e as Map<String, dynamic>)).toList() ??
            const [],
        activeBookingId: _intOrNull(j['activeBookingId']),
      );
}

class ServiceRequest {
  ServiceRequest({required this.requestId, this.type, this.status, this.note, this.createdAt, this.courtName});

  final int requestId;
  final String? type;
  final String? status;
  final String? note;
  final String? createdAt;
  final String? courtName;

  factory ServiceRequest.fromJson(Map<String, dynamic> j) => ServiceRequest(
        requestId: _int(j['requestId']),
        type: _str(j['type']),
        status: _str(j['status']),
        note: _str(j['note']),
        createdAt: _str(j['createdAt']),
        courtName: _str(j['courtName']),
      );
}

class CancelPreview {
  CancelPreview({
    this.cancellationAllowed = false,
    this.refundEligible = false,
    this.paid = false,
    this.refundableAmount = 0,
    this.cancellationFee = 0,
    this.reputationPenalty = 0,
    this.policyMessage,
  });

  final bool cancellationAllowed;
  final bool refundEligible;
  final bool paid;
  final double refundableAmount;
  final double cancellationFee;
  final int reputationPenalty;
  final String? policyMessage;

  factory CancelPreview.fromJson(Map<String, dynamic> j) => CancelPreview(
        cancellationAllowed: _bool(j['cancellationAllowed']),
        refundEligible: _bool(j['refundEligible']),
        paid: _bool(j['paid']),
        refundableAmount: _double(j['refundableAmount']),
        cancellationFee: _double(j['cancellationFee']),
        reputationPenalty: _int(j['reputationPenalty']),
        policyMessage: _str(j['policyMessage']),
      );
}

class HomeData {
  HomeData({
    required this.customer,
    this.sports = const [],
    this.featuredFacilities = const [],
    this.promotions = const [],
    this.upcomingBookings = const [],
    this.unreadNotifications = 0,
  });

  final Customer customer;
  final List<Sport> sports;
  final List<FacilitySummary> featuredFacilities;
  final List<Promotion> promotions;
  final List<Booking> upcomingBookings;
  final int unreadNotifications;

  factory HomeData.fromJson(Map<String, dynamic> j) => HomeData(
        customer: Customer.fromJson(j['customer'] as Map<String, dynamic>),
        sports: (j['sports'] as List?)?.map((e) => Sport.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
        featuredFacilities: (j['featuredFacilities'] as List?)
                ?.map((e) => FacilitySummary.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        promotions:
            (j['promotions'] as List?)?.map((e) => Promotion.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
        upcomingBookings:
            (j['upcomingBookings'] as List?)?.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList() ??
                const [],
        unreadNotifications: _int(j['unreadNotifications']),
      );
}
