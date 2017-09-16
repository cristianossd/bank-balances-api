# NuBank Balances API

Start the api service `$ sudo docker-compose up -d api`. Install the project dependencies: `$ sudo docker-compose run api mix deps.get`, and to compile: `$ sudo docker-compose run api mix deps.compile`.

Creating the database: `$ sudo docker-compose run api mix ecto.create`. Run the migrations: `$ sudo docker-compose run api mix ecto.migrate`.

Restart the server: `$ sudo docker-compose restart api`.

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
