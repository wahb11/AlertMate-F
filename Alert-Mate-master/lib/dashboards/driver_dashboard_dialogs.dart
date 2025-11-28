  // Add Contact Dialog
  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final relationshipController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    String priority = 'secondary';
    List<String> methods = ['call'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Emergency Contact'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: relationshipController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'primary', child: Text('Primary')),
                    DropdownMenuItem(value: 'secondary', child: Text('Secondary')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      priority = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Contact Methods:', style: TextStyle(fontWeight: FontWeight.bold)),
                CheckboxListTile(
                  title: const Text('Phone Call'),
                  value: methods.contains('call'),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        methods.add('call');
                      } else {
                        methods.remove('call');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('SMS'),
                  value: methods.contains('sms'),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        methods.add('sms');
                      } else {
                        methods.remove('sms');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Email'),
                  value: methods.contains('email'),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        methods.add('email');
                      } else {
                        methods.remove('email');
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || 
                    relationshipController.text.isEmpty || 
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                  return;
                }
                
                setState(() {
                  _emergencyContacts.add({
                    'name': nameController.text,
                    'relationship': relationshipController.text,
                    'phone': phoneController.text,
                    'email': emailController.text,
                    'priority': priority,
                    'methods': methods,
                    'enabled': true,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${nameController.text} added to emergency contacts')),
                );
              },
              child: const Text('Add Contact'),
            ),
          ],
        ),
      ),
    );
  }

  // Edit Contact Dialog
  void _showEditContactDialog(int index) {
    final contact = _emergencyContacts[index];
    final nameController = TextEditingController(text: contact['name']);
    final relationshipController = TextEditingController(text: contact['relationship']);
    final phoneController = TextEditingController(text: contact['phone']);
    final emailController = TextEditingController(text: contact['email']);
    String priority = contact['priority'];
    List<String> methods = List<String>.from(contact['methods']);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Emergency Contact'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: relationshipController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'primary', child: Text('Primary')),
                    DropdownMenuItem(value: 'secondary', child: Text('Secondary')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      priority = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Contact Methods:', style: TextStyle(fontWeight: FontWeight.bold)),
                CheckboxListTile(
                  title: const Text('Phone Call'),
                  value: methods.contains('call'),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        methods.add('call');
                      } else {
                        methods.remove('call');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('SMS'),
                  value: methods.contains('sms'),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        methods.add('sms');
                      } else {
                        methods.remove('sms');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Email'),
                  value: methods.contains('email'),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        methods.add('email');
                      } else {
                        methods.remove('email');
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || 
                    relationshipController.text.isEmpty || 
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                  return;
                }
                
                setState(() {
                  _emergencyContacts[index] = {
                    'name': nameController.text,
                    'relationship': relationshipController.text,
                    'phone': phoneController.text,
                    'email': emailController.text,
                    'priority': priority,
                    'methods': methods,
                    'enabled': contact['enabled'],
                  };
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${nameController.text} updated successfully')),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

