# storyscape

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

!!! VERY EARLY STAGES !!!

## Introduction

Storyscape is an open-source project that aims to create a free ePub book reading platform. Our
mission is to provide users with a seamless and synchronized reading experience across all their
devices, allowing them to easily access and keep track of their reading progress in books from
anywhere. By leveraging the power of open source technology, we aim to build a community-driven
platform that is both user-friendly and customizable for readers worldwide.

## Desired features

1. Easy Book Downloads: Users will be able to download ePub books directly onto their devices
   through Storyscape's intuitive interface.
2. Synchronized Reading Progress: Readers can pick up where they left off on any device, ensuring a
   seamless reading experience across all platforms.
3. Customizable Reading Experience: Users will be able to personalize their reading environment with
   custom themes and font sizes for optimal comfort and enjoyment.
4. Advanced analytics to provide insights into reading habits and preferences.
5. Social sharing features to connect readers and foster a sense of community
6. Advanced Search Functionality: A powerful search engine allows users to quickly find specific
   passages or quotes within a book, enhancing their reading experience.
7. Accessibility Features: Storyscape will include features such as text-to-speech functionality and
   night mode for easier reading in low light environments.
8. Open-Source Codebase: By leveraging open source technology, developers can contribute to the
   platform's growth and evolution, ensuring that Storyscape remains a dynamic and innovative
   reading experience for users worldwide. The open-source codebase will also allow for greater
   transparency and accountability in the development process, as well as collaboration with the
   broader tech community to identify and address any issues or bugs that may arise.

## Current features

- At present, Storyscape offers the ability to display an ePub book downloaded through a user-provided
URL. This allows users to easily access their favorite books on any device with an internet
connection.
- Successfully loaded ePub books are stored locally

## Development

Storyscape combines the power of Flutter as a UI framework with the principles of clean architecture
and test-driven development (TDD). Additionally, it incorporates some Rust concepts into the Dart
codebase to further enhance its reliability. This project showcases how these
approaches can be seamlessly integrated to create a robust and maintainable software application.

It follows a clean architecture pattern, where the application logic is separated from
the presentation layer (provided by Flutter). The business logic resides in separate modules, which
are tested independently using TDD. This approach ensures that each module can be developed and
maintained without affecting the rest of the application.

To further improve performance and reliability, it incorporates Rust-style error
handling mechanisms, such as the `Result` type, to provide a more robust and
reliable way of handling errors in our Dart code. This will help us avoid null pointer exceptions
and other common errors that can occur when working with complex data structures.
