class Task{
  final String id;
  String title;
  String? text;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.text,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'title': title,
      'text': text,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map){
    return Task(
      id: map['id'],
      title: map['title'],
      text: map['text'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}