// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:sti_app/presentation/extensions/extensions.dart';

// import '../../misc/constants.dart';
// import '../../misc/methods.dart';
// import '../../providers/router/router_provider.dart';
// import '../../providers/user_data/user_data_provider.dart';
// import '../../widgets/sti_text_field_widget.dart';

// class RegisterPage extends ConsumerStatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   ConsumerState<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends ConsumerState<RegisterPage> {
//   final nameController = TextEditingController();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();
//   String selectedRole = 'santri'; // Default role

//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Listen untuk navigasi setelah register
//     ref.listen(
//       userDataProvider,
//       (previous, next) {
//         if (next is AsyncData && next.value != null) {
//           ref.read(routerProvider).goNamed('main');
//         } else if (next is AsyncError) {
//           context.showSnackBar(next.error.toString());
//         }
//       },
//     );

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back,
//             color: AppColors.neutral900,
//           ),
//           onPressed: () {
//             if (context.canPop()) {
//               context.goNamed('login');
//             } else {
//               context.go('/login');
//             }
//           },
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Daftar Akun',
//                 style: GoogleFonts.plusJakartaSans(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.neutral900,
//                 ),
//               ),
//               verticalSpace(8),
//               Text(
//                 'Lengkapi data diri Anda',
//                 style: GoogleFonts.plusJakartaSans(
//                   fontSize: 16,
//                   color: AppColors.neutral600,
//                 ),
//               ),
//               verticalSpace(32),

//               // Name TextField
//               STITextField(
//                 labelText: 'Nama Lengkap',
//                 controller: nameController,
//                 prefixIcon: const Icon(Icons.person_outline,
//                     color: AppColors.neutral600),
//               ),

//               verticalSpace(16),

//               // Email TextField
//               STITextField(
//                 labelText: 'Email',
//                 controller: emailController,
//                 prefixIcon: const Icon(Icons.email_outlined,
//                     color: AppColors.neutral600),
//                 keyboardType: TextInputType.emailAddress,
//               ),

//               verticalSpace(16),

//               // Password TextField
//               STITextField(
//                 labelText: 'Password',
//                 controller: passwordController,
//                 obscureText: true,
//                 prefixIcon:
//                     const Icon(Icons.lock_outline, color: AppColors.neutral600),
//               ),

//               verticalSpace(16),

//               // Confirm Password TextField
//               STITextField(
//                 labelText: 'Konfirmasi Password',
//                 controller: confirmPasswordController,
//                 obscureText: true,
//                 prefixIcon:
//                     const Icon(Icons.lock_outline, color: AppColors.neutral600),
//               ),

//               verticalSpace(16),

//               // Role Selection
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: AppColors.neutral300),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.people_outline,
//                         color: AppColors.neutral600),
//                     horizontalSpace(12),
//                     Expanded(
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           value: selectedRole,
//                           items: const [
//                             DropdownMenuItem(
//                               value: 'santri',
//                               child: Text('Santri'),
//                             ),
//                             DropdownMenuItem(
//                               value: 'admin',
//                               child: Text('Admin'),
//                             ),
//                           ],
//                           onChanged: (value) {
//                             setState(() {
//                               selectedRole = value!;
//                             });
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               verticalSpace(32),

//               // Register Button
//               Consumer(
//                 builder: (context, ref, child) {
//                   final userState = ref.watch(userDataProvider);

//                   return ElevatedButton(
//                     onPressed: userState is AsyncLoading
//                         ? null
//                         : () {
//                             // Validasi input
//                             if (passwordController.text !=
//                                 confirmPasswordController.text) {
//                               context.showSnackBar('Password tidak sama');
//                               return;
//                             }

