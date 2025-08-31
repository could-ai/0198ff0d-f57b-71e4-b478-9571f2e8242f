import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/password.dart';
import '../database/database_helper.dart';
import 'home_screen.dart';

class AddPasswordScreen extends StatefulWidget {
  final Password? password;

  AddPasswordScreen({this.password});

  @override
  _AddPasswordScreenState createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.password?.title ?? '');
    _usernameController = TextEditingController(text: widget.password?.username ?? '');
    _passwordController = TextEditingController(text: widget.password?.password ?? '');
    _notesController = TextEditingController(text: widget.password?.notes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.password == null ? 'Add Password' : 'Edit Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username/Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username or email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePassword,
                child: Text(widget.password == null ? 'Add Password' : 'Update Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _savePassword() {
    if (_formKey.currentState!.validate()) {
      final password = Password(
        id: widget.password?.id,
        title: _titleController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (widget.password == null) {
        Provider.of<PasswordProvider>(context, listen: false).addPassword(password);
      } else {
        Provider.of<PasswordProvider>(context, listen: false).updatePassword(password);
      }

      Navigator.pop(context);
    }
  }
}