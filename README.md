# iOS Technical Assignment - iTunes Music Search App

This is a simple iOS application that allows users to search for music tracks from the iTunes Store using Apple’s iTunes Search API.

## Features

- User can input a search query to find music tracks.
- Results are limited to Denmark.
- Each search result displays:
  - Track name
  - Artist name
  - Release date
  - Artwork
- Fully responsive UI using AutoLayout built programmatically.
- No third-party libraries used.
- Structured and testable codebase.
- Basic demonstration of unit test strategy included.

## Architecture

The app follows a very simple Clean Architecture design pattern to ensure separation of concerns, testability, and maintainability.

## Assumptions
- I didn't find any "short description" in the response from the API. I assume I could have used the collectionName instead but I decided to leave it out.

## Unit Testing
- I implemented a simple unit test of SearchUseCase, which is responsible for executing a search request through a service conforming to ITunesServiceProtocol.
