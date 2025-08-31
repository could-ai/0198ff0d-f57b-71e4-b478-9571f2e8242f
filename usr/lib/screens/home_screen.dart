import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/password.dart';
import '../database/database_helper.dart';
import 'add_password_screen.dart';

class PasswordProvider with ChangeNotifier {
  List<Password> _passwords = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Password> get passwords => _passwords;

  Future<void> loadPasswords() async {
    _passwords = await _dbHelper.getPasswords();
    notifyListeners();
  }

  Future<void> addPassword(Password password) async {
    await _dbHelper.insertPassword(password);
    await loadPasswords();
  }

  Future<void> updatePassword(Password password) async {
    await _dbHelper.updatePassword(password);
    await loadPasswords();
  }

  Future<void> deletePassword(int id) async {
    await _dbHelper.deletePassword(id);
    await loadPasswords();
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<PasswordProvider>(context, listen: false).loadPasswords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPasswordScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<PasswordProvider>(
        builder: (context, provider, child) {
          if (provider.passwords.isEmpty) {
            return Center(
              child: Text('No passwords saved yet. Tap + to add one.'),
            );
          }
          return ListView.builder(
            itemCount: provider.passwords.length,
            itemBuilder: (context, index) {
              final password = provider.passwords[index];
              return ListTile(
                title: Text(password.title),
                subtitle: Text(password.username),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPasswordScreen(password: password),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _showDeleteDialog(context, password.id!);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  _showPasswordDialog(context, password);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Password'),
          content: Text('Are you sure you want to delete this password?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Provider.of<PasswordProvider>(context, listen: false).deletePassword(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPasswordDialog(BuildContext context, Password password) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(password.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Username: ${password.username}'),
              Text('Password: ${password.password}'),
              if (password.notes != null && password.notes!.isNotEmpty)
                Text('Notes: ${password.notes}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}