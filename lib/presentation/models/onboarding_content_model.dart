class OnboardingContent {
  final String title;
  final String description;
  final String image;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.image,
  });
}

// Data onboarding
final List<OnboardingContent> onboardingContents = [
  OnboardingContent(
    title: 'Monitoring Hafalan',
    description:
        'Pantau progress hafalan Al-Quran dengan mudah dan terstruktur',
    image: 'assets/images/onboarding1.png', // Placeholder image path
  ),
  OnboardingContent(
    title: 'Presensi Digital',
    description:
        'Absensi yang terintegrasi memudahkan pencatatan kehadiran santri',
    image: 'assets/images/onboarding2.png',
  ),
  OnboardingContent(
    title: 'Laporan Terukur',
    description:
        'Evaluasi perkembangan santri melalui laporan yang mudah dipahami',
    image: 'assets/images/onboarding3.png',
  ),
];
