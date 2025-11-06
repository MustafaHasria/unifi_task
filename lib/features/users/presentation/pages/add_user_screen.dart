import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/native_toast_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';

class AddUserScreen extends StatelessWidget {
  const AddUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UserBloc>(),
      child: const _AddUserScreenContent(),
    );
  }
}

class _AddUserScreenContent extends StatefulWidget {
  const _AddUserScreenContent();

  @override
  State<_AddUserScreenContent> createState() => _AddUserScreenContentState();
}

class _AddUserScreenContentState extends State<_AddUserScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedGender = 'male';
  String _selectedStatus = 'active';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<UserBloc>().add(
            AddUserEvent(
              name: _nameController.text,
              email: _emailController.text,
              gender: _selectedGender,
              status: _selectedStatus,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New User'),
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserAdded) {
            // Show native toast
            getIt<NativeToastService>().showSuccess('User added successfully!');
            
            // Also show Flutter SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('User added successfully!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
            context.pop(true);
          } else if (state is UserAddError) {
            // Show native toast
            getIt<NativeToastService>().showError(state.message);
            
            // Also show Flutter SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is UserAdding;

          return AbsorbPointer(
            absorbing: isLoading,
            child: Opacity(
              opacity: isLoading ? 0.6 : 1.0,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'Enter full name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      SizedBox(height: 16.h),

                      // Email field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter email address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an email';
                          }
                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Gender dropdown
                      DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.wc_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'male',
                            child: Text('Male'),
                          ),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('Female'),
                          ),
                        ],
                        onChanged: isLoading ? null : (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Status dropdown
                      DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(Icons.toggle_on_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: 'inactive',
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: isLoading ? null : (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                      SizedBox(height: 32.h),

                      // Submit button
                      ElevatedButton(
                        onPressed: isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Add User'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

