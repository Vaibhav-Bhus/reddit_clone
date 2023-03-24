import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/providers/storage_repository_provider.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/repository/community_repository.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

final searchCommunityProvider = StreamProvider.family((ref,String query)  {
  
  return ref.watch(communintyControllerProvider.notifier).searchCommuniity(query);
});


final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communintyControllerProvider.notifier);
  return communityController.getUserCommunity();
});
final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(communintyControllerProvider.notifier)
      .getCommunityName(name);
});

final communintyControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  final storageReppository = ref.watch(storageRepositoryProvider);
  return CommunityController(
      storageRepository: storageReppository,
      communityRepository: communityRepository,
      ref: ref);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  CommunityController(
      {required CommunityRepository communityRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _communityRepository = communityRepository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';
    Community community = Community(
        name: name,
        id: name,
        banner: Constants.bannerDefault,
        avatar: Constants.avatarDefault,
        members: [uid],
        mods: [uid]);
    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Community created successfully!');
      Routemaster.of(context).pop();
    });
  }

  Stream<Community> getCommunityName(String name) {
    return _communityRepository.getCommunityName(name);
  }

  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    // required Uint8List? profileWebFile,
    // required Uint8List? bannerWebFile,
    required BuildContext context,
    required Community community,
  }) async {
    state = true;
    if (profileFile != null) {
      // communities/profile/memes
      final res = await _storageRepository.storeFile(
        path: 'communities/profile',
        id: community.name,
        file: profileFile,
        // webFile: profileWebFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(avatar: r),
      );
    }

    if (bannerFile != null) {
      // communities/banner/memes
      final res = await _storageRepository.storeFile(
        path: 'communities/banner',
        id: community.name,
        file: bannerFile,
        // webFile: bannerWebFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(banner: r),
      );
    }

    final res = await _communityRepository.editCommunity(community);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  Stream<List<Community>> getUserCommunity() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunities(uid);
  }

  Stream<List<Community>> searchCommuniity(String query) {
    return _communityRepository.searchCommuniity(query);
  }
}
