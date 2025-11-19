import 'package:flutter/material.dart';

class UserListTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onSelect;

  const UserListTile({super.key, required this.user, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Color(0xFFD7F7C5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.green.shade300,
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user["name"],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  user["email"],
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onSelect,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: StadiumBorder(),
            ),
            child: Text("Selecionar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
