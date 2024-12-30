import 'package:flutter/material.dart';
import 'api_services.dart';

class FetchItems extends StatefulWidget {
  @override
  _FetchItemsState createState() => _FetchItemsState();
}

class _FetchItemsState extends State<FetchItems> {
  final ApiService _apiService = ApiService();
  late Future<List<Post>> futurePosts;
  Set<int> expandedItems = {};
  List<Post> allPosts = [];
  List<Post> filteredPosts = [];
  TextEditingController searchController = TextEditingController();
  bool isAscending = true;
  bool isFilterApplied = false;

  @override
  void initState() {
    super.initState();
    futurePosts = _apiService.fetchPosts();
  }

  void toggleExpanded(int index) {
    setState(() {
      if (expandedItems.contains(index)) {
        expandedItems.remove(index);
      } else {
        expandedItems.add(index);
      }
    });
  }

  void filterPosts(String query) {
    setState(() {
      // First filter by search query
      if (query.isEmpty) {
        filteredPosts = List.from(allPosts);
      } else {
        filteredPosts = allPosts
            .where((post) =>
                post.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }

      // Then sort based on isAscending
      if (isFilterApplied) {
        filteredPosts.sort((a, b) =>
            isAscending ? a.id.compareTo(b.id) : b.id.compareTo(a.id));
      }
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sort by ID'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('1 to ${allPosts.length}'),
                leading: Icon(Icons.arrow_upward),
                selected: isAscending && isFilterApplied,
                onTap: () {
                  setState(() {
                    isAscending = true;
                    isFilterApplied = true;
                    filterPosts(searchController.text);
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('${allPosts.length} to 1'),
                leading: Icon(Icons.arrow_downward),
                selected: !isAscending && isFilterApplied,
                onTap: () {
                  setState(() {
                    isAscending = false;
                    isFilterApplied = true;
                    filterPosts(searchController.text);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Clear Sort'),
              onPressed: () {
                setState(() {
                  isFilterApplied = false;
                  filterPosts(searchController.text);
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Old Posts'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search posts...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: filterPosts,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isFilterApplied ? Colors.blue : null,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: IconButton(
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFilterApplied
                              ? (isAscending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward)
                              : Icons.filter_list,
                          color: isFilterApplied ? Colors.white : null,
                        ),
                      ],
                    ),
                    onPressed: _showFilterDialog,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: futurePosts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Initialize allPosts and filteredPosts only once when data is loaded
                if (allPosts.isEmpty && snapshot.hasData) {
                  allPosts = snapshot.data!;
                  filteredPosts = List.from(allPosts);
                }

                if (filteredPosts.isEmpty) {
                  return Center(
                    child: Text('No posts found'),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    bool isExpanded = expandedItems.contains(index);
                    return Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: Text(
                              '${filteredPosts[index].id}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            title: Text(
                              filteredPosts[index].title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                              onPressed: () => toggleExpanded(index),
                            ),
                            onTap: () => toggleExpanded(index),
                          ),
                          if (isExpanded)
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Container(
                                width: double.infinity,
                                child: Text(
                                  filteredPosts[index].body,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}