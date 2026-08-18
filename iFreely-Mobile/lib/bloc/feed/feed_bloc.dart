import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flut/consts/hive_consts.dart';
import 'package:flut/models/feed_card.dart';
import 'package:flut/repos/feed_repo.dart';
import 'package:flut/ui/feed_gig_card.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepo _feedRepo;

  FeedBloc(this._feedRepo) : super(FeedState(selected_feed: FeedCard.empty())) {
    on<FeedLoad>(_load_feed);
    on<FeedSelectCard>(_select_card);
  }

  _load_feed(FeedLoad event, emit) async {
    emit(state.copyWith(status: FeedStatus.loading, error: FeedError.none));

    try {
      var feed = await _feedRepo.load_freelancer_feed(
        event.date,
        event.rate,
        event.type,
        event.query,
      );
      emit(state.copyWith(feed: feed));
    } catch (feed_error) {
      emit(state.copyWith(
        status: FeedStatus.error,
      ));
      rethrow;
    }
    emit(state.copyWith(status: FeedStatus.loaded, error: FeedError.none));
  }

  _select_card(FeedSelectCard event, emit) async {
    emit(state.copyWith(selected_feed: event.feed_card));
  }
}
