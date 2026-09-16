import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fullstack_app/app/widgets/offline_banner.dart';
import 'package:fullstack_app/app/widgets/error_retry.dart';
import 'package:fullstack_app/features/posts/presentation/providers/posts_provider.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: RefreshIndicator(
        onRefresh: () => context.read<PostsProvider>().load(),
        child: Column(
          children: [
            if (provider.isFromCache) const OfflineBanner(),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PostsProvider provider) {
    if (provider.isLoading && provider.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && provider.posts.isEmpty) {
      return ErrorRetry(
        message: provider.errorMessage!,
        onRetry: () => context.read<PostsProvider>().load(),
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: provider.posts.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final post = provider.posts[index];
        return ListTile(
          leading: CircleAvatar(child: Text('${post.id}')),
          title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
        );
      },
    );
  }
}
