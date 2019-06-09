# Album Tags Phoenix

## Overview
This project is an experimental re-write of the business layer of the [Album Tags](https://github.com/jhunschejones/Album-Tags) application using the Phoenix framework and Ecto. Initially, this will just be an exercise to see how the app's data will work with these new tools. I am expecting I will face some challenges with this process as I start reconstructing some of the more complex data relationships using a different ORM. This will include the self-referencing, many-to-many relationship of "album connections," and the matches-all-in-array behavior of "tag searching."

## Process
I will be working with a local development instance of Postgres, then moving to a cloud database in production as the project progresses. The first step will be setting up the initial database migrations along with the models and all data relationships. I will also create a simple seed file to allow me to test migrating up and down while still having access to example data to see that everything is working as intended. After that is completed, I will fill out resourceful routing and controller code to preform as many of the basic functions of the app as possible. I am interested by the concept of 'contexts' introduced in Phoenix 1.4, and I will be exploring how these allow me to abstract more business logic out of my controllers than I might have done in v1.2.

## Tooling
This project includes a Ruby script called `asset_builder` for creating custom compiled versions of JavaScript and style resources, allowing the app to ship a more compact asset bundle to the user.

#### Setup:
1. Download [closure compiler](~https://developers.google.com/closure/compiler/docs/gettingstarted_app~) and update the path to the closure compiler jar file in `/config/asset_builder_config.yml`
2. `brew install sass/sass/sass`
3. `cd assets && npm install`
4. Review the remaining path information in `asset_builder_config.yml` and update if needed

#### Use:
*these commands are written to be run from the project root directory*
* `ruby ./assets/asset_builder.rb` will compile all materialize resources
* `ruby ./assets/asset_builder.rb {page_name}` will compile all custom resources for a particular page
* `ruby ./assets/asset_builder.rb {page_name} [js, scss, css]` you can pass in a second parameter to only compile one type of assets
