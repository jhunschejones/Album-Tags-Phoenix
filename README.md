# Album Tags Phoenix

## Overview
Album Tags is an application that I have been maintaining since March of 2017. It has undergone several significant changes and re-writes and I am very proud of this third major release. The app is hosted in the cloud and allows users to curate and share custom tags, lists, and connections for their favorite albums. Check out the live app [here](https://www.albumtags.com/) to give it a spin for yourself, or browse through my [favorites list](https://www.albumtags.com/lists/65) to see one way users can combine all this powerful functionality to create an easily curated collection.

Other features of the app include the ability to search by tags, filter albums displayed in lists, and follow chains of album connections to find records from your collection you might have even forgot about over time!

## Process
I built this third release of Album Tags from the ground up, using Elixir and the Phoenix framework along with Ecto and a few other great Elixir tools. It includes a custom build tool for compiling my assets that slides right in alongside Phoenix's live-reload for faster development. The process I followed to complete the app is roughly as follows:

* I built out the contexts and data models
* I put together the tools required for my front-end build pipeline
* I built out the controllers and views for the static pages
* I built out the SPA for the lists page
* I built [tooling](https://github.com/jhunschejones/Album-Tags-Utilities/tree/master/album-tags-3-migration) for migrating the previous application data to the new database
* I filled out the test suite to improve coverage and catch additional edge cases
* I conducted user testing to improve app-flow and usability
* I used the New Relic Elixir agent to monitor the application in production and make some significant performance improvements to decrease the load time of several heavy pages

## Lessons Learned
Building Album Tags 3 from the ground up was an incredibly educational experience. I had the opportunity to revisit some foundational decisions made in earlier versions of the app and improve the design of elements that needed to be updated. A few areas where these improvements really stand out are the new UI, the new data models, and the test suite.

In previous versions of Album Tags I used Bootstrap and a _lot_ of custom styling and JavaScript to present the UI. I built in a hybrid of desktop and mobile design in an attempt to accommodate both worlds. This time around, I did the vast majority of the app design mobile-first using the more modern Materialize framework. The majority of the app's users take advantage of this tool on mobile devices, so this approach helped me make sure the important features were easy to get to on the screens where they would be accessed the most. I fully committed to using the new front-end framework as well, including a custom asset build tool that enabled me to customize the source code and ship the best version of the framework for my exact needs.

As Album Tags moved from MongoDB into a relational database, several of the data models remained somewhat bound by earlier choices. In this rewrite, I was able to start fresh with data models that included everything I liked from earlier versions of the app, plus all the things I always wished it had! I have high hopes that these new models will be more efficient in the present and more extensible in the future. A good example of one of these changes is that the 'My Favorites' list is now just another list _(albeit with some special handling for user convenience.)_ In the past, this functionality existed separate from 'Lists', requiring a fair amount of hand-waiving to deliver a consistent user experience across both. Now users can use a 'My Favorites' list if they wish, or any other list, and get the same, rich filtering functionality and most up-to-date list behavior across the board!

Last but not least: tests. Album Tags 2 had a small test suite that covered some important elements of the API, however as I maintained the site during slower seasons when new development wasn't happening, I found myself wishing for the confidence and stability better coverage would afford me. With the new version of the app, all important elements of the back-end code are tested, resulting in a much easier path for things like framework upgrades, performance improvements, and future functionality changes. I am going to work hard to maintain this high coverage percentage as the app continues to mature, and the testing tools in place now help lay the groundwork to make that dream as achievable as possible.

## Setup:
1. `cd assets && npm install`
2. Review the paths set in `asset_builder_config.yml` and update if needed
3. Make sure you have Postgres installed and running locally
4. `bin/test` to run tests
5. `bin/start` to run the app in local development

## Tooling
Album Tags 3 includes a front-end resource build pipeline called `asset_builder` which enables the creation custom compiled JavaScript and Sass, allowing the app to ship a more compact asset bundle to the user.

#### To Use Asset Builder:
*these commands are written to be run from the project root directory*
* `ruby ./assets/asset_builder.rb` will compile all materialize resources
* `ruby ./assets/asset_builder.rb {page_name}` will compile all custom resources for a particular page
* `ruby ./assets/asset_builder.rb {page_name} [js, scss, css]` you can pass in a second parameter to only compile one type of assets
