import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/productsResponse.dart';
import '../providers/apiProvider.dart';


class ProductDetailScreen extends StatelessWidget {
  static const routeName = 'product-details';

  @override
  Widget build(BuildContext context) {
    final ApiProvider provider = Provider.of<ApiProvider>(context,listen: true);

    final Product product = ModalRoute.of(context)!.settings.arguments as Product;

    final isLiked = provider.isLiked(product);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                    child: Image.network(
                      product.thumbnail,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
        
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Expanded(
                    child: Text(
                      product.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  // Like Button
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
