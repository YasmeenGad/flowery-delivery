import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flowery_delivery/core/networking/common/api_result.dart';
import 'package:flowery_delivery/core/networking/error/error_handler.dart';
import 'package:flowery_delivery/features/auth/presentation/apply/viewModel/apply_driver_actions.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/networking/error/error_model.dart';
import '../../../domain/entities/request/apply_request_entity.dart';
import '../../../domain/entities/response/apply_response_entity.dart';
import '../../../domain/use_cases/apply_driver_usecase.dart';

part 'apply_driver_view_model_state.dart';

@injectable
class ApplyDriverViewModelCubit extends Cubit<ApplyDriverViewModelState> {
  final ApplyDriverUseCase _useCase;

  @factoryMethod
  ApplyDriverViewModelCubit(this._useCase)
      : super(ApplyDriverViewModelInitial());

  void onAction(ApplyDriverActions action) {
    switch (action) {
      case ApplyDriverSubmit():
        _applyDriver(action.request);
        break;
    }
  }

  Future<void> _applyDriver(ApplyRequestEntity request) async {
    emit(ApplyDriverViewModelLoading());
    debugPrint(' request: $request');
    final result = await _useCase.applyDriver(request);

    switch (result) {
      case Success<ApplyResponseEntity>():
        emit(ApplyDriverViewModelSuccess(result.data));
        debugPrint(' ${result.data}');
      case Fail<ApplyResponseEntity>():
        debugPrint(' error ${result.exception}');
        emit(ApplyDriverViewModelError(ErrorHandler.handle(result.exception!)));
    }
  }
}
