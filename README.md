# Hikari - Manga Reader App

A beautiful and feature-rich Flutter manga reader app built with Riverpod, Dio, and SharedPreferences. Hikari provides a seamless reading experience with support for both classic page-turning and webtoon-style vertical scrolling.

## Features

### 📱 Core Features
- **Bottom Navigation**: Easy access to Home, Favourites, and Settings
- **Manga Search**: Search through thousands of manga from MangaDex API
- **Favourites System**: Save your favorite manga locally with SharedPreferences
- **Chapter Reading**: Full chapter reading with image caching
- **Responsive Design**: Works perfectly on different screen sizes

### 🎨 UI/UX Features
- **Theme Support**: Light, Dark, and System theme modes
- **Reading Modes**: 
  - **Classic Mode**: Horizontal page-turning with zoom support
  - **Webtoon Mode**: Vertical scrolling for long-form content
- **Fixed Image Layouts**: Prevents ListTile overflow issues
- **Smooth Animations**: Fluid transitions and interactions
- **Material Design 3**: Modern, beautiful interface

### 🔧 Technical Features
- **State Management**: Riverpod for reactive state management
- **API Integration**: MangaDex API with Dio for HTTP requests
- **Local Storage**: SharedPreferences for user preferences and favourites
- **Image Caching**: Cached network images for better performance
- **Error Handling**: Comprehensive error handling and loading states
- **Feature-First Architecture**: Clean, modular code structure

## Screenshots

The app includes:
- **Home Screen**: Browse popular manga and search functionality
- **Manga Detail**: View manga information, description, and chapter list
- **Reader Screen**: Immersive reading experience with customizable modes
- **Favourites Screen**: Manage your saved manga collection
- **Settings Screen**: Customize theme and reading preferences

## Architecture

### Folder Structure
```
lib/
├── core/
│   ├── models/          # Data models (Manga, Chapter, etc.)
│   ├── services/        # API and storage services
│   └── providers/       # Riverpod providers
├── features/
│   ├── home/           # Home screen and search
│   ├── manga_detail/   # Manga details and chapters
│   ├── reader/         # Reading interface
│   ├── favourites/     # Favourites management
│   └── settings/       # App settings
└── main.dart          # App entry point
```

### Key Components

#### Models
- **Manga**: Represents manga data with title, description, cover, etc.
- **Chapter**: Chapter information with pages and metadata
- **ReadingMode**: Enum for Classic/Webtoon reading modes
- **AppThemeMode**: Theme mode selection (Light/Dark/System)

#### Services
- **ApiService**: MangaDex API integration with Dio
- **StorageService**: Local storage management with SharedPreferences

#### Providers
- **Theme Providers**: Theme mode and data management
- **Reading Mode Providers**: Reading preference management
- **Favourites Providers**: Favourite manga state management
- **API Providers**: API service providers

## Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd hikari
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Dependencies

The app uses the following key dependencies:

```yaml
dependencies:
  flutter_riverpod: ^2.4.10    # State management
  dio: ^5.4.0                  # HTTP client
  shared_preferences: ^2.2.2   # Local storage
  cached_network_image: ^3.3.1 # Image caching
  flutter_staggered_grid_view: ^0.7.0 # Grid layouts
```

## Usage

### Home Screen
- Browse popular manga from MangaDex
- Use the search bar to find specific titles
- Tap on manga cards to view details
- Add manga to favourites with the heart button

### Manga Detail Screen
- View manga cover, title, and description
- See author, artist, and publication information
- Browse available chapters
- Add/remove from favourites
- Tap chapters to start reading

### Reader Screen
- **Classic Mode**: Swipe horizontally to turn pages
- **Webtoon Mode**: Scroll vertically through pages
- Tap screen to show/hide controls
- Use the menu button to switch reading modes
- Zoom in/out on images (Classic mode)

### Settings Screen
- Switch between Light, Dark, and System themes
- Choose between Classic and Webtoon reading modes
- View local data usage
- Clear all favourites if needed

## API Integration

The app integrates with the MangaDex API to provide:
- Manga search and discovery
- Chapter information and metadata
- Cover images and artwork
- Chapter page images

### API Endpoints Used
- `/manga` - Search and browse manga
- `/manga/{id}` - Get manga details
- `/manga/{id}/feed` - Get chapter list
- `/at-home/server/{chapterId}` - Get chapter images

## Performance Optimizations

- **Image Caching**: All images are cached locally for faster loading
- **Lazy Loading**: Chapters and manga load as needed
- **State Management**: Efficient state updates with Riverpod
- **Memory Management**: Proper disposal of controllers and resources

## Error Handling

The app includes comprehensive error handling:
- Network connectivity issues
- API rate limiting
- Image loading failures
- Invalid data responses
- User-friendly error messages with retry options

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- **MangaDex** for providing the free manga API
- **Flutter Team** for the amazing framework
- **Riverpod** for excellent state management
- **Material Design** for beautiful UI components

## Support

If you encounter any issues or have questions:
1. Check the existing issues on GitHub
2. Create a new issue with detailed information
3. Include device information and error logs

---

**Hikari** - Bringing light to your manga reading experience! 📚✨