# README

A simple Ruby on Rails application to randomly select a meal from a list of meals.

## Requirements

* Ruby 3.2.2
* ImageMagick
* Sqlite3
* Foreman gem

## Start up

```bash
./bin/rails db:create
./bin/rails db:migrate
./bin/dev
```

## Description

This application users TheMealDB API to fetch a random meal and display it to the user. 
Authenticated user can also add a meal to the list of favorite meals and browse the list of favorite meals.

## Used technologies

* Devise is used for user authentication 
* CarrierWave is used for image upload
* TailwindCSS is used for styling
* dry-struct and dry-types to create a simple structure for the meal data
* dry-container and dry-auto_inject to create a simple dependency injection container

## Disclaimer

Some images were generated using AI service (logo, splash background, default user image)
