import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_developer_assignment_task/model/search_product.dart';
import 'package:flutter_developer_assignment_task/repo/product_repo.dart';

import '../../bloc/product_search/product_search_bloc.dart';

class SearchComponents extends StatefulWidget {
  const SearchComponents({super.key});

  @override
  State<SearchComponents> createState() => _SearchComponentsState();
}

class _SearchComponentsState extends State<SearchComponents> {
  late List<Product> searchList;
  @override
  void initState() {
    searchList = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductSearchBloc(context.read<ProductRepository>()),
      child: BlocListener<ProductSearchBloc, ProductSearchState>(
        listener: (_, state) {
          if (state is SearchStateLoadSuccess) {
            searchList = state.searchList.products;
          }
        },

        child: Builder(
          builder: (context) {
            return SearchAnchor.bar(
              barHintText: 'Search...',

              barLeading: const Icon(Icons.search),
              barPadding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onChanged: (value) async {
                context.read<ProductSearchBloc>().add(
                  SearchTextChanged(query: value),
                );
              },
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                    return searchList.map(
                      (e) => ListTile(
                        title: Text(e.title),
                        onTap: () => controller.closeView(e.title),
                      ),
                    );
                  },
            );
          },
        ),
      ),
    );
  }
}
