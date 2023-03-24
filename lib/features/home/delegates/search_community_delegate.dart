import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class SearchCommunityDelegate extends SearchDelegate {
  final WidgetRef ref;

  SearchCommunityDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return ref.watch(searchCommunityProvider(query)).when(data: (communities)=>ListView.builder(
      itemCount: communities.length,
      itemBuilder: (BuildContext context, int index) {
        final community = communities[index];
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(community.avatar),),
          title: Text('r/${community.name}'),
          onTap: ()=>navidateToCommunity(context, community),
        );
      },
    ), error: ((error, stackTrace) => ErrorText(error: error.toString())), loading: ()=>const Loader());
  }

  void navidateToCommunity(BuildContext context,Community community){
    Routemaster.of(context).push('/r/${community.name}');
  }
}
