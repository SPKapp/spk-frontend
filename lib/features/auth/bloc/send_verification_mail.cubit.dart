import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spk_app_frontend/features/auth/auth.service.dart';

part 'send_verification_mail.state.dart';

class SendVerificationMailCubit extends Cubit<SendVerificationMailState> {
  SendVerificationMailCubit({
    AuthService? authService,
  })  : _authService = authService ?? AuthService(),
        super(const SendVerificationMailInitial());

  final AuthService _authService;

  void sendVerificationMail() async {
    try {
      await _authService.sendVerificationMail();
      emit(const SendVerificationMailSuccess());
    } catch (_) {
      emit(const SendVerificationMailFailure());
    }
  }
}
