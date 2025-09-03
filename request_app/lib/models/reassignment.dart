
import 'package:request_app/models/request.dart';
import 'package:request_app/models/user.dart';

class Reassignment {
  const Reassignment(
    this.request,
    this.reassignedFrom,
    this.reassignedTo,
    this.reassignedAt,
  );

  final Request request;
  final User reassignedFrom;
  final User reassignedTo;
  final DateTime reassignedAt;
}