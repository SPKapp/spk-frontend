part of 'send_verification_mail.cubit.dart';

sealed class SendVerificationMailState extends Equatable {
  const SendVerificationMailState();

  @override
  List<Object> get props => [];
}

final class SendVerificationMailInitial extends SendVerificationMailState {
  const SendVerificationMailInitial();
}

final class SendVerificationMailSuccess extends SendVerificationMailState {
  const SendVerificationMailSuccess();
}

final class SendVerificationMailFailure extends SendVerificationMailState {
  const SendVerificationMailFailure();
}
