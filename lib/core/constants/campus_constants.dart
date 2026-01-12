/// Constantes pour les données du campus de Ngaoundéré
import '../../../features/map/domain/entities/place.dart';

class CampusConstants {
  // Coordonnées du campus de l'Université de Ngaoundéré
  static const double campusLatitude = 6.4254;
  static const double campusLongitude = 13.5900;
  static const String campusName = 'Université de Ngaoundéré';

  /// POIs par défaut du campus
  static final List<Place> defaultCampusPois = [
    const Place(
      id: '1',
      name: 'Amphi 500',
      category: 'amphithéâtre',
      latitude: 6.4260,
      longitude: 13.5905,
      description: 'Grand amphithéâtre - Capacité 500 places',
      address: 'Campus Principal',
      tags: ['enseignement', 'amphithéâtre'],
    ),
    const Place(
      id: '2',
      name: 'Bibliothèque Centrale',
      category: 'bibliothèque',
      latitude: 6.4255,
      longitude: 13.5895,
      description: 'Bibliothèque avec 50 000 ouvrages',
      address: 'Campus Principal',
      tags: ['ressources', 'étude'],
    ),
    const Place(
      id: '3',
      name: 'Restaurant Universitaire',
      category: 'restauration',
      latitude: 6.4250,
      longitude: 13.5900,
      description: 'Restauration pour les étudiants',
      address: 'Campus Principal',
      tags: ['repas', 'service'],
    ),
    const Place(
      id: '4',
      name: 'Cité Universitaire A',
      category: 'logement',
      latitude: 6.4265,
      longitude: 13.5910,
      description: 'Résidence pour 200 étudiants',
      address: 'Campus Principal',
      tags: ['logement', 'résidence'],
    ),
    const Place(
      id: '5',
      name: 'Centre de Santé',
      category: 'santé',
      latitude: 6.4245,
      longitude: 13.5890,
      description: 'Centre médical du campus',
      address: 'Campus Principal',
      tags: ['santé', 'médical'],
    ),
    const Place(
      id: '6',
      name: 'Stade Omnisports',
      category: 'sport',
      latitude: 6.4240,
      longitude: 13.5885,
      description: 'Terrain de sport et installations',
      address: 'Campus Principal',
      tags: ['sport', 'loisir'],
    ),
    const Place(
      id: '7',
      name: 'Laboratoire Informatique',
      category: 'éducation',
      latitude: 6.4258,
      longitude: 13.5902,
      description: 'Labo avec 50 ordinateurs',
      address: 'Campus Principal',
      tags: ['informatique', 'enseignement'],
    ),
    const Place(
      id: '8',
      name: 'Secrétariat Principal',
      category: 'administration',
      latitude: 6.4252,
      longitude: 13.5898,
      description: 'Bâtiment administratif',
      address: 'Campus Principal',
      tags: ['admin', 'services'],
    ),
  ];
}
