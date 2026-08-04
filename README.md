# FastBite 🍔

A food ordering app that lets customers browse a menu, order meals, and track their deliveries — built with Flutter and a local SQLite database.

## Features

- 🔐 **Account system** — register and log in, with hashed passwords and persistent sessions (stay logged in between app launches)
- 🍽️ **Browse the menu** — search by name and filter by category
- 🛒 **Cart management** — add items, adjust quantities, see a live price breakdown (subtotal, delivery fee, total)
- 📦 **Order placement** — checkout with a delivery address to place an order
- 📋 **Order tracking** — view order history with status badges, cancel an order, or mark it as received
- 💾 **Offline-first** — all data (accounts, menu, cart, orders) is stored locally on-device, no backend server required

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| State management | [Provider](https://pub.dev/packages/provider) |
| Local database | [sqflite](https://pub.dev/packages/sqflite) (SQLite) |
| Session persistence | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| Password hashing | [crypto](https://pub.dev/packages/crypto) |

## Screenshots

<!-- Add screenshots here, e.g.: -->
<!-- <img src="screenshots/home.png" width="250" /> <img src="screenshots/cart.png" width="250" /> <img src="screenshots/orders.png" width="250" /> -->

## Project Structure