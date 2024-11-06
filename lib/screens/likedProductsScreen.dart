import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task1/providers/apiProvider.dart';

class LikedProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ApiProvider>(context);

    return Scaffold(
      body: provider.likedProducts.isEmpty
          ? Center(child: Text('No liked products yet.'))
          : ListView.builder(
        itemCount: provider.likedProducts.length,
        itemBuilder: (ctx, index) {
          final product = provider.likedProducts[index];
          final isLiked = true;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            child: Card(
              elevation: 4,
              child: Row(
                children: [
                  // Left Image
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    child: Image.network(
                      product.thumbnail,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title.length > 10
                                ? '${product.title.substring(0, 10)}...'
                                : product.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5),
                          Text(
                            product.description.length > 20
                                ? '${product.description.substring(0, 20)}...'
                                : product.description,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      provider.toggleLike(product);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
