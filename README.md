# BetterAppGen

Generate Rails 8 applications with an opinionated, production-ready stack.

## Features

- **Solid Stack**: PostgreSQL-backed caching, jobs, and WebSockets (no Redis needed)
  - Solid Cache for caching
  - Solid Queue for background jobs
  - Solid Cable for Action Cable
- **Modern Frontend**: Vite 7 + Tailwind CSS 4 + Stimulus
- **Multi-Database Architecture**: Separate databases for app, cache, queue, and cable
- **UUID Primary Keys**: By default across all models
- **Docker Development**: Complete Docker setup for development
- **Configurable Locale**: Support for multiple languages (en, it, de, fr, es, pt, nl, pl, ru, ja, zh)

## Installation

```bash
gem install better_app_gen
```

## Usage

### Generate a New Application

```bash
# Basic usage (English locale, default ports)
better_app_gen new my-app

# With SimpleForm
better_app_gen new my-app --with-simple-form

# With Italian locale
better_app_gen new my-app --locale it

# Custom ports
better_app_gen new my-app --rails-port 3001 --vite-port 5174

# Skip Docker
better_app_gen new my-app --skip-docker

# Combine options
better_app_gen new my-app --with-simple-form --locale it --rails-port 3001
```

### Check Dependencies

```bash
better_app_gen check
```

### View Version

```bash
better_app_gen version
```

## Options

| Flag | Default | Description |
|------|---------|-------------|
| `--with-simple-form` | false | Include SimpleForm with Tailwind CSS styling |
| `--rails-port PORT` | 3000 | Rails server port |
| `--vite-port PORT` | 5173 | Vite dev server port |
| `--skip-docker` | false | Skip Docker configuration |
| `--locale LOCALE` | en | Default locale (en, it, de, fr, es, pt, nl, pl, ru, ja, zh) |

## Generated Application Structure

```
my-app/
├── app/
│   ├── assets/
│   │   ├── javascripts/
│   │   │   ├── application.js
│   │   │   └── controllers/
│   │   └── stylesheets/
│   │       └── application.css
│   ├── controllers/
│   │   └── home_controller.rb
│   ├── helpers/
│   │   ├── home_helper.rb
│   │   └── vite_helper.rb
│   └── views/
│       ├── home/
│       │   └── index.html.erb
│       └── layouts/
│           └── application.html.erb
├── config/
│   ├── application.rb
│   ├── database.yml
│   └── routes.rb
├── db/
│   ├── migrate/
│   ├── cache_migrate/
│   ├── queue_migrate/
│   └── cable_migrate/
├── .docker/
│   └── Dockerfile.dev
├── script/
│   ├── dc-up
│   ├── dc-down
│   ├── dc-shell
│   └── ...
├── compose.yml
├── vite.config.js
├── postcss.config.js
├── Procfile.dev
└── ...
```

## Development Workflow

### With Docker (Recommended)

```bash
cd my-app
script/dc-up         # Start Docker containers
script/dc-shell      # Open shell in Rails container
rails db:create      # Create databases
rails db:schema:load # Load schema
exit                 # Exit shell
script/dc-down && script/dc-up  # Restart containers
```

### Without Docker

```bash
cd my-app
bundle install
yarn install
rails db:create db:schema:load
bin/dev              # Start Rails + Vite
```

## Requirements

- Ruby >= 3.2.0
- Rails >= 8.0.0
- Node.js >= 20.0.0
- Yarn >= 4.0.0
- PostgreSQL >= 16
- Git

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

```bash
git clone https://github.com/umbertopeserico/better_app_gen.git
cd better_app_gen
bin/setup
rake spec
```

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/umbertopeserico/better_app_gen.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
