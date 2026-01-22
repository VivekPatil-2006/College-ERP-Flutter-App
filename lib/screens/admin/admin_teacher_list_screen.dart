import 'dart:io';

import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/firestore_service.dart';
import '../../models/admin_student_model.dart';
import 'admin_teacher_profile_screen.dart';

class AdminTeacherListScreen extends StatefulWidget {
  const AdminTeacherListScreen({super.key});

  @override
  State<AdminTeacherListScreen> createState() =>
      _AdminTeacherListScreenState();
}

class _AdminTeacherListScreenState extends State<AdminTeacherListScreen> {

  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController searchController = TextEditingController();

  List<AdminStudent> teachers = [];

  int limit = 10;
  String sortType = "recent";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadTeachers();
  }

  // ================= LOAD TEACHERS =================

  Future<void> loadTeachers() async {

    setState(() => loading = true);

    var data = await firestoreService.getTeachers(limit: limit);

    if (sortType == "name") {
      data.sort((a, b) => a.name.compareTo(b.name));
    }

    setState(() {
      teachers = data;
      loading = false;
    });
  }

  // ================= SEARCH =================

  Future<void> searchTeachers() async {

    if (searchController.text.isEmpty) {
      loadTeachers();
      return;
    }

    setState(() => loading = true);

    var data =
    await firestoreService.searchTeachers(searchController.text);

    setState(() {
      teachers = data;
      loading = false;
    });
  }

  // ================= LOAD MORE =================

  void loadMore() {
    limit += 10;
    loadTeachers();
  }

  // ================= DELETE CONFIRM =================

  void confirmDelete(AdminStudent teacher) {

    showDialog(
      context: context,

      builder: (_) => AlertDialog(
        title: const Text("Delete Teacher"),
        content: Text(
          "Are you sure you want to remove ${teacher.name}?",
        ),

        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),

            onPressed: () async {

              Navigator.pop(context);

              await firestoreService.deleteTeacher(teacher.id);
              loadTeachers();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Teacher Deleted")),
              );
            },

            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ================= EXPORT CSV =================

  Future<void> exportCSV() async {

    if (teachers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No data to export")),
      );
      return;
    }

    List<List<String>> rows = [];

    rows.add(["ID", "Name", "Email", "Phone"]);

    for (var t in teachers) {
      rows.add([t.id, t.name, t.email, t.phone]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getExternalStorageDirectory();
    final path = "${directory!.path}/teachers.csv";

    final file = File(path);
    await file.writeAsString(csvData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("CSV Exported\n$path"),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Teacher Management"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        tooltip: "Export CSV",
        child: const Icon(Icons.download),
        onPressed: exportCSV,
      ),

      body: Column(
        children: [

          // ================= SEARCH =================

          Padding(
            padding: const EdgeInsets.all(12),

            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(30),

              child: TextField(
                controller: searchController,
                onChanged: (_) => searchTeachers(),

                decoration: InputDecoration(
                  hintText: "Search teacher name or email",
                  prefixIcon: const Icon(Icons.search),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // ================= HEADER =================

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Row(
                  children: [

                    const Icon(Icons.people, size: 18),

                    const SizedBox(width: 6),

                    Text(
                      "Total Teachers: ${teachers.length}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                DropdownButton<String>(
                  value: sortType,
                  underline: const SizedBox(),

                  items: const [

                    DropdownMenuItem(
                      value: "recent",
                      child: Text("Recent"),
                    ),

                    DropdownMenuItem(
                      value: "name",
                      child: Text("Name A-Z"),
                    ),
                  ],

                  onChanged: (value) {

                    setState(() => sortType = value!);
                    loadTeachers();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ================= LIST =================

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())

                : teachers.isEmpty
                ? emptyState()

                : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: teachers.length,

              itemBuilder: (context, index) {

                final teacher = teachers[index];

                return Dismissible(

                  key: ValueKey(teacher.id),
                  direction: DismissDirection.endToStart,

                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),

                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),

                  confirmDismiss: (_) async {

                    confirmDelete(teacher);
                    return false;
                  },

                  child: teacherCard(teacher),
                );
              },
            ),
          ),

          // ================= LOAD MORE =================

          Padding(
            padding: const EdgeInsets.all(12),

            child: SizedBox(
              width: double.infinity,
              height: 45,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.expand_more),
                label: const Text("Load More"),

                onPressed: loadMore,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= TEACHER CARD =================

  Widget teacherCard(AdminStudent teacher) {

    return Card(
      elevation: 3,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(

        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.green.shade100,

          child: Text(
            teacher.name.isNotEmpty
                ? teacher.name[0].toUpperCase()
                : "?",

            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),

        title: Text(
          teacher.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),

        subtitle: Text(
          teacher.email,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),

        onTap: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AdminTeacherProfileScreen(
                    teacherId: teacher.id,
                  ),
            ),
          );
        },
      ),
    );
  }

  // ================= EMPTY STATE =================

  Widget emptyState() {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: const [

          Icon(
            Icons.school_outlined,
            size: 90,
            color: Colors.grey,
          ),

          SizedBox(height: 10),

          Text(
            "No Teachers Found",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
