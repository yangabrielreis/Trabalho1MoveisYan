import 'package:flutter/material.dart';
import 'package:nba_app1/service/api_basketball_service.dart';

class ViewTeam extends StatelessWidget {
  final int teamId;
  final String name;
  final String? imageUrl;
  final String? country;

  const ViewTeam({
    super.key,
    required this.teamId,
    required this.name,
    this.imageUrl,
    this.country,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                ),
                child: imageUrl != null 
                  ? Image.network(imageUrl!, height: 100, width: 100)
                  : const Icon(Icons.sports_basketball, size: 80, color: Colors.indigo),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              name, 
              style: const TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: Colors.indigo
              ),
              textAlign: TextAlign.center,
            ),
            if (country != null) 
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  country!, 
                  style: TextStyle(color: Colors.grey[600], fontSize: 16)
                ),
              ),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Divider(),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Temporada 2022-2023",
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.indigo
                ),
              ),
            ),
            const SizedBox(height: 20),

            FutureBuilder<Map<String, dynamic>>(
              future: ApiBasketballService().getTeamStatistics(teamId: teamId, season: '2022-2023'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.indigo)
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("Erro ao carregar: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
                    )
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text("Sem dados disponíveis"));
                }

                final stats = snapshot.data!;

                try {
                  final games = stats['games'];
                  final wins = games['wins']['all']['total'] ?? 0;
                  final loses = games['loses']['all']['total'] ?? 0;
                  final played = games['played']['all'] ?? 0;
                  final pointsAvg = stats['points']['for']['average']['all'] ?? '0';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard("Jogos", played.toString(), Colors.indigo),
                            _buildStatCard("Vitórias", wins.toString(), Colors.green),
                            _buildStatCard("Derrotas", loses.toString(), Colors.red),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Pontos por Jogo",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      pointsAvg.toString(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.show_chart, color: Colors.indigo, size: 36),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                } catch (e) {
                  return Center(child: Text("Erro ao processar os dados: $e"));
                }
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
