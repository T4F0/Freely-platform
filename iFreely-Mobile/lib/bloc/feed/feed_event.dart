part of 'feed_bloc.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object> get props => [];
}


class FeedLoad extends FeedEvent {
  String? rate = null;
  String? date = null;
  String? type = null;
  String? query = null;
  FeedLoad({this.rate,this.date,this.type,this.query});
}
class FeedSelectCard extends FeedEvent {
  FeedCard feed_card;
  FeedSelectCard(this.feed_card);

  @override
  List<Object> get props => [feed_card];

}
