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
* dry-monads to handle the results from the Meals modules

## Possible improvements

* More test coverage - I decided against covering the sign in and sign up functionality as it is provided by Devise and 
it is well tested, but as important as it is, it might be covered by tests
* Dependency between `Meals` and `TheMealDB` - `TheMealDB` has to be aware of the `Meals::Meal` structure to translate
the data from the API to the `Meals::Meal` attributes. It does not create those objects directly, but it still has to
know about the structure. Maybe it would be better to have a separate module that would be responsible for translating
the data from the API to the `Meals::Meal` structure.

## Disclaimer

Some images were generated using AI service (logo, splash background, default user image)
