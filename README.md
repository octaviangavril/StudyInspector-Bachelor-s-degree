# Study Inspector - Laboratory Activity Management System

## Installation Guide

To install the Study Inspector application, follow the steps below:

1. **Clone the repository**
   Download the source code by cloning the repository from the specified location:
    ```
    git clone https://github.com/octaviangavril/StudyInspector-Bachelor-s-degree.git
    ```

2. **Configure the application**
   Configure the application according to the examples provided in:
    - `backend/src/main/resources/application.properties.example`
    - `backend/src/main/resources/service-account-credentials.json.example`

3. **Set up Google Cloud credentials**
   To obtain a configuration containing the service account credentials that communicate with the Google Sheets API and Google Drive API, refer to the official documentation:
    - [Google Workspace API Documentation](https://developers.google.com/workspace/guides/get-started)

   Create a Google Cloud project, add the Google Sheets API and Google Drive API as scopes, and then create Service Account credentials.

4. **Navigate to the project directory**
   In the terminal, navigate to the project directory:
    ```
    cd StudyInspector-Bachelor-s-degree
    ```

5. **Run the backend**
   Run the backend of the application:
    ```
    cd backend
    ./gradlew bootRun
    ```

6. **Open a new terminal and repeat step 4**
   Open a new terminal window and navigate back to the project directory as mentioned in step 4.

7. **Run the frontend**
   Run the frontend of the application, selecting the device you want to run the platform on:
    ```
    cd frontend
    flutter run -d chrome
    ```

## Technologies Used

- **Backend:** Spring Boot (Java) with Gradle
- **Frontend:** Flutter
- **APIs:** Google Sheets API, Google Drive API
- **Configuration:** Google Cloud Service Accounts

## Acknowledgements

- [Google Developers](https://developers.google.com/)
- [Flutter](https://flutter.dev/)
- [Spring Boot](https://spring.io/projects/spring-boot)
