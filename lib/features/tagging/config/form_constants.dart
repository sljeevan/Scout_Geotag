class FormOptions {
  static const projectStages = [
    'Planning',
    'Design',
    'Tender',
    'Construction',
    'Completed',
  ];

  static const buildingTypes = [
    'Office',
    'IT Park',
    'Mall',
    'Mixed Use',
    'Corporate HQ',
  ];

  static const certifications = ['LEED', 'IGBC', 'GRIHA', 'EDGE'];
  static const certificationTargets = ['Silver', 'Gold', 'Platinum'];

  static const residentialTypes = [
    'Apartment',
    'Villa',
    'Township',
    'Gated Community',
  ];

  static const targetSegments = ['Affordable', 'Premium', 'Luxury'];

  static const hospitalityTypes = [
    'Hotel',
    'Resort',
    'Club',
    'Convention Center'
  ];
  static const starRatings = ['3 Star', '4 Star', '5 Star'];

  static const specializations = ['Residential', 'Commercial', 'Hospitality'];
  static const involvementStages = ['Concept', 'Design', 'Execution'];
  static const developerScales = ['Local', 'Regional', 'National'];
}

class ValidationPatterns {
  static const email = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
  static const phone = r'^\+?[0-9\-\s]{8,20}$';
  static const website = r'^(https?:\/\/)?([\w-]+\.)+[\w-]{2,}(\/.*)?$';
}

class FormVersion {
  static const formVersion = 2;
  static const schemaVersion = 2;
}
