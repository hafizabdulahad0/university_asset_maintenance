// File: lib/models/complaint_model.dart

class Complaint {
  int?    id;
  String  title;
  String  description;
  String? mediaPath;     // path to image or video
  bool    mediaIsVideo;  // true if video, false if image
  String  status;
  int     teacherId;
  int?    staffId;

  Complaint({
    this.id,
    required this.title,
    required this.description,
    this.mediaPath,
    this.mediaIsVideo = false,
    required this.status,
    required this.teacherId,
    this.staffId,
  });

  // Convert a Complaint into a map for the database
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title':        title,
      'description':  description,
      'mediaPath':    mediaPath,
      'mediaIsVideo': mediaIsVideo ? 1 : 0,
      'status':       status,
      'teacherId':    teacherId,
      'staffId':      staffId,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Create a Complaint object from a map
  factory Complaint.fromMap(Map<String, dynamic> map) {
    return Complaint(
      id:           map['id'] as int?,
      title:        map['title'] as String,
      description:  map['description'] as String,
      mediaPath:    map['mediaPath'] as String?,
      mediaIsVideo: (map['mediaIsVideo'] as int) == 1,
      status:       map['status'] as String,
      teacherId:    map['teacherId'] as int,
      staffId:      map['staffId'] as int?,
    );
  }
}
