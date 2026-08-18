// ignore_for_file: must_be_immutable
part of 'feed_bloc.dart';

enum FeedStatus {loading, loaded, error}
enum FeedError {none , network}
class FeedState extends Equatable {
  List<FeedCard> feed; 
  FeedCard selected_feed;
  FeedStatus status;   
  FeedError error;   


  FeedState({
    this.feed = const [],
    this.status = FeedStatus.loaded,
    this.error =  FeedError.none,
    required this.selected_feed,
  });

  FeedState copyWith({
    List<FeedCard>? feed, 
    FeedStatus? status, 
    FeedError? error, 
    FeedCard? selected_feed 
  }) => FeedState(
    feed : feed ?? this.feed, 
    status : status ?? FeedStatus.loaded, 
    error : error ?? FeedError.none, 
    selected_feed : selected_feed ?? this.selected_feed, 
  );

  @override
  List<Object> get props => [feed,status,error,selected_feed];


}

