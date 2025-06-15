// File: lib/providers/complaint_provider.dart
// Manages complaint data and notifies listeners on changes
import 'package:flutter/material.dart';
import 'package:university_asset_maintenance/helpers/db_helper.dart';
import 'package:university_asset_maintenance/models/complaint_model.dart';

class ComplaintProvider with ChangeNotifier {
  List<Complaint> _myComplaints = [];
  List<Complaint> get myComplaints => _myComplaints;

  // Load complaints for a given teacher
  Future<void> loadComplaintsForTeacher(int teacherId) async {
    _myComplaints = await DBHelper.getComplaintsByTeacher(teacherId);
    notifyListeners();
  }

  // Load all complaints (for admin)
  Future<void> loadAllComplaints() async {
    _myComplaints = await DBHelper.getAllComplaints();
    notifyListeners();
  }

  // Add a new complaint to the database
  Future<void> addComplaint(Complaint complaint) async {
    await DBHelper.insertComplaint(complaint);
    notifyListeners();
  }

  // Update a complaint (e.g., status change)
  Future<void> updateComplaint(Complaint complaint) async {
    await DBHelper.updateComplaint(complaint);
    notifyListeners();
  }
}
