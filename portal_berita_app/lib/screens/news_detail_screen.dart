import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/news_provider.dart';
import '../services/api_service.dart';
import '../models/comment.dart';

class NewsDetailScreen extends StatefulWidget {
  final int newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final _commentController = TextEditingController();
  final _apiService = ApiService();
  List<Comment> _comments = [];
  bool _isLoadingComments = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false)
          .fetchNewsDetail(widget.newsId);
      _loadComments();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    _comments = await _apiService.getComments(widget.newsId);
    setState(() => _isLoadingComments = false);
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final result = await _apiService.addComment(widget.newsId, _commentController.text);
    if (result['success']) {
      _commentController.clear();
      await _loadComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NewsProvider, AuthProvider>(
      builder: (context, newsProvider, authProvider, child) {
        final news = newsProvider.selectedNews;

        return Scaffold(
          appBar: AppBar(
            title: Text('News Detail', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
          body: newsProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : news == null
                  ? const Center(child: Text('News not found'))
                  : RefreshIndicator(
                      onRefresh: () async {
                        await newsProvider.fetchNewsDetail(widget.newsId);
                        await _loadComments();
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (news.image != null)
                              CachedNetworkImage(
                                imageUrl: news.image!,
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 250,
                                  color: Colors.grey.shade300,
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 250,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (news.category != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade700,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        news.category!,
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  Text(news.title, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        news.user?.name ?? 'Unknown',
                                        style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey.shade600),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('dd MMM yyyy, HH:mm').format(news.createdAt),
                                        style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(news.content, style: GoogleFonts.roboto(fontSize: 16, height: 1.6)),
                                  const SizedBox(height: 24),
                                  const Divider(),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Comments (${_comments.length})',
                                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  if (authProvider.isAuthenticated)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _commentController,
                                            decoration: InputDecoration(
                                              hintText: 'Write a comment...',
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            maxLines: null,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed: _addComment,
                                          icon: const Icon(Icons.send),
                                          color: Colors.blue.shade700,
                                          iconSize: 30,
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 16),
                                  _isLoadingComments
                                      ? const Center(child: CircularProgressIndicator())
                                      : _comments.isEmpty
                                          ? Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(32.0),
                                                child: Text('No comments yet', style: GoogleFonts.roboto(color: Colors.grey.shade600)),
                                              ),
                                            )
                                          : ListView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: _comments.length,
                                              itemBuilder: (context, index) {
                                                final comment = _comments[index];
                                                return Card(
                                                  margin: const EdgeInsets.only(bottom: 12),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(12),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundColor: Colors.blue.shade700,
                                                              child: Text(
                                                                comment.user?.name.substring(0, 1).toUpperCase() ?? 'U',
                                                                style: const TextStyle(color: Colors.white),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 12),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    comment.user?.name ?? 'Unknown',
                                                                    style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                                                                  ),
                                                                  Text(
                                                                    DateFormat('dd MMM yyyy, HH:mm').format(comment.createdAt),
                                                                    style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey.shade600),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Text(comment.content, style: GoogleFonts.roboto()),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        );
      },
    );
  }
}
