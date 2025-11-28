# Zenith - Weather app but with AI

A modern, responsive weather application built with Flutter, utilizing the **MVVM (Model-View-ViewModel)** architecture and integrated with external APIs for comprehensive weather data and engaging daily notifications via the **Gemini API**.

## App Demo

## Features

* **Current Weather:** Real-time display of temperature, conditions, and location-specific data.
* **5-Day Forecast:** Detailed forecast view to help users plan ahead.
* **MVVM Architecture:** Clean, scalable, and maintainable codebase structure using the MVVM pattern.
* **Dual API Integration:**
    * **Weather API:** Fetches and displays accurate meteorological information.
    * **Gemini API:** Generates unique, contextual, customizable daily notification messages based on the current and forecasted weather (e.g., "Perfect day for a run! Expect sunshine until 5 PM.").
* **State Management:** Utilizes **Riverpod** for efficient state handling.
* **Modern UI:** Developed with a responsive **Material 3 (M3)** design.

## Architecture Overview

The project is structured following the MVVM pattern for clear separation of concerns:

| Layer | Responsibility | Key Folders/Files |
| :--- | :--- | :--- |
| **Model** | Data structures and business entities. | `lib/model/` |
| **View** | UI components, screens, and user interaction. | `lib/view/` |
| **ViewModel** | Business logic, state management, and interaction with the Repository. | `lib/viewmodel/` |
| **Data** | API communication, data parsing, and storage logic. | `lib/services/`, `lib/repositories/` |

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

* **Flutter SDK** (stable channel)
* **Dart SDK**
* **An IDE** (VS Code or Android Studio) with Flutter/Dart plugins

### Installation

1.  **Clone the repository:**
    ```bash
    git clone 'GIT_REPO'
    cd zenith
    ```

2.  **Install dependencies:**
    ```bash
    flutter clean
    flutter pub get
    ```

3.  **Set up API Keys:**
    This app requires two API keys for full functionality.

    ```dart
    const String GEMINI_API_KEY = "YOUR_GEMINI_API_KEY";
    const String WEATHER_API_KEY = "YOUR_WEATHER_API_KEY";
    ```
4.  **Run the App:**
    ```bash
    flutter run
    ```
    
## Key Dependencies

| Package | Purpose |
| :--- | :--- |
| `flutter_riverpod`| State Management (connecting View and ViewModel). |
| `dio` | Handling network requests to both APIs. |
| `google_generative_ai` | Integrating the Gemini API for engaging notifications. |
| `flutter_local_notifications` | Scheduling and displaying daily, personalized messages. |
| `shared_preferences` | Local storage for user settings (e.g., default city). |

## Contributing

Contributions are welcome! If you have suggestions, bug reports, or want to add a new feature, please feel free to open an issue or submit a pull request.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Contact
[shimantosqr9@gmail.com]
