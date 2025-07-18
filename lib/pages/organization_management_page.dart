import 'package:flutter/material.dart';
import 'package:microrealeaste/database/models/organization.dart';
import 'package:microrealeaste/database/models/user.dart';
import 'package:microrealeaste/database/data_service.dart';
import 'package:uuid/uuid.dart';
import 'package:microrealeaste/providers/auth_provider.dart';

/// Organization management page for Super Admin and Organization Admin
class OrganizationManagementPage extends StatefulWidget {
  const OrganizationManagementPage({Key? key}) : super(key: key);

  @override
  State<OrganizationManagementPage> createState() => _OrganizationManagementPageState();
}

class _OrganizationManagementPageState extends State<OrganizationManagementPage> {
  List<Organization> _organizations = [];
  bool _isLoading = true;
  final _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    setState(() {
      _organizations = DataService.organizations;
      _isLoading = false;
    });
  }

  void _showCreateOrganizationDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final addressController = TextEditingController();
    final logoUrlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Organization'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Organization Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: logoUrlController,
                decoration: const InputDecoration(labelText: 'Logo URL (optional)'),
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
            onPressed: () async {
              final org = Organization(
                id: _uuid.v4(),
                name: nameController.text.trim(),
                description: descriptionController.text.trim(),
                logoUrl: logoUrlController.text.trim().isEmpty ? null : logoUrlController.text.trim(),
                address: addressController.text.trim(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              await DataService.addOrganization(org);
              setState(() {
                _organizations = DataService.organizations;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Organization created')));
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showInviteMemberDialog(Organization org) {
    final emailController = TextEditingController();
    UserRole selectedRole = UserRole.organizationAdmin;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Invite Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: UserRole.values
                    .where((role) => role != UserRole.superAdmin)
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.name),
                        ))
                    .toList(),
                onChanged: (role) => setState(() => selectedRole = role!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Add a new user with the invited email, role, and org
                final user = User(
                  id: _uuid.v4(),
                  email: emailController.text.trim(),
                  firstName: '',
                  lastName: '',
                  role: selectedRole,
                  organizationId: org.id,
                  organizationIds: [org.id],
                  currentOrganizationId: org.id,
                  rolesByOrg: {org.id: selectedRole},
                  isActive: true,
                  emailVerified: false,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await DataService.addUser(user);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member invited')));
              },
              child: const Text('Invite'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditOrganizationDialog(Organization org) {
    final nameController = TextEditingController(text: org.name);
    final descriptionController = TextEditingController(text: org.description);
    final addressController = TextEditingController(text: org.address);
    final logoUrlController = TextEditingController(text: org.logoUrl ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Organization'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Organization Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: logoUrlController,
                decoration: const InputDecoration(labelText: 'Logo URL (optional)'),
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
            onPressed: () async {
              final updatedOrg = org.copyWith(
                name: nameController.text.trim(),
                description: descriptionController.text.trim(),
                address: addressController.text.trim(),
                logoUrl: logoUrlController.text.trim().isEmpty ? null : logoUrlController.text.trim(),
                updatedAt: DateTime.now(),
              );
              await DataService.updateOrganization(updatedOrg);
              setState(() {
                _organizations = DataService.organizations;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Organization updated')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteOrganization(Organization org) async {
    await DataService.deleteOrganization(org.id);
    setState(() {
      _organizations = DataService.organizations;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Organization deleted')));
  }

  void _showMembersDialog(Organization org) {
    final users = DataService.users.where((u) => u.organizationIds.contains(org.id)).toList();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Members of ${org.name}'),
          content: SizedBox(
            width: 400,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final currentRole = user.rolesByOrg[org.id] ?? user.role;
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user.email),
                  subtitle: Text(currentRole.name),
                  trailing: DropdownButton<UserRole>(
                    value: currentRole,
                    items: UserRole.values
                        .where((role) => role != UserRole.superAdmin)
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role.name),
                            ))
                        .toList(),
                    onChanged: (role) async {
                      if (role != null) {
                        final updatedUser = user.copyWith(
                          rolesByOrg: {
                            ...user.rolesByOrg,
                            org.id: role,
                          },
                        );
                        await DataService.updateUser(updatedUser);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Role updated for ${user.email}')),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            onPressed: _showCreateOrganizationDialog,
            tooltip: 'Create Organization',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _organizations.length,
              itemBuilder: (context, index) {
                final org = _organizations[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: org.logoUrl != null
                        ? CircleAvatar(backgroundImage: NetworkImage(org.logoUrl!))
                        : const CircleAvatar(child: Icon(Icons.business)),
                    title: Text(org.name),
                    subtitle: Text(org.description),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'invite') _showInviteMemberDialog(org);
                        if (value == 'edit') _showEditOrganizationDialog(org);
                        if (value == 'delete') _deleteOrganization(org);
                        if (value == 'members') _showMembersDialog(org);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'invite', child: Text('Invite Member')),
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        const PopupMenuItem(value: 'members', child: Text('Manage Members')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
} 