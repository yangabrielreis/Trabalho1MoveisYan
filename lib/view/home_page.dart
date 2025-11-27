import 'package:flutter/material.dart';
import 'package:nba_app1/service/api_basketball_service.dart';
import 'package:nba_app1/view/view_team.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _teams = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTeams();
    });
  }

  Future<void> _fetchTeams({String? query}) async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final String? searchTerm = (query != null && query.isNotEmpty) ? query : null;

      final result = await ApiBasketballService().getTeamsNBA(
        season: '2022-2023', 
        search: searchTerm, 
      );

      final filteredList = result.where((team) {
        final name = team['name'].toString();
        return !name.startsWith('Team');
      }).toList();

      setState(() {
        _teams = filteredList;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = "Erro: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'NBA Times',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ), 
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Pesquisar time',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _fetchTeams();
                      },
                    )
                  : null,
              ),
              onChanged: (val) {
                setState(() {}); 
              },
              onSubmitted: (value) => _fetchTeams(query: value),
            ),
          ),
          Expanded(
            child: _buildListContent(),
          ),
        ],
      ),
    ); 
  }

  Widget _buildListContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 10),
            Text(_errorMessage),
            TextButton(
              onPressed: () => _fetchTeams(),
              child: const Text("Recarregar"),
            )
          ],
        ),
      );
    }

    if (_teams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            Text("Nenhum time encontrado para '${_searchController.text}'"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                _fetchTeams();
              },
              child: const Text("Voltar para lista completa"),
            )
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _teams.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final team = _teams[index];
        
        int teamId = 0;
        if (team is Map) {
          teamId = int.tryParse(team['id'].toString()) ?? 0;
        } else {
          try { teamId = (team as dynamic).id; } catch (_) {}
        }

        String name = '';
        String? imageUrl;
        
        if (team is Map) {
          name = (team['name'] ?? '').toString();
          imageUrl = (team['logo'] as String?) ?? '';
          if (imageUrl.isEmpty) imageUrl = null;
        }

        return ListTile(
          leading: imageUrl != null
              ? CircleAvatar(backgroundImage: NetworkImage(imageUrl), backgroundColor: Colors.transparent)
              : const CircleAvatar(child: Icon(Icons.sports_basketball)),
          title: Text(name),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewTeam(
                  teamId: teamId,
                  name: name,
                  imageUrl: imageUrl,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