//                             // Proses register
//                             ref.read(userDataProvider.notifier).register(
//                                   name: nameController.text,
//                                   email: emailController.text,
//                                   password: passwordController.text,
//                                   role: selectedRole,
//                                 );
//                           },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       minimumSize: const Size(double.infinity, 56),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                     child: userState is AsyncLoading
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                         : Text(
//                             'Daftar',
//                             style: GoogleFonts.plusJakartaSans(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                           ),
//                   );
//                 },
//               ),

//               verticalSpace(16),

//               // Login Link
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Sudah punya akun? ',
//                     style: GoogleFonts.plusJakartaSans(
//                       color: AppColors.neutral600,
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () => context.goNamed('login'),
//                     child: Text(
//                       'Masuk',
//                       style: GoogleFonts.plusJakartaSans(
//                         color: AppColors.primary,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../extensions/extensions.dart';
import '../../misc/constants.dart';
import '../../misc/methods.dart';
import '../../providers/router/router_provider.dart';
import '../../providers/user_data/user_data_provider.dart';
import '../../widgets/sti_text_field_widget.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  DateTime? selectedDate;
  String selectedRole = 'santri';
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    if (value.length < 10 || value.length > 13) {
      return 'Nomor telepon harus 10-13 digit';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != passwordController.text) {
      return 'Password tidak sama';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      userDataProvider,
      (previous, next) {
        if (next is AsyncData && next.value != null) {
          ref.read(routerProvider).goNamed('main');
        } else if (next is AsyncError) {
          context.showSnackBar(next.error.toString());
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.neutral900,
          ),
          onPressed: () {
            if (context.canPop()) {
              Navigator.of(context).pop();
            } else {
              context.goNamed('login');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daftar Akun',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
                verticalSpace(8),
                Text(
                  'Lengkapi data diri Anda',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: AppColors.neutral600,
                  ),
                ),
                verticalSpace(32),

                // Name Field
                STITextField(
                  labelText: 'Nama Lengkap',
                  controller: nameController,
                  validator: (value) => _validateRequired(value, 'Nama'),
                  prefixIcon: const Icon(Icons.person_outline,
                      color: AppColors.neutral600),
                ),
                verticalSpace(16),

                // Email Field
                STITextField(
                  labelText: 'Email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: AppColors.neutral600),
                ),
                verticalSpace(16),

                // Phone Field
                STITextField(
                  labelText: 'Nomor Telepon',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  prefixIcon: const Icon(Icons.phone_outlined,
                      color: AppColors.neutral600),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13),
                  ],
                ),
                verticalSpace(16),

                // Date of Birth Field
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Tanggal Lahir',
                      prefixIcon: const Icon(Icons.calendar_today,
                          color: AppColors.neutral600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      selectedDate != null
                          ? DateFormat('dd MMMM yyyy').format(selectedDate!)
                          : 'Pilih tanggal lahir',
                      style: GoogleFonts.plusJakartaSans(
                        color: selectedDate != null
                            ? AppColors.neutral800
                            : AppColors.neutral600,
                      ),
                    ),
                  ),
                ),
                verticalSpace(16),

                // Address Field
                STITextField(
                  labelText: 'Alamat',
                  controller: addressController,
                  maxLines: 2,
                  validator: (value) => _validateRequired(value, 'Alamat'),
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      color: AppColors.neutral600),
                ),
                verticalSpace(16),

                // Password Field
                STITextField(
                  labelText: 'Password',
                  controller: passwordController,
                  obscureText: obscurePassword,
                  validator: _validatePassword,
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.neutral600),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.neutral600,
                    ),
                    onPressed: () =>
                        setState(() => obscurePassword = !obscurePassword),
                  ),
                ),
                verticalSpace(16),

                // Confirm Password Field
                STITextField(
                  labelText: 'Konfirmasi Password',
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.neutral600),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.neutral600,
                    ),
                    onPressed: () => setState(
                        () => obscureConfirmPassword = !obscureConfirmPassword),
                  ),
                ),
                verticalSpace(16),

                // Role Selection
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.neutral300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people_outline,
                          color: AppColors.neutral600),
                      horizontalSpace(12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedRole,
                            items: const [
                              DropdownMenuItem(
                                value: 'santri',
                                child: Text('Santri'),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('Admin'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedRole = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpace(32),

                // Register Button
                Consumer(
                  builder: (context, ref, child) {
                    final userState = ref.watch(userDataProvider);

                    return ElevatedButton(
                      onPressed: userState is AsyncLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                ref.read(userDataProvider.notifier).register(
                                      name: nameController.text,
                                      email: emailController.text,
                                      password: passwordController.text,
                                      role: selectedRole,
                                      phoneNumber: phoneController.text,
                                      address: addressController.text,
                                      dateOfBirth: selectedDate,
                                    );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: userState is AsyncLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Daftar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    );
                  },
                ),
                verticalSpace(16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.neutral600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.goNamed('login'),
                      child: Text(
                        'Masuk',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
